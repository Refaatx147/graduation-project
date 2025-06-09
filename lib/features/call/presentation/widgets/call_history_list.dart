// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/call_history.dart';
import '../cubit/call_cubit.dart';

class CallHistoryList extends StatefulWidget {
  const CallHistoryList({Key? key}) : super(key: key);

  @override
  State<CallHistoryList> createState() => _CallHistoryListState();
}

class _CallHistoryListState extends State<CallHistoryList> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final double _collapsedHeight = 80;
  final double _expandedHeight = 300;
  late AnimationController _animationController;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start collapsed
    _animationController.value = 0;
  }

  @override
  void dispose() {
    _mounted = false;
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!_mounted) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallCubit, CallState>(
      listenWhen: (previous, current) {
        if (previous is CallHistoryLoaded && current is CallHistoryLoaded) {
          return previous.callHistory.length != current.callHistory.length ||
                 !_areListsEqual(previous.callHistory, current.callHistory);
        }
        return previous.runtimeType != current.runtimeType;
      },
      buildWhen: (previous, current) {
        if (previous is CallHistoryLoaded && current is CallHistoryLoaded) {
          return previous.callHistory.length != current.callHistory.length ||
                 !_areListsEqual(previous.callHistory, current.callHistory);
        }
        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, state) {
        if (!_mounted) return;
      },
      builder: (context, state) {
        if (!_mounted) return const SizedBox.shrink();
        
        if (state is CallHistoryLoading) {
          return const SizedBox.shrink();
        }

        if (state is CallHistoryError) {
          print('Error in call history: ${state.message}');
          return const SizedBox.shrink();
        }

        if (state is CallHistoryLoaded) {
          final calls = state.callHistory;
          
          if (calls.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            height: _isExpanded ? _expandedHeight : _collapsedHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                if (_isExpanded) Expanded(child: _buildCallList(calls)),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff0D343F),
              const Color(0xff0D343F).withOpacity(0.9),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Recent Calls',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: _isExpanded ? 0.5 : 0,
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallList(List<CallHistory> calls) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: calls.length,
        itemBuilder: (context, index) {
          final call = calls[index];
          return _buildCallItem(call);
        },
      ),
    );
  }

  Widget _buildCallItem(CallHistory call) {
    final isOutgoing = call.callerId == FirebaseAuth.instance.currentUser?.uid;
    final otherPersonName = isOutgoing ? call.receiverName : call.callerName;
    final callType = call.isVideoCall ? 'Video' : 'Audio';
    final callStatus = call.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getStatusColor(call.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xff0D343F),
            child: Text(
              otherPersonName.isNotEmpty ? otherPersonName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          otherPersonName,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xff0D343F),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatCallInfo(call),
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(call.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$callType Call • ${callStatus.toUpperCase()}',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 11,
                    color: _getStatusColor(call.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(call.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            call.isVideoCall ? Icons.videocam : Icons.call,
            color: _getStatusColor(call.status),
            size: 20,
          ),
        ),
      ),
    );
  }

  String _formatCallInfo(CallHistory call) {
    final time = _formatTime(call.timestamp);
    final duration = call.duration > 0 ? ' • ${_formatDuration(call.duration)}' : '';
    return '$time$duration';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final callDate = DateTime(time.year, time.month, time.day);

    if (callDate == today) {
      return 'Today ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (callDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'rejected':
        return Colors.orange;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  bool _areListsEqual(List<CallHistory> list1, List<CallHistory> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].timestamp != list2[i].timestamp ||
          list1[i].status != list2[i].status) {
        return false;
      }
    }
    return true;
  }
} 