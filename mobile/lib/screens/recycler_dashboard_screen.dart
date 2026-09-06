import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';
import '../widgets/core/dhatu_button.dart';

class RecyclerDashboardScreen extends StatelessWidget {
  const RecyclerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    // Mock incoming lots
    final List<Map<String, dynamic>> incomingLots = [
      {'collector': 'Raju K.', 'material': 'Copper Wires', 'weight': '5.0 kg', 'distance': '2.5 km', 'time': '10 mins ago'},
      {'collector': 'Suresh', 'material': 'Aluminium', 'weight': '12.0 kg', 'distance': '4.1 km', 'time': '1 hour ago'},
    ];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Recycler Dashboard', style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: theme.textColor),
            onPressed: () {},
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
              // Profile Setup / Status
              DhatuCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GreenTech Recyclers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('Accepting New Lots', style: TextStyle(color: theme.subtitleColor)),
                          ],
                        )
                      ],
                    ),
                    Switch(
                      value: true,
                      onChanged: (v) {},
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Incoming Lots',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: incomingLots.length,
                  itemBuilder: (context, index) {
                    final lot = incomingLots[index];
                    return DhatuCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(lot['material'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
                              Text(lot['weight'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('From: ${lot['collector']} (${lot['distance']})', style: TextStyle(color: theme.subtitleColor)),
                              Text(lot['time'], style: TextStyle(color: theme.subtitleColor, fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: DhatuButton(
                                  text: 'Reject',
                                  isPrimary: false,
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DhatuButton(
                                  text: 'Quote',
                                  isPrimary: true,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
