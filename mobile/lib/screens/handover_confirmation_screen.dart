import 'package:flutter/material.dart';
import 'main_shell.dart';

class HandoverConfirmationScreen extends StatelessWidget {
  final String lotId;
  final String referenceNumber;
  final String recyclerName;
  final double finalPrice;
  final double weightKg;

  const HandoverConfirmationScreen({
    super.key,
    required this.lotId,
    required this.referenceNumber,
    required this.recyclerName,
    required this.finalPrice,
    required this.weightKg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F6B6B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFFE0A526), size: 54),
              ),
              const SizedBox(height: 24),
              const Text(
                'हैंडओवर सफलतापूर्वक दर्ज हुआ!\nHandover Confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3),
              ),
              const SizedBox(height: 8),
              const Text(
                'सामग्री अधिकृत रीसायकलर को हस्तांतरित कर दी गई है।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 32),

              // Certified Digital Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF0F6B6B), width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('हैंडओवर संदर्भ क्रमांक (Ref ID):', referenceNumber, isHighlight: true),
                    const Divider(color: Colors.white12, height: 24),
                    _buildReceiptRow('लॉट ID (Lot ID):', lotId),
                    const SizedBox(height: 10),
                    _buildReceiptRow('अधिकृत रीसायकलर:', recyclerName),
                    const SizedBox(height: 10),
                    _buildReceiptRow('सत्यापित वजन:', '$weightKg kg'),
                    const SizedBox(height: 10),
                    _buildReceiptRow('भुगतान राशि (Amount):', '₹${finalPrice.toInt()}', isGold: true),
                  ],
                ),
              ),
              const Spacer(),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell(initialTabIndex: 3)), // Earnings tab
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6B6B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('कमाई देखें (Go to Earnings Dashboard) →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false, bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight || isGold ? 15 : 13,
            fontWeight: isHighlight || isGold ? FontWeight.bold : FontWeight.w500,
            color: isGold
                ? const Color(0xFFE0A526)
                : isHighlight
                    ? Colors.tealAccent
                    : Colors.white,
            fontFamily: isHighlight ? 'monospace' : null,
          ),
        ),
      ],
    );
  }
}
