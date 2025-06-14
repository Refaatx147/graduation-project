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
import 'dart:async';

class PatientChatScreen extends StatefulWidget {
  final String caregiverId;
  final String caregiverName;

  const PatientChatScreen({
    Key? key,
    required this.caregiverId,
    required this.caregiverName,
  }) : super(key: key);

  @override
  PatientChatScreenState createState() => PatientChatScreenState();
}

class PatientChatScreenState extends State<PatientChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isPlaying = false;
  Timer? _recordingTimer;
  int _remainingSeconds = 10;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  // Expose these methods for voice control
  void startRecording() async {
    if (!_isRecording) {
      setState(() {
        _remainingSeconds = 10;
      });
      await _startRecording();
      // Start 10-second timer with UI updates
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        }
        if (_remainingSeconds == 0) {
          timer.cancel();
          if (_isRecording) {
            stopRecording();
          }
        }
      });
    }
  }

  void stopRecording() async {
    if (_isRecording) {
      _recordingTimer?.cancel();
      setState(() {
        _remainingSeconds = 10;
      });
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/audio_message.m4a';
        
        await _audioRecorder.start(
           const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );
        
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _isRecording = false;
      });
      _recordingTimer?.cancel();
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      _recordingTimer?.cancel();
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        print('Recording stopped, uploading file from path: $path');
        final audioUrl = await _cloudinaryService.uploadAudio(
          File(path),
          FirebaseAuth.instance.currentUser?.uid ?? '',
        );

        print('Audio uploaded, URL: $audioUrl');
        await _chatRepository.sendMessage(
          senderType: SenderType.patient,
          receiverId: widget.caregiverId,
          messageType: MessageType.audio,
          audioUrl: audioUrl,
        );
        print('Message sent successfully');
      } else {
        print('No recording path available after stopping');
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0D343F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Text(
                widget.caregiverName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0D343F),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.caregiverName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.call, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.pushNamed(context, '/patient-call', arguments: widget.caregiverId);
              },
            ),
          ),
        ],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRepository.getMessages(widget.caregiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
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
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xff0D343F) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Recording stops in $_remainingSeconds seconds',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : const Color(0xff0D343F),
                ),
                child: IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _isRecording ? stopRecording : startRecording,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}