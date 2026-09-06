import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dummy App Logo placeholder (since we don't have the actual generated icon image file here)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowDark,
                    blurRadius: 20,
                    offset: const Offset(10, 10),
                  ),
                  BoxShadow(
                    color: theme.shadowLight,
                    blurRadius: 20,
                    offset: const Offset(-10, -10),
                  ),
                ],
              ),
              child: const Icon(Icons.recycling, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'Dhatu',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Har Taar Mein Mulya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
