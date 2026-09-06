import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import 'settings_screen.dart';
import 'create_lot_screen.dart';
import 'price_board_screen.dart';
import 'earnings_dashboard_screen.dart';
import 'transaction_history_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Dhatu', style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.textColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Namaste, Collector!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to do today?',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.subtitleColor,
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildActionCard(
                      context, 
                      theme, 
                      'New Lot', 
                      Icons.add_a_photo, 
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateLotScreen()),
                        );
                      }
                    ),
                    _buildActionCard(
                      context, 
                      theme, 
                      'Price Board', 
                      Icons.currency_rupee, 
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PriceBoardScreen()),
                        );
                      }
                    ),
                    _buildActionCard(
                      context, 
                      theme, 
                      'My Earnings', 
                      Icons.account_balance_wallet, 
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EarningsDashboardScreen()),
                        );
                      }
                    ),
                    _buildActionCard(
                      context, 
                      theme, 
                      'My Lots', 
                      Icons.inventory_2, 
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, ThemeManager theme, String title, IconData icon, VoidCallback onTap) {
    return DhatuCard(
      margin: EdgeInsets.zero, // handled by grid spacing
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Audio icon placeholder
          Icon(
            Icons.volume_up,
            size: 20,
            color: theme.subtitleColor,
          )
        ],
      ),
    );
  }
}
