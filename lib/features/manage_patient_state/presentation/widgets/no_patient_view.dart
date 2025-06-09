import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoPatientView extends StatelessWidget {
  const NoPatientView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff0D343F).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_off,
              size: 64,
              color: Color(0xff0D343F),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No patient connected',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Color(0xff0D343F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please scan the patient\'s QR code first',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 