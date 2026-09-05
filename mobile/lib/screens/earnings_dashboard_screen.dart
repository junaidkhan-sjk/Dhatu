import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/localization_service.dart';
import 'payment_status_screen.dart';

class EarningsDashboardScreen extends StatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  State<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends State<EarningsDashboardScreen> {
  Map<String, dynamic> _summary = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  void _fetchEarnings() async {
    setState(() => _loading = true);
    final data = await ApiService().getEarningsSummary();
    setState(() {
      _summary = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    final today = _summary['todayEarningsInr'] ?? 2030;
    final total = _summary['totalEarningsInr'] ?? 8575;
    final pending = _summary['pendingEarningsInr'] ?? 3600;
    final completedCount = _summary['completedCount'] ?? 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('कमाई डैशबोर्ड (Earnings Dashboard)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              final text = 'आपकी आज की कमाई $today रुपये है, और कुल कमाई $total रुपये हो चुकी है।';
              AudioService().speak(text, lang: loc.currentLanguage);
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFE0A526)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Big Today's Earnings Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F6B6B), Color(0xFF073838)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0A526), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("आज की कमाई (Today's Earnings)", style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '₹$today',
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFFE0A526), fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  const Text('डिजिटल व बैंक ट्रांसफर द्वारा भुगतान प्राप्त', style: TextStyle(fontSize: 12, color: Colors.tealAccent)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary 2-Card Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'कुल कमाई (Total)',
                    amount: '₹$total',
                    subtitle: '$completedCount सौदे पूर्ण',
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    title: 'प्रलंबित (Pending)',
                    amount: '₹$pending',
                    subtitle: 'सत्यापन प्रक्रिया में',
                    color: const Color(0xFFE0A526),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Button to open Detailed Payment Status
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentStatusScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('लेन-देन विवरण (View Payment Status) →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String amount,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }
}
