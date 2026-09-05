import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lot_model.dart';
import '../services/sync_engine.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = Provider.of<SyncEngine>(context);
    final allLots = sync.localLots;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ऑफ़लाइन सिंक स्थिति (Sync Status)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status KPI Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF0F6B6B)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('ऑफ़लाइन (Pending)', '${sync.offlineCount}', Colors.amber),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _buildStatItem('सिंक पूर्ण (Synced)', '${sync.syncedCount}', Colors.tealAccent),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _buildStatItem('त्रुटि (Attention)', '${sync.attentionCount}', Colors.redAccent),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: sync.isSyncing ? null : () => sync.syncPendingQueue(),
                icon: Icon(
                  Icons.sync_rounded,
                  color: Colors.black,
                  size: 22,
                ),
                label: Text(
                  sync.isSyncing ? 'सिंक हो रहा है... (Syncing)' : 'अभी सिंक करें (Retry Sync Now)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0A526),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'रिकॉर्ड सूची (Local Database Queue)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: allLots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final lot = allLots[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lot.id,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
                            ),
                            Text(
                              '${lot.material.category} · ${lot.weightKg} kg',
                              style: const TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                        _buildBadge(lot.syncState),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace')),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }

  Widget _buildBadge(SyncState state) {
    Color c = Colors.tealAccent;
    String t = '🟢 Synced';
    if (state == SyncState.savedOffline) {
      c = Colors.amber;
      t = '🟡 Offline';
    } else if (state == SyncState.syncing) {
      c = Colors.blue;
      t = '🔵 Syncing';
    } else if (state == SyncState.attentionRequired) {
      c = Colors.redAccent;
      t = '🔴 Attention';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)),
    );
  }
}
