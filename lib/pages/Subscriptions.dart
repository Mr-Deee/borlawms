import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/SubscriptionNavigation.dart' show NavigationPage;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAccessDialog(Map<String, dynamic> sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Begin Navigation"),
        content: Text(
          "Do you want to begin navigation to ${sub['name']}'s house?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NavigationPage(
                    clientLat: sub['lat'],
                    clientLng: sub['lng'], clientName: sub['name'],
                  ),
                ),
              );
            },
            child: const Text("Begin"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('subscriptions');

    return Scaffold(
      appBar: AppBar(title: const Text("Subscriptions")),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No subscriptions yet."));
          }

          // Convert Realtime DB snapshot to Map
          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final subscriptions = data.entries.map((entry) {
            final subData = Map<String, dynamic>.from(entry.value);

            // Handle nested location data
            final location = subData['location'] is Map ? Map<String, dynamic>.from(subData['location'])
                : null;

            return {
              'id': entry.key,
              'name': subData['name'] ?? '',
              'email': subData['email'] ?? '',
              'phone': subData['phone'] ?? '',
              'lat': location?['lat']?.toDouble() ?? 0.0,  // Convert to double if needed
              'lng': location?['lng']?.toDouble() ?? 0.0,
              // Include other fields if needed
              'date': subData['date'] ?? '',
              'time': subData['time'] ?? '',
              'timestamp': subData['timestamp'] ?? 0,
            };
          }).toList();

          return ListView.builder(
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              var sub = subscriptions[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  sub['email'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  sub['phone'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 2,
                        ),
                        onPressed: () => _showAccessDialog(sub),
                        child: const Text(
                          "Start PickUp",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );            },
          );
        },
      ),
    );
  }

}