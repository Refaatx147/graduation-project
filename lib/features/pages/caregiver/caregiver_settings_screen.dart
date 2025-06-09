import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaregiverSettingsScreen extends StatefulWidget {
  const CaregiverSettingsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CaregiverSettingsScreenState createState() => _CaregiverSettingsScreenState();
}

class _CaregiverSettingsScreenState extends State<CaregiverSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xff0D343F),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Settings'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile Information',
                  subtitle: 'Update your personal details',
                  onTap: () {
                    // Navigate to profile edit
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                    activeColor: const Color(0xff0D343F),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location Sharing',
                  subtitle: 'Control location sharing settings',
                  trailing: Switch(
                    value: _locationSharingEnabled,
                    onChanged: (value) {
                      setState(() => _locationSharingEnabled = value);
                    },
                    activeColor: const Color(0xff0D343F),
                  ),
                ),
              ],
            ),
            _buildSectionHeader('App Settings'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark/light theme',
                  trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() => _darkModeEnabled = value);
                    },
                    activeColor: const Color(0xff0D343F),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ],
            ),
            _buildSectionHeader('Support'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get assistance and FAQs',
                  onTap: () {
                    // Navigate to help center
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    // Navigate to terms of service
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff0D343F),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xff0D343F).withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0D343F).withAlpha(26),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff0D343F).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xff0D343F),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff0D343F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: const Color(0xff0D343F).withAlpha(153),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xff0D343F).withAlpha(26),
      indent: 16,
      endIndent: 16,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff0D343F),
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(
        language,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 16,
            color: _selectedLanguage == language
                ? const Color(0xff0D343F)
                : const Color(0xff0D343F).withAlpha(153),
            fontWeight: _selectedLanguage == language
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
      trailing: _selectedLanguage == language
          ? const Icon(
              Icons.check_circle,
              color: Color(0xff0D343F),
            )
          : null,
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/user-select');
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
} 