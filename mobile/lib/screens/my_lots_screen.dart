import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lot_model.dart';
import '../services/sync_engine.dart';
import '../services/localization_service.dart';
import 'lot_details_screen.dart';
import 'create_lot_flow.dart';

class MyLotsScreen extends StatefulWidget {
  const MyLotsScreen({super.key});

  @override
  State<MyLotsScreen> createState() => _MyLotsScreenState();
}

class _MyLotsScreenState extends State<MyLotsScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final sync = Provider.of<SyncEngine>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF061E18);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = theme.cardColor;
    final borderColor = isDark ? const Color(0xFF1E3A8A).withOpacity(0.35) : const Color(0xFF061E18).withOpacity(0.12);
    final headerBg = isDark ? const Color(0xFF0B132B) : const Color(0xFFFFFFFF);
    final highlightColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0D9488);

    final allLots = sync.localLots;

    final filteredLots = _filterStatus == 'all'
        ? allLots
        : allLots.where((l) => l.transactionStatus == _filterStatus).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'मेरे डिजिटल लॉट (My Material Lots)',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryText),
        ),
        actions: [
          IconButton(
            onPressed: () => sync.syncPendingQueue(),
            icon: Icon(
              Icons.sync_rounded,
              color: sync.isSyncing ? Colors.blueAccent : highlightColor,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateLotFlow()),
          );
        },
        backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF061E18),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('नया लॉट (+ New Lot)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'सभी लॉट (All)', isDark),
                  _buildFilterChip('draft', 'ड्राफ्ट (Draft)', isDark),
                  _buildFilterChip('matched', 'रीसायकलर मैच (Matched)', isDark),
                  _buildFilterChip('handed_over', 'हस्तांतरित (Handed Over)', isDark),
                  _buildFilterChip('paid', 'भुगतान पूर्ण (Paid)', isDark),
                ],
              ),
            ),
          ),

          Expanded(
            child: filteredLots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: secondaryText.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'कोई लॉट नहीं मिला (No Lots Found)',
                          style: TextStyle(color: secondaryText, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredLots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final lot = filteredLots[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LotDetailsScreen(lot: lot)),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lot.id,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: highlightColor,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  _buildSyncIndicator(lot.syncState),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF172554) : const Color(0xFF061E18).withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        lot.material.category[0],
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: highlightColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lot.material.category,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
                                        ),
                                        Text(
                                          '${lot.weightKg} kg · ${lot.transactionStatus.toUpperCase()}',
                                          style: TextStyle(fontSize: 12, color: secondaryText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${(lot.finalPriceInr ?? lot.quotedPriceInr).toInt()}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label, bool isDark) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
        ),
        backgroundColor: isDark ? const Color(0xFF172554).withOpacity(0.4) : const Color(0xFF061E18).withOpacity(0.06),
        selectedColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF061E18),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (val) {
          setState(() => _filterStatus = status);
        },
      ),
    );
  }

  Widget _buildSyncIndicator(SyncState state) {
    Color color;
    String label;

    switch (state) {
      case SyncState.savedOffline:
        color = Colors.amber;
        label = 'Saved Offline';
        break;
      case SyncState.syncing:
        color = Colors.blue;
        label = 'Synchronizing';
        break;
      case SyncState.synced:
        color = const Color(0xFF0D9488);
        label = 'Synced';
        break;
      case SyncState.attentionRequired:
        color = Colors.redAccent;
        label = 'Attention';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
