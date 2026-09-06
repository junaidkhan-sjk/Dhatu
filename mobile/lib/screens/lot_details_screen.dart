import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/core/dhatu_card.dart';

class LotDetailsScreen extends StatelessWidget {
  const LotDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    // Timeline mockup
    final List<Map<String, dynamic>> timeline = [
      {'status': 'Created', 'time': '10:00 AM, 12 May', 'done': true},
      {'status': 'Estimated', 'time': '10:01 AM, 12 May', 'done': true},
      {'status': 'Matched (GreenTech)', 'time': '10:05 AM, 12 May', 'done': true},
      {'status': 'Accepted', 'time': '10:15 AM, 12 May', 'done': true},
      {'status': 'Handed Over', 'time': '11:30 AM, 12 May', 'done': true},
      {'status': 'Confirmed', 'time': '11:32 AM, 12 May', 'done': true},
      {'status': 'Paid', 'time': 'Pending...', 'done': false},
    ];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Lot #DHT-1004', style: TextStyle(color: theme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DhatuCard(
                child: Column(
                  children: [
                    Text('Mixed Copper Wires', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textColor)),
                    const SizedBox(height: 8),
                    Text('Final Weight: 5.2 kg', style: TextStyle(fontSize: 16, color: theme.subtitleColor)),
                    const Divider(height: 32),
                    Text('Total Earned', style: TextStyle(fontSize: 14, color: theme.subtitleColor)),
                    Text('₹1,404', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: timeline.length,
                  itemBuilder: (context, index) {
                    final item = timeline[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item['done'] ? theme.primaryColor : Colors.grey,
                              ),
                              child: Icon(Icons.check, size: 14, color: theme.onPrimaryColor),
                            ),
                            if (index != timeline.length - 1)
                              Container(
                                width: 2,
                                height: 40,
                                color: item['done'] ? theme.primaryColor : Colors.grey,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['status'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: item['done'] ? FontWeight.bold : FontWeight.normal,
                                  color: theme.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(item['time'], style: TextStyle(color: theme.subtitleColor, fontSize: 12)),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
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
