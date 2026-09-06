import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/sync_engine.dart';
import '../services/audio_service.dart';
import '../services/theme_service.dart';
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
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    final primaryText = isDark ? ThemeService.darkTextPrimary : ThemeService.lightTextPrimary;
    final secondaryText = isDark ? ThemeService.darkTextSecondary : ThemeService.lightTextSecondary;
    final accentColor = isDark ? ThemeService.darkAccent : ThemeService.lightAccent;

    return Scaffold(
      backgroundColor: isDark ? ThemeService.darkCanvas : ThemeService.lightCanvas,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF061E18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.recycling_rounded, color: isDark ? const Color(0xFF38BDF8) : Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tr('app_name'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryText,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  loc.tr('tagline'),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0D9488),
                    fontWeight: FontWeight.w600,
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
                    ? Colors.blue.withOpacity(0.15)
                    : sync.offlineCount > 0
                        ? Colors.amber.withOpacity(0.15)
                        : isDark
                            ? const Color(0xFF1E3A8A).withOpacity(0.3)
                            : const Color(0xFF061E18).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sync.isSyncing
                      ? Colors.blue
                      : sync.offlineCount > 0
                          ? Colors.amber
                          : isDark
                              ? const Color(0xFF38BDF8).withOpacity(0.4)
                              : const Color(0xFF0D9488).withOpacity(0.4),
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
                              : isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0D9488),
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
                              : isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF047857),
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
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0B132B), const Color(0xFF172554)]
                      : [const Color(0xFF061E18), const Color(0xFF0F382E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x33000000) : const Color(0x22061E18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
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
                      Text(
                        '₹140/kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF86EFAC),
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
                        icon: Icon(Icons.volume_up_rounded, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF86EFAC)),
                        tooltip: 'Listen to rates',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Huge Primary CTA Button: + Create New Lot
            SizedBox(
              height: 68,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateLotFlow()),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 28),
                label: Text(
                  loc.tr('create_new_lot'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF061E18),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: isDark ? const Color(0x662563EB) : const Color(0x44061E18),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Navigation Grid
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'भाव सूची (Price Board)',
                    subtitle: '5 सामग्रियों के ताज़ा दर',
                    iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D9488),
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
                    iconColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF064E3B),
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
            const SizedBox(height: 20),

            // Safety Tip Card with Audio (Neumorphic Raised)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: ThemeService.neuRaised(
                isDark: isDark,
                radius: 20,
                depth: 5,
                blur: 12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF172554) : const Color(0xFF061E18).withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0D9488),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'सुरक्षा सलाह (Safety Tip)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'बैटरी या एसिड छूते समय दस्ताने पहनें। बैटरी को कभी न तोड़ें।',
                          style: TextStyle(fontSize: 12, color: secondaryText),
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
                    icon: Icon(
                      Icons.volume_up_rounded,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0D9488),
                    ),
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
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF061E18);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF1E3A8A).withOpacity(0.35) : const Color(0xFF061E18).withOpacity(0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
