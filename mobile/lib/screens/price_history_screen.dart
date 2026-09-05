import 'package:flutter/material.dart';
import '../models/price_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/localization_service.dart';

class PriceHistoryScreen extends StatefulWidget {
  final String category;
  const PriceHistoryScreen({super.key, required this.category});

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  String _range = '30d'; // 7d, 30d, 90d
  List<PriceHistoryPoint> _points = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    setState(() => _loading = true);
    final pts = await ApiService().getPriceHistory(widget.category, range: _range);
    setState(() {
      _points = pts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.category} भाव इतिहास (Price History)', style: const TextStyle(fontSize: 16, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              final text = 'पिछले ${_range == "7d" ? "सात" : _range == "90d" ? "नब्बे" : "तीस"} दिनों में ${widget.category} का भाव स्थिर और बढ़ता हुआ रहा है।';
              AudioService().speak(text, lang: loc.currentLanguage);
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFE0A526)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Range Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['7d', '30d', '90d'].map((r) {
                final isSel = _range == r;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(r == '7d' ? '7 दिन' : r == '90d' ? '90 दिन' : '30 दिन'),
                    selected: isSel,
                    selectedColor: const Color(0xFFE0A526),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : Colors.white,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _range = r);
                        _fetchHistory();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Visual Chart Representation Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text('ऐतिहासिक दर रुझान (Price Trend Graph)', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Simple Bar Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _points.map((p) {
                      final height = (p.priceInr - 20) * 1.5;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('₹${p.priceInr.toInt()}', style: const TextStyle(fontSize: 10, color: Color(0xFFE0A526), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: height.clamp(40.0, 160.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F6B6B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(p.date, style: const TextStyle(fontSize: 9, color: Colors.white54)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
