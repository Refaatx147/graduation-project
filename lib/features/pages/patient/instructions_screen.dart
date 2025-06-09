// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 95, 112),
        title: Text(
          'Instructions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            icon: Icons.phone_in_talk,
            title: 'Making Calls',
            items: [
              'Tap the Audio or Video button to start a call',
              'Use Emergency button for urgent situations',
              'Wait for your caregiver to accept the call',
              'Ensure good internet connection for better quality',
            ],
          ),
          _buildSection(
            icon: Icons.emergency,
            title: 'Emergency Features',
            items: [
              'Red Emergency button for urgent situations',
              'Automatically notifies all connected caregivers',
              'Provides your current location to caregivers',
              'Initiates immediate video call connection',
            ],
          ),
          _buildSection(
            icon: Icons.chat_bubble,
            title: 'Chat Communication',
            items: [
              'Use chat for non-urgent communication',
              'Send text messages to your caregivers',
              'Share your daily updates and needs',
              'Check message status (sent/delivered/read)',
            ],
          ),
          _buildSection(
            icon: Icons.history,
            title: 'Call History',
            items: [
              'View all past calls and their duration',
              'Check missed calls from caregivers',
              'Easily redial from call history',
              'Monitor communication patterns',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xff0D343F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) => _buildInstruction(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xff0D343F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}