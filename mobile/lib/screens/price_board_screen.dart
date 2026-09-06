import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';

class PriceBoardScreen extends StatelessWidget {
  const PriceBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    
    // Mock data for prices
    final List<Map<String, dynamic>> prices = [
      {'material': 'Copper (Mixed)', 'price': '₹250 - ₹280', 'trend': 'up'},
      {'material': 'Aluminium', 'price': '₹120 - ₹140', 'trend': 'stable'},
      {'material': 'Iron/Steel', 'price': '₹25 - ₹35', 'trend': 'down'},
      {'material': 'E-Waste (PCBs)', 'price': '₹400 - ₹600', 'trend': 'up'},
    ];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Today\'s Price Board', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: prices.length,
          itemBuilder: (context, index) {
            final item = prices[index];
            return DhatuCard(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.recycling, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['material'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Per Kg',
                          style: TextStyle(color: theme.subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['price'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        item['trend'] == 'up' ? Icons.trending_up : (item['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat),
                        color: item['trend'] == 'up' ? Colors.green : (item['trend'] == 'down' ? Colors.red : Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.volume_up, color: theme.subtitleColor), // Audio icon requirement
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
