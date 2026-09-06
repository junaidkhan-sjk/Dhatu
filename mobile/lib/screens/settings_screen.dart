import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import '../widgets/core/dhatu_button.dart';
import '../widgets/core/dhatu_progress.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.textColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Theme Toggles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Theme Toggles
              DhatuCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Glassmorphism Mode',
                        style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Switch between Neomorphism and Glassmorphism',
                        style: TextStyle(color: theme.subtitleColor),
                      ),
                      value: theme.styleMode == ThemeStyleMode.glassmorphism,
                      onChanged: (val) {
                        theme.setStyleMode(
                          val ? ThemeStyleMode.glassmorphism : ThemeStyleMode.neomorphism,
                        );
                      },
                      activeColor: theme.primaryColor,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600),
                      ),
                      value: theme.isDarkMode,
                      onChanged: (val) {
                        theme.toggleDarkMode();
                      },
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              Text(
                'Component Preview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 16),

              // Button Previews
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: DhatuButton(
                      text: 'Primary',
                      icon: Icons.check_circle,
                      isPrimary: true,
                      onPressed: () {
                        // Dummy action
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DhatuButton(
                      text: 'Secondary',
                      icon: Icons.close_rounded,
                      isPrimary: false,
                      onPressed: () {
                        // Dummy action
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              DhatuButton(
                text: 'Loading State',
                icon: Icons.hourglass_empty_rounded,
                isLoading: true,
                onPressed: () {},
              ),

              const SizedBox(height: 32),

              // Progress Preview
              Text(
                'Progress / Skeleton',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              const DhatuProgress(height: 80),

              const SizedBox(height: 32),
              
              // Color Picker Mock (Will implement full later)
              Text(
                'Primary Color (Mock)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ColorDot(color: const Color(0xFF4CAF50), theme: theme), // Green
                  _ColorDot(color: const Color(0xFF2196F3), theme: theme), // Blue
                  _ColorDot(color: const Color(0xFFFF9800), theme: theme), // Orange
                  _ColorDot(color: const Color(0xFF9C27B0), theme: theme), // Purple
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final ThemeManager theme;

  const _ColorDot({required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isSelected = theme.primaryColor.value == color.value;
    return GestureDetector(
      onTap: () => theme.setPrimaryColor(color),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: theme.textColor, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
      ),
    );
  }
}
