import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/sync_engine.dart';
import '../services/audio_service.dart';
import 'create_lot_flow.dart';
import 'price_board_screen.dart';
import 'my_lots_screen.dart';
import 'sync_status_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final sync = Provider.of<SyncEngine>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F6B6B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.recycling_rounded, color: Color(0xFFE0A526), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tr('app_name'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  loc.tr('tagline'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFE0A526),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 4-state Sync Badge
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sync.isSyncing
                    ? Colors.blue.withOpacity(0.2)
                    : sync.offlineCount > 0
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sync.isSyncing
                      ? Colors.blue
                      : sync.offlineCount > 0
                          ? Colors.amber
                          : Colors.teal,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sync.isSyncing
                          ? Colors.blue
                          : sync.offlineCount > 0
                              ? Colors.amber
                              : Colors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sync.isSyncing
                        ? 'Syncing'
                        : sync.offlineCount > 0
                            ? '${sync.offlineCount} Offline'
                            : 'Live Synced',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sync.isSyncing
                          ? Colors.blueAccent
                          : sync.offlineCount > 0
                              ? Colors.amber
                              : Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Collector Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F6B6B), Color(0xFF0B4E4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330F6B6B),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'रमेश (कबाड़ी) · Ramesh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'धारावी जोन / Dharavi Zone',
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'आज का औसत भाव (Today\'s Top Rate)',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'सर्किट बोर्ड (PCB): ',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const Text(
                        '₹140/kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE0A526),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          AudioService().speak(
                            'आज सर्किट बोर्ड का भाव 140 रुपये प्रति किलो है।',
                            lang: loc.currentLanguage,
                          );
                        },
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFE0A526)),
                        tooltip: 'Listen to rates',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Huge Primary CTA Button: + Create New Lot
            SizedBox(
              height: 72,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateLotFlow()),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 30),
                label: Text(
                  loc.tr('create_new_lot'),
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0A526),
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0x66E0A526),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Navigation Grid
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'भाव सूची (Price Board)',
                    subtitle: '5 सामग्रियों के ताज़ा दर',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PriceBoardScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildActionTile(
                    context,
                    icon: Icons.inventory_2_rounded,
                    title: 'मेरे लॉट (My Lots)',
                    subtitle: 'ट्रेसिबिलिटी व स्थिति',
                    color: Colors.tealAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyLotsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Safety Tip Card with Audio
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFFE0A526), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'सुरक्षा सलाह (Safety Tip)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE0A526),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'बैटरी या एसिड छूते समय दस्ताने पहनें। बैटरी को कभी न तोड़ें।',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      AudioService().speak(
                        'बैटरी या एसिड छूते समय हमेशा दस्ताने पहनें।',
                        lang: loc.currentLanguage,
                      );
                    },
                    icon: const Icon(Icons.volume_up_rounded, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
