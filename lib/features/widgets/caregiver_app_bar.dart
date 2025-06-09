import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_settings_screen.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_support_screen.dart';

class CaregiverAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onNotificationPressed;

  const CaregiverAppBar({
    Key? key,
    required this.title,
    this.leadingIcon = Icons.person,
    this.onNotificationPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user-select',
          (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showActionMenu(BuildContext context) {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox? overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    try {
      final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
      final buttonSize = button.size;
      
      final RelativeRect position = RelativeRect.fromLTRB(
        buttonPosition.dx + buttonSize.width - 180,
        buttonPosition.dy + buttonSize.height,
        buttonPosition.dx + buttonSize.width,
        buttonPosition.dy + buttonSize.height + 180,
      );

      showMenu(
        
        color: const Color.fromARGB(255, 244, 243, 243),
        context: context,
        position: position,
        constraints: const BoxConstraints(
          minWidth: 180,
          maxWidth: 180,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        items: [
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {
            //  Navigator.of(context).pop();
              onNotificationPressed?.call();
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CaregiverSupportScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CaregiverSettingsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(

            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              Navigator.pop(context); // Close menu
              _handleLogout(context);
            },
          ),
        ],
      ).then((value) {
        // Handle menu close if needed
        if (value == null) return;
      });
    } catch (e) {
      debugPrint('Error showing menu: $e');
    }
  }

  PopupMenuItem _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      
      onTap: onTap,
      height: 45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
             
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xff0D343F),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : const Color(0xff0D343F),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 24, 77, 91),
      leading: Row(
        children: [
          const SizedBox(width: 16),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final userName = snapshot.data?.get('name') ?? 'Caregiver';
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(leadingIcon, color: const Color(0xff0D343F)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      leadingWidth: 200,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) {
            _showActionMenu(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}