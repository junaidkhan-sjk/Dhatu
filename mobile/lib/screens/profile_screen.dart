import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import 'language_selection_screen.dart';
import 'safety_guidance_screen.dart';
import 'sync_status_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('प्रोफ़ाइल व सेटिंग्स (Profile & Settings)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F6B6B).withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0A526), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, size: 36, color: Color(0xFFE0A526)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('रमेश कुमार (कबाड़ी)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('+91 9876543210', style: TextStyle(fontSize: 12, color: Colors.white60, fontFamily: 'monospace')),
                        SizedBox(height: 4),
                        Text('पंजीकृत ई-कचरा संकलनकर्ता (Informal Collector)', style: TextStyle(fontSize: 11, color: Colors.tealAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Options
            _buildSettingTile(
              context,
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
            const SizedBox(height: 12),

            _buildSettingTile(
              context,
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
            const SizedBox(height: 12),

            _buildSettingTile(
              context,
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
            const SizedBox(height: 24),

            // Data Maturity Tag
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFE0A526), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'dataMaturity Policy: All records tagged demo / synthetic / field_collected',
                      style: TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'monospace'),
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

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F6B6B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFE0A526), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}
