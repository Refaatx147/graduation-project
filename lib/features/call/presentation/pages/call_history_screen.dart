// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:grade_pro/features/call/domain/models/call_history.dart';
import 'package:grade_pro/features/call/presentation/cubit/call_cubit.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 95, 112),
        elevation: 0,
        title: Text(
          'Call History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text('All Calls', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem(
                value: 'missed',
                child: Text('Missed Calls', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Text('Completed Calls', style: GoogleFonts.poppins()),
              ),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<CallCubit, CallState>(
        builder: (context, state) {
          if (state is CallHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff0D343F),
              ),
            );
          }

          if (state is CallHistoryLoaded) {
            if (state.callHistory.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.callHistory.length,
              itemBuilder: (context, index) {
                return _buildCallHistoryItem(context, state.callHistory[index]);
              },
            );
          }

          if (state is CallHistoryError) {
            return _buildErrorState(state.message);
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildCallHistoryItem(BuildContext context, CallHistory call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildCallTypeAvatar(call),
        title: Text(
          call.receiverName,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: call.status == 'missed' ? Colors.red : const Color(0xff0D343F),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(call.timestamp),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              _getCallStatusText(call),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _getStatusColor(call.status),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          color: const Color(0xff34C772),
          onPressed: () {
          },
        ),
      ),
    );
  }

  Widget _buildCallTypeAvatar(CallHistory call) {
    return CircleAvatar(
      backgroundColor: _getAvatarColor(call),
      radius: 25,
      child: Icon(
        call.isVideoCall ? Icons.videocam : Icons.call,
        color: _getIconColor(call),
      ),
    );
  }

  Color _getAvatarColor(CallHistory call) {
    if (call.status == 'missed') return Colors.red.withOpacity(0.1);
    return call.isVideoCall 
        ? const Color(0xff34C772).withOpacity(0.1)
        : const Color(0xff0D343F).withOpacity(0.1);
  }

  Color _getIconColor(CallHistory call) {
    if (call.status == 'missed') return Colors.red;
    return call.isVideoCall 
        ? const Color(0xff34C772)
        : const Color(0xff0D343F);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xff34C772);
      case 'missed':
        return Colors.red;
      case 'rejected':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getCallStatusText(CallHistory call) {
    switch (call.status) {
      case 'completed':
        return '${call.duration} seconds';
      case 'missed':
        return 'Missed Call';
      case 'rejected':
        return 'Call Rejected';
      case 'cancelled':
        return 'Call Cancelled';
      default:
        return call.status;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_end_outlined,
            size: 64,
            color: const Color(0xff0D343F).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No calls yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xff0D343F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your call history will appear here',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}