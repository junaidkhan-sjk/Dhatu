import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import 'recycler_offer_screen.dart';

class RecyclerMatchingScreen extends StatelessWidget {
  const RecyclerMatchingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    // Mock recyclers with distinct authorization statuses
    final List<Map<String, dynamic>> recyclers = [
      {'name': 'GreenTech Recyclers', 'price': '₹1,350', 'distance': '2.5 km', 'pickup': true, 'authStatus': 'authorized'},
      {'name': 'EcoScrap India', 'price': '₹1,400', 'distance': '4.1 km', 'pickup': false, 'authStatus': 'pending'},
      {'name': 'Local Kabaadi', 'price': '₹1,250', 'distance': '0.8 km', 'pickup': true, 'authStatus': 'revoked'},
    ];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Nearby Buyers', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: recyclers.length,
          itemBuilder: (context, index) {
            final r = recyclers[index];
            final status = r['authStatus'];
            
            Color statusColor;
            IconData statusIcon;
            String statusText;
            
            if (status == 'authorized') {
              statusColor = Colors.green;
              statusIcon = Icons.verified_rounded;
              statusText = 'Verified / अधिकृत';
            } else if (status == 'pending') {
              statusColor = Colors.orange;
              statusIcon = Icons.hourglass_empty_rounded;
              statusText = 'Pending / लंबित';
            } else {
              statusColor = Colors.red;
              statusIcon = Icons.cancel_rounded;
              statusText = 'Revoked / रद्द';
            }

            return DhatuCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecyclerOfferScreen()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          r['name'],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offer: ${r['price']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.primaryColor),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: theme.subtitleColor),
                          const SizedBox(width: 4),
                          Text(r['distance'], style: TextStyle(color: theme.subtitleColor)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (r['pickup'])
                        Chip(
                          label: const Text('Free Pickup'),
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(color: theme.primaryColor, fontSize: 12),
                        )
                      else
                        Chip(
                          label: const Text('Drop-off Only'),
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
