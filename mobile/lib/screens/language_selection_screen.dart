import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _selectLanguage(BuildContext context, String code) async {
    await LocalizationService().loadLanguage(code);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F6B6B).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    size: 48,
                    color: Color(0xFFE0A526),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'अपनी भाषा चुनें\nChoose Your Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'अॅप वापरण्यासाठी आपली पसंतीची भाषा निवडा',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 48),

              // Hindi Button
              _buildLanguageCard(
                context,
                title: 'हिन्दी',
                subTitle: 'Hindi',
                code: 'hi',
                accentColor: const Color(0xFFE0A526),
              ),
              const SizedBox(height: 16),

              // Marathi Button
              _buildLanguageCard(
                context,
                title: 'मराठी',
                subTitle: 'Marathi',
                code: 'mr',
                accentColor: const Color(0xFF0F6B6B),
              ),
              const SizedBox(height: 16),

              // English Button
              _buildLanguageCard(
                context,
                title: 'English',
                subTitle: 'English',
                code: 'en',
                accentColor: Colors.blueAccent,
              ),

              const Spacer(),
              const Text(
                'Dhatu E-Waste Platform · Smart India Hackathon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white30,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String title,
    required String subTitle,
    required String code,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: () => _selectLanguage(context, code),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  title.substring(0, 1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}
