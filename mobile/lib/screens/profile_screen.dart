import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';
import '../services/theme_service.dart';
import 'language_selection_screen.dart';
import 'safety_guidance_screen.dart';
import 'sync_status_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeService = Provider.of<ThemeService>(context);

    final primaryTextColor = isDark ? ThemeService.darkTextPrimary : ThemeService.lightTextPrimary;
    final secondaryTextColor = isDark ? ThemeService.darkTextSecondary : ThemeService.lightTextSecondary;
    final accentColor = isDark ? ThemeService.darkAccent : ThemeService.lightAccent;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'प्रोफ़ाइल व सेटिंग्स (Profile & Settings)',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card (Neumorphic Raised)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: ThemeService.neuRaised(
                isDark: isDark,
                radius: 24,
                depth: 6,
                blur: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: ThemeService.neuInset(isDark: isDark, radius: 30),
                    child: Center(
                      child: Icon(Icons.person_rounded, size: 34, color: accentColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'रमेश कुमार (कबाड़ी)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+91 9876543210',
                          style: TextStyle(fontSize: 12, color: secondaryTextColor, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'पंजीकृत ई-कचरा संकलनकर्ता (Informal Collector)',
                          style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Neumorphic Theme Switcher Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: ThemeService.neuRaised(
                isDark: isDark,
                radius: 20,
                depth: 5,
                blur: 12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: ThemeService.neuInset(isDark: isDark, radius: 12),
                    child: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDark ? 'Neumorphic Dark Mode' : 'Neumorphic Light Mode',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDark ? 'Tap switch for Soft Ceramic Light' : 'Tap switch for Midnight Slate Dark',
                          style: TextStyle(fontSize: 11, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (val) => themeService.toggleTheme(),
                    activeColor: accentColor,
                    activeTrackColor: isDark ? const Color(0xFF1E2B4A) : const Color(0xFFDFE6F0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Settings Options (Neumorphic Raised Tiles)
            _buildNeuSettingTile(
              context,
              isDark: isDark,
              accentColor: accentColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              icon: Icons.translate_rounded,
              title: 'भाषा बदलें (Change Language)',
              subtitle: 'हिन्दी / मराठी / English',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildNeuSettingTile(
              context,
              isDark: isDark,
              accentColor: accentColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              icon: Icons.health_and_safety_rounded,
              title: 'सुरक्षा मार्गदर्शन (Safety Guidance)',
              subtitle: 'बैटरी व सीआरटी सुरक्षित निपटान',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SafetyGuidanceScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildNeuSettingTile(
              context,
              isDark: isDark,
              accentColor: accentColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              icon: Icons.cloud_sync_rounded,
              title: 'ऑफ़लाइन सिंक स्थिति (Sync Status)',
              subtitle: 'स्थानीय डेटा व कतार प्रबंधन',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildNeuSettingTile(
              context,
              isDark: isDark,
              accentColor: Colors.redAccent,
              primaryTextColor: Colors.redAccent,
              secondaryTextColor: secondaryTextColor,
              icon: Icons.logout_rounded,
              title: 'लॉगआउट (Logout)',
              subtitle: 'खाते से बाहर निकलें (Sign out)',
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? ThemeService.darkSurface : ThemeService.lightSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('लॉगआउट करें?', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
                    content: Text('क्या आप सचमुच लॉगआउट करना चाहते हैं?', style: TextStyle(color: secondaryTextColor)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('रद्द करें (Cancel)', style: TextStyle(color: secondaryTextColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('लॉगआउट (Logout)'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('dhatu_auth_token');
                  await prefs.remove('dhatu_user');
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),

            // Data Maturity Tag (Neumorphic Inset)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: ThemeService.neuInset(isDark: isDark, radius: 16),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data Integrity: Neumorphic UI Standard · Smart India Hackathon',
                      style: TextStyle(fontSize: 11, color: secondaryTextColor, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuSettingTile(
    BuildContext context, {
    required bool isDark,
    required Color accentColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ThemeService.neuRaised(
          isDark: isDark,
          radius: 20,
          depth: 5,
          blur: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: ThemeService.neuInset(isDark: isDark, radius: 12),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: secondaryTextColor.withOpacity(0.4), size: 16),
          ],
        ),
      ),
    );
  }
}
