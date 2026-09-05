import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'digital_handover_screen.dart';

class RecyclerOfferScreen extends StatefulWidget {
  final String lotId;
  final String recyclerName;
  final double offeredRate;
  final double totalEstPrice;

  const RecyclerOfferScreen({
    super.key,
    required this.lotId,
    required this.recyclerName,
    required this.offeredRate,
    required this.totalEstPrice,
  });

  @override
  State<RecyclerOfferScreen> createState() => _RecyclerOfferScreenState();
}

class _RecyclerOfferScreenState extends State<RecyclerOfferScreen> {
  bool _loading = false;

  void _acceptOffer() async {
    setState(() => _loading = true);
    await ApiService().acceptOffer(widget.lotId);
    setState(() => _loading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DigitalHandoverScreen(
            lotId: widget.lotId,
            recyclerName: widget.recyclerName,
            agreedPrice: widget.totalEstPrice,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('रीसायकलर ऑफर (Recycler Offer)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0A526), width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F6B6B).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'लॉट ID: ${widget.lotId}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.tealAccent, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.recyclerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text('कुल प्रस्तावित राशि (Total Offered Amount)', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${widget.totalEstPrice.toInt()}',
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFFE0A526)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${widget.offeredRate.toInt()} प्रति किलो (per kg rate)',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Spacer(),

            if (_loading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFE0A526)))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _acceptOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F6B6B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('ऑफर स्वीकार करें (Accept Offer) ✓', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('अस्वीकार करें (Decline)', style: TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
