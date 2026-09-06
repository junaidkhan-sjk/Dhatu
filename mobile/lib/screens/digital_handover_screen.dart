import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import '../widgets/core/dhatu_button.dart';
import 'handover_confirmation_screen.dart';

class DigitalHandoverScreen extends StatelessWidget {
  const DigitalHandoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Digital Handover', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DhatuCard(
                child: Column(
                  children: [
                    Text('Reference Number', style: TextStyle(color: theme.subtitleColor)),
                    const SizedBox(height: 8),
                    Text('DHT-9982-XYZ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor, letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Map Pin Mock
              DhatuCard(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.map, size: 48, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'GreenTech Facility, Plot 42, MIDC',
                            style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Final Confirmations
              DhatuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verify Final Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
                    const SizedBox(height: 16),
                    _buildCheckRow(theme, 'Final Weight: 5.2 kg (+0.2 kg)'),
                    const SizedBox(height: 8),
                    _buildCheckRow(theme, 'Final Price: ₹1,404'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              DhatuButton(
                text: 'Confirm Handover & Payment',
                icon: Icons.qr_code_scanner,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HandoverConfirmationScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow(ThemeManager theme, String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: theme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: theme.textColor, fontSize: 16)),
      ],
    );
  }
}
