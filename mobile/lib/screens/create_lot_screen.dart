import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import '../widgets/core/dhatu_button.dart';
import 'ai_result_screen.dart';

class CreateLotScreen extends StatefulWidget {
  const CreateLotScreen({Key? key}) : super(key: key);

  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  int _currentStep = 0;
  double _weight = 5.0;

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('New Lot', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentStep == 1 ? theme.primaryColor : theme.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: _currentStep == 0 ? _buildPhotoStep(theme) : _buildWeightStep(theme),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: DhatuButton(
                  text: _currentStep == 0 ? 'Next' : 'Analyze Material',
                  icon: _currentStep == 0 ? Icons.arrow_forward : Icons.auto_awesome,
                  onPressed: _nextStep,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoStep(ThemeManager theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 80, color: theme.primaryColor),
          const SizedBox(height: 24),
          Text(
            'Take a photo of the scrap',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          DhatuCard(
            onTap: () {},
            child: Container(
              height: 200,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: theme.subtitleColor),
                  const SizedBox(height: 8),
                  Text('Tap to open camera', style: TextStyle(color: theme.subtitleColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStep(ThemeManager theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scale, size: 80, color: theme.primaryColor),
          const SizedBox(height: 24),
          Text(
            'Estimated Weight (kg)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          DhatuCard(
            child: Column(
              children: [
                Text(
                  '${_weight.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
                Slider(
                  value: _weight,
                  min: 0.5,
                  max: 100.0,
                  activeColor: theme.primaryColor,
                  inactiveColor: theme.primaryColor.withOpacity(0.3),
                  onChanged: (val) {
                    setState(() => _weight = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
