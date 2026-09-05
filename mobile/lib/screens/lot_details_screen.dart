import 'package:flutter/material.dart';
import '../models/lot_model.dart';

class LotDetailsScreen extends StatelessWidget {
  final MaterialLot lot;
  const LotDetailsScreen({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('लॉट विवरण (${lot.id})', style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF0F6B6B), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lot.material.category,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '₹${(lot.finalPriceInr ?? lot.quotedPriceInr).toInt()}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFE0A526)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'वजन: ${lot.weightKg} kg · ${lot.material.subCategory ?? "Standard"}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  if (lot.recyclerName != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1120),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.business_rounded, color: Colors.tealAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'रीसायकलर: ${lot.recyclerName}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Traceability Timeline Header
            const Text(
              'डिजिटल ट्रेसिबिलिटी टाइमलाइन\nTraceability Audit Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Real Chronological Stages
            ..._buildTimelineEntries(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimelineEntries() {
    final timeline = lot.traceability?.timeline ?? [
      TimelineEvent(
        stage: 'Lot Created',
        timestamp: lot.dateTime,
        note: 'सामग्री की फोटो, वजन और डिजिटल लॉट पंजीकृत किया गया।',
        actorRole: 'collector',
      ),
      TimelineEvent(
        stage: 'Price Estimated',
        timestamp: lot.dateTime,
        note: 'AI द्वारा श्रेणी पहचान व अनुमानित मूल्य निकाला गया।',
        actorRole: 'system',
      ),
    ];

    return timeline.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final isLast = idx == timeline.length - 1;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0A526),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: const Color(0xFF0F6B6B),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.stage,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                      Text(
                        e.timestamp.length > 10 ? e.timestamp.substring(0, 10) : e.timestamp,
                        style: const TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  if (e.note != null) ...[
                    const SizedBox(height: 4),
                    Text(e.note!, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
