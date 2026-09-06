import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import '../widgets/core/dhatu_button.dart';
import 'recycler_matching_screen.dart';

class EstimatedValueScreen extends StatelessWidget {
  const EstimatedValueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Estimated Value', style: TextStyle(color: theme.textColor)),
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
                    const SizedBox(height: 16),
                    Text(
                      '5.0 kg Mixed Copper Wires',
                      style: TextStyle(fontSize: 18, color: theme.subtitleColor),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        Text('1,250 - 1,400', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Estimate Only',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: DhatuButton(
                  text: 'Find Buyers Nearby',
                  icon: Icons.search,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RecyclerMatchingScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
