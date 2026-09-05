import 'package:flutter/material.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  String _activeTab = 'paid'; // 'paid' or 'pending'

  final List<Map<String, dynamic>> _samplePayments = [
    {
      'lotId': 'DH-2026-0812',
      'material': 'PCB (सर्किट बोर्ड)',
      'weight': '14.5 kg',
      'amount': '₹2,030',
      'status': 'paid',
      'method': 'Digital UPI',
      'date': '04 Sep 2026',
      'recycler': 'EcoMetals Green Yard',
    },
    {
      'lotId': 'DH-2026-0815',
      'material': 'Battery (ई-बाइक बैटरी)',
      'weight': '22.0 kg',
      'amount': '₹1,980',
      'status': 'pending',
      'method': 'Direct Bank Payout',
      'date': '03 Sep 2026',
      'recycler': 'Sahyadri E-Waste Recyclers',
    },
    {
      'lotId': 'DH-2026-0818',
      'material': 'Cable (तांबा केबल)',
      'weight': '35.0 kg',
      'amount': '₹8,575',
      'status': 'paid',
      'method': 'Digital UPI',
      'date': '01 Sep 2026',
      'recycler': 'EcoMetals Green Yard',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _samplePayments.where((p) => p['status'] == _activeTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('भुगतान स्थिति (Payment Status)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Toggle
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('प्राप्त भुगतान (Paid)')),
                    selected: _activeTab == 'paid',
                    selectedColor: const Color(0xFF0F6B6B),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    onSelected: (_) => setState(() => _activeTab = 'paid'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('बकाया (Pending)')),
                    selected: _activeTab == 'pending',
                    selectedColor: const Color(0xFFE0A526),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _activeTab == 'pending' ? Colors.black : Colors.white,
                    ),
                    onSelected: (_) => setState(() => _activeTab = 'pending'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = filtered[index];

                  return Container(
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
                              p['lotId'],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.tealAccent, fontFamily: 'monospace'),
                            ),
                            Text(p['date'], style: const TextStyle(fontSize: 11, color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['material'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text('${p["weight"]} · ${p["recycler"]}', style: const TextStyle(fontSize: 11, color: Colors.white60)),
                              ],
                            ),
                            Text(
                              p['amount'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFE0A526)),
                            ),
                          ],
                        ),
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
}
