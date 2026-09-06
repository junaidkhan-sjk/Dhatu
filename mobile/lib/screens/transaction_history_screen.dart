import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import 'lot_details_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('All Lots & Transactions', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          itemBuilder: (context, index) {
            // Mock data
            bool isSynced = index % 3 != 0; // Every 3rd item is offline
            String status = index == 0 ? 'Pending Payment' : 'Completed';
            Color statusColor = index == 0 ? Colors.orange : Colors.green;

            return DhatuCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LotDetailsScreen()),
                );
              },
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lot #DHT-10${index}4', style: TextStyle(color: theme.subtitleColor, fontSize: 12)),
                      Icon(
                        isSynced ? Icons.cloud_done : Icons.cloud_off, 
                        color: isSynced ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mixed Copper Wires',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor),
                      ),
                      Text('₹1,404', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('12 May 2026', style: TextStyle(color: theme.subtitleColor)),
                      Chip(
                        label: Text(status),
                        backgroundColor: statusColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
