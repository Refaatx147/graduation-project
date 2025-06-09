// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/core/services/cloudinary_service.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_message.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class CaregiverChatScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CaregiverChatScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<CaregiverChatScreen> createState() => _CaregiverChatScreenState();
}

class _CaregiverChatScreenState extends State<CaregiverChatScreen> with SingleTickerProviderStateMixin {
  final ChatRepository _chatRepository = ChatRepository();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AudioRecorder? _audioRecorder;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isPlaying = false;
  bool _isTyping = false;
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initAnimations();
  }

  void _initAnimations() {
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _recordingAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _recordingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder?.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    _recordingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    try {
      _audioRecorder = AudioRecorder();
      await _requestPermissions();
    } catch (e) {
      print('Error initializing recorder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing recorder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record audio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (_audioRecorder == null) {
        await _initRecorder();
        if (_audioRecorder == null) {
          throw Exception('Failed to initialize recorder');
        }
      }

      if (!await _audioRecorder!.hasPermission()) {
        await _requestPermissions();
        return;
      }

      final directory = await getTemporaryDirectory();
      _recordingPath = '${directory.path}/audio_message.m4a';
      
      await _audioRecorder!.start(
        const  RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );
      
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder == null) return;
      
      final path = await _audioRecorder!.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        try {
          final audioUrl = await _cloudinaryService.uploadAudio(
            File(path),
            FirebaseAuth.instance.currentUser?.uid ?? '',
          );

          await _chatRepository.sendMessage(
            receiverId: widget.patientId,
            messageType: MessageType.audio,
            audioUrl: audioUrl,
            senderType: SenderType.caregiver,
          );
        } catch (e) {
          print('Error uploading audio: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading audio: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTextMessage() async {
    if (_textController.text.trim().isEmpty) return;

    try {
      await _chatRepository.sendMessage(
        receiverId: widget.patientId,
        messageType: MessageType.text,
        text: _textController.text.trim(),
        senderType: SenderType.caregiver,
      );

      _textController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 29, 140, 170),
              child: Text(
                widget.patientName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                StreamBuilder<bool>(
                  
                  stream: _chatRepository.getUserOnlineStatus(widget.patientId),
                  builder: (context, snapshot) {
                    print('patient id : ${widget.patientId}');
                    final isOnline = snapshot.data ?? false;
                    return Text(
                      isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green[100] : Colors.grey[300],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xff0D343F),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff0D343F).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                
                stream: _chatRepository.getMessages(widget.patientId),
                builder: (context, snapshot) {
                                      print('patent id : ${widget.patientId}');

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff0D343F),
                      ),
                    );
                  }
                  final messages = snapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;

                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Patient is typing...',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xff0D343F),
              child: Text(
                widget.patientName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xff0D343F) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.messageType == MessageType.text)
                    Text(
                      message.text!,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else if (message.messageType == MessageType.audio)
                    GestureDetector(
                      onTap: () => _playAudio(message.audioUrl!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white.withOpacity(0.1) : const Color(0xff0D343F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: isMe ? Colors.white : const Color(0xff0D343F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Audio Message',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: isMe ? Colors.white : const Color(0xff0D343F),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const  CircleAvatar(
              radius: 12,
              backgroundColor:  Color(0xff0D343F),
              child:  Text(
                'Me',
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _recordingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _recordingAnimation.value : 1.0,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : const Color(0xff0D343F),
                  ),
                );
              },
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isTyping = value.isNotEmpty;
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color(0xff0D343F),
            ),
            onPressed: _sendTextMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
} 