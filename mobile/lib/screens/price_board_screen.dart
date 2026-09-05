import 'package:flutter/material.dart';
import '../models/price_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/localization_service.dart';
import 'price_history_screen.dart';

class PriceBoardScreen extends StatefulWidget {
  const PriceBoardScreen({super.key});

  @override
  State<PriceBoardScreen> createState() => _PriceBoardScreenState();
}

class _PriceBoardScreenState extends State<PriceBoardScreen> {
  List<PriceBoardCard> _cards = [];
  String _selectedCategory = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  void _fetchPrices() async {
    setState(() => _loading = true);
    final board = await ApiService().getPriceBoard();
    setState(() {
      _cards = board;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final categories = ['All', 'PCB', 'Battery', 'Cable', 'CRT', 'Motor'];

    final filtered = _selectedCategory == 'All'
        ? _cards
        : _cards.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('पारदर्शी भाव सूची (Price Board)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              final text = 'आज के मुख्य दर: सर्किट बोर्ड 135 रुपये, तांबा केबल 240 रुपये, बैटरी 85 रुपये प्रति किलो।';
              AudioService().speak(text, lang: loc.currentLanguage);
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFE0A526)),
            tooltip: 'Listen to All Rates',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0F172A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat == 'All' ? 'सभी सामग्री (All)' : cat),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                      backgroundColor: const Color(0xFF1E293B),
                      selectedColor: const Color(0xFFE0A526),
                      checkmarkColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE0A526)))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filtered[index];

                      return Container(
                        padding: const EdgeInsets.all(18),
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
                                  item.category,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.trendPercent,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Text(
                                  '₹${item.currentRateInrPerKg.toInt()}',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFE0A526), fontFamily: 'monospace'),
                                ),
                                const Text(
                                  ' /kg',
                                  style: TextStyle(fontSize: 14, color: Colors.white60),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    final text = '${item.category} का आज का दर ${item.currentRateInrPerKg.toInt()} रुपये प्रति किलो है।';
                                    AudioService().speak(text, lang: loc.currentLanguage);
                                  },
                                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFE0A526)),
                                ),
                              ],
                            ),

                            Text(
                              'बाज़ार सीमा: ₹${item.minRateInrPerKg.toInt()} – ₹${item.maxRateInrPerKg.toInt()} /kg',
                              style: const TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                            const SizedBox(height: 12),

                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PriceHistoryScreen(category: item.category),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'इतिहास व रुझान देखें (View History & Chart)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.tealAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
