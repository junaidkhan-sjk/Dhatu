import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import '../widgets/core/dhatu_button.dart';
import 'estimated_value_screen.dart';

class AiResultScreen extends StatelessWidget {
  const AiResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Analysis Result', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DhatuCard(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.image, size: 80, color: theme.primaryColor), // Mock photo
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Identified Material',
                      style: TextStyle(fontSize: 16, color: theme.subtitleColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mixed Copper Wires',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: const Text('High Confidence (94%)'),
                          backgroundColor: Colors.green.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: DhatuButton(
                      text: 'Change',
                      isPrimary: false,
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DhatuButton(
                      text: 'Confirm',
                      isPrimary: true,
                      icon: Icons.check,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EstimatedValueScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
