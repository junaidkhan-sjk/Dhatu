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
    final allLots = sync.localLots;

    final filteredLots = _filterStatus == 'all'
        ? allLots
        : allLots.where((l) => l.transactionStatus == _filterStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('मेरे डिजिटल लॉट (My Material Lots)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => sync.syncPendingQueue(),
            icon: Icon(
              Icons.sync_rounded,
              color: sync.isSyncing ? Colors.blueAccent : const Color(0xFFE0A526),
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
        backgroundColor: const Color(0xFFE0A526),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('नया लॉट (+ New Lot)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F172A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'सभी लॉट (All)'),
                  _buildFilterChip('draft', 'ड्राफ्ट (Draft)'),
                  _buildFilterChip('matched', 'रीसायकलर मैच (Matched)'),
                  _buildFilterChip('handed_over', 'हस्तांतरित (Handed Over)'),
                  _buildFilterChip('paid', 'भुगतान पूर्ण (Paid)'),
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
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        const Text(
                          'कोई लॉट नहीं मिला (No Lots Found)',
                          style: TextStyle(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold),
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
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lot.id,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.tealAccent,
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
                                      color: const Color(0xFF0F6B6B).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        lot.material.category[0],
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE0A526)),
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
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        Text(
                                          '${lot.weightKg} kg · ${lot.transactionStatus.toUpperCase()}',
                                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${(lot.finalPriceInr ?? lot.quotedPriceInr).toInt()}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFE0A526),
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

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white70,
        ),
        backgroundColor: const Color(0xFF1E293B),
        selectedColor: const Color(0xFFE0A526),
        checkmarkColor: Colors.black,
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
        label = '🟡 Saved Offline';
        break;
      case SyncState.syncing:
        color = Colors.blue;
        label = '🔵 Synchronizing';
        break;
      case SyncState.synced:
        color = Colors.tealAccent;
        label = '🟢 Synced';
        break;
      case SyncState.attentionRequired:
        color = Colors.redAccent;
        label = '🔴 Attention';
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
