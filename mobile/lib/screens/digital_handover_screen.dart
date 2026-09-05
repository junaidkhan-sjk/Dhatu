import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'handover_confirmation_screen.dart';

class DigitalHandoverScreen extends StatefulWidget {
  final String lotId;
  final String recyclerName;
  final double agreedPrice;

  const DigitalHandoverScreen({
    super.key,
    required this.lotId,
    required this.recyclerName,
    required this.agreedPrice,
  });

  @override
  State<DigitalHandoverScreen> createState() => _DigitalHandoverScreenState();
}

class _DigitalHandoverScreenState extends State<DigitalHandoverScreen> {
  double _finalWeightKg = 12.5;
  bool _photoCaptured = true;
  bool _submitting = false;

  void _submitHandover() async {
    setState(() => _submitting = true);
    await ApiService().handoverLot(widget.lotId, _finalWeightKg);
    setState(() => _submitting = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HandoverConfirmationScreen(
            lotId: widget.lotId,
            referenceNumber: 'REF-${widget.lotId.replaceAll('DH-', '')}',
            recyclerName: widget.recyclerName,
            finalPrice: widget.agreedPrice,
            weightKg: _finalWeightKg,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('डिजिटल हैंडओवर (Digital Handover)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'सामग्री सुपुर्दगी व कांटा सत्यापन\nHandover & Scale Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'रीसायकलर के कांटे पर तौला गया अंतिम वजन दर्ज करें:',
              style: TextStyle(fontSize: 13, color: Colors.white60),
            ),
            const SizedBox(height: 24),

            // Handover Photo Proof Box
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F6B6B), width: 1.5),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _photoCaptured ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                      size: 48,
                      color: const Color(0xFFE0A526),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _photoCaptured ? 'हैंडओवर फोटो संलग्न (Photo Verified)' : 'हैंडओवर फोटो खींचें',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weight Confirmation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('कांटे का अंतिम वजन (Final Scale Weight)', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 8),
                  Text(
                    '$_finalWeightKg kg',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFFE0A526), fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            if (_submitting)
              const Center(child: CircularProgressIndicator(color: Color(0xFFE0A526)))
            else
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitHandover,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6B6B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('हैंडओवर पुष्टि करें (Confirm Handover) ✓', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
