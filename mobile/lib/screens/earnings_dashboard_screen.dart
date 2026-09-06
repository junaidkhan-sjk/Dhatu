import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import 'transaction_history_screen.dart';

class EarningsDashboardScreen extends StatelessWidget {
  const EarningsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('My Earnings', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4 Stat Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard(theme, 'Today', '₹1,404')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(theme, 'This Week', '₹4,250')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard(theme, 'Pending', '₹0', isHighlight: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(theme, 'Total Lots', '12')),
                ],
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                      );
                    },
                    child: Text('View All', style: TextStyle(color: theme.primaryColor)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // Mock Recent Transactions
              _buildTransactionRow(theme, 'Mixed Copper Wires', '₹1,404', 'Today', true),
              _buildTransactionRow(theme, 'Aluminium Cans', '₹350', 'Yesterday', true),
              _buildTransactionRow(theme, 'Old Batteries', '₹800', '12 May', false), // Offline saved state
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeManager theme, String title, String value, {bool isHighlight = false}) {
    return DhatuCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: theme.subtitleColor, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value, 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: isHighlight ? Colors.orange : theme.textColor
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(ThemeManager theme, String title, String amount, String date, bool isSynced) {
    return DhatuCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSynced ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSynced ? Icons.cloud_done : Icons.cloud_off, 
              color: isSynced ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor)),
                Text(date, style: TextStyle(fontSize: 12, color: theme.subtitleColor)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16)),
        ],
      ),
    );
  }
}
