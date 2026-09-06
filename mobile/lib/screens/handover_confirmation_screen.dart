import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_button.dart';
import 'home_dashboard_screen.dart';

class HandoverConfirmationScreen extends StatelessWidget {
  const HandoverConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'Handover Complete!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.onPrimaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment of ₹1,404 is processing.',
              style: TextStyle(fontSize: 18, color: theme.onPrimaryColor.withOpacity(0.8)),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                child: DhatuButton(
                  text: 'Back to Dashboard',
                  icon: Icons.home_rounded,
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
