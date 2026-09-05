import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/localization_service.dart';

class SafetyGuidanceScreen extends StatelessWidget {
  const SafetyGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    final List<Map<String, dynamic>> safetyTips = [
      {
        'title': 'लीथियम व एसिड बैटरी (Battery Safety)',
        'description': 'बैटरी छूते समय हमेशा मोटे दस्ताने पहनें। बैटरी को कभी न तोड़ें या काटें। आग व पानी से दूर रखें।',
        'icon': Icons.battery_alert_rounded,
        'color': Colors.amberAccent,
        'speech': 'बैटरी छूते समय हमेशा मोटे दस्ताने पहनें। बैटरी को कभी न तोड़ें या काटें।',
      },
      {
        'title': 'सीआरटी स्क्रीन व कांच (CRT Tube)',
        'description': 'सीआरटी टीवी ट्यूब को कभी न फोड़ें। इसमें वैक्यूम और भारी सीसा होता है जो फेफड़ों के लिए घातक है।',
        'icon': Icons.tv_off_rounded,
        'color': Colors.redAccent,
        'speech': 'सीआरटी टीवी ट्यूब को कभी न फोड़ें। इसमें खतरनाक गैस और जहरीला सीसा होता है।',
      },
      {
        'title': 'बिजली के तार (Cable Stripping)',
        'description': 'प्लास्टिक निकालने के लिए तार को कभी न जलाएं! जहरीला धुआं स्वास्थ्य को नुकसान पहुंचाता है।',
        'icon': Icons.power_off_rounded,
        'color': Colors.orangeAccent,
        'speech': 'प्लास्टिक निकालने के लिए तार को कभी न जलाएं। खुले में आग लगाना कानूनी अपराध है।',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('सुरक्षा निर्देश (Safety Guidance)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: safetyTips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final tip = safetyTips[index];

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (tip['color'] as Color).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (tip['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(tip['icon'] as IconData, color: tip['color'] as Color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        tip['title'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  tip['description'] as String,
                  style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AudioService().speak(tip['speech'] as String, lang: loc.currentLanguage);
                    },
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text('🔊 निर्देश सुनें', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F6B6B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
