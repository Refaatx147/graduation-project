// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverSupportScreen extends StatefulWidget {
  const CaregiverSupportScreen({Key? key}) : super(key: key);

  @override
  State<CaregiverSupportScreen> createState() => _CaregiverSupportScreenState();
}

class _CaregiverSupportScreenState extends State<CaregiverSupportScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  

 

  @override
  Widget build(BuildContext context) {
    return 
     Scaffold(
        backgroundColor: const Color(0xffFFF9ED),
        appBar: AppBar(
          backgroundColor: const Color(0xffFFF9ED),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xff0D343F)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Help & Support',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff0D343F),
              ),
            ),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupportSection(
                title: 'FAQ',
                icon: Icons.question_answer_outlined,
                items: [
                  'How to manage patient medications?',
                  'How to update patient information?',
                  'How to use video call feature?',
                  'How to set reminders?',
                ],
              ),
              const SizedBox(height: 24),
              _buildSupportSection(
                title: 'Contact Us',
                icon: Icons.contact_support_outlined,
                items: [
                  'Email: support@gradepro.com',
                  'Phone: +1 234 567 890',
                  'Working hours: 24/7',
                ],
              ),
              const SizedBox(height: 24),
              _buildSupportSection(
                title: 'User Guide',
                icon: Icons.menu_book_outlined,
                items: [
                  'Getting Started',
                  'Patient Management',
                  'Emergency Contacts',
                  'Settings & Customization',
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildSupportSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff0D343F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xff0D343F)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0D343F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_right,
                  color: Color(0xff0D343F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff0D343F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}