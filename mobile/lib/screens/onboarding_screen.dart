import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_button.dart';
import 'home_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'icon': Icons.camera_alt,
      'title': 'Snap & Track',
      'subtitle': 'Take a photo of e-waste to automatically classify it',
    },
    {
      'icon': Icons.account_balance_wallet,
      'title': 'Know the Value',
      'subtitle': 'Get an instant estimate for your material lot',
    },
    {
      'icon': Icons.handshake,
      'title': 'Connect & Earn',
      'subtitle': 'Find authorized recyclers nearby and secure a fair price',
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          data['icon'],
                          size: 100,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data['title'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['subtitle'],
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.subtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Progress Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  width: _currentPage == index ? 24 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? theme.primaryColor 
                        : theme.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: DhatuButton(
                  text: _currentPage == _onboardingData.length - 1 
                      ? 'Get Started' 
                      : 'Next',
                  icon: _currentPage == _onboardingData.length - 1 
                      ? Icons.check_circle_rounded 
                      : Icons.arrow_forward_rounded,
                  isPrimary: true,
                  onPressed: _nextPage,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
