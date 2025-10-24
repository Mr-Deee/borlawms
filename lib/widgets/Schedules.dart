import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../Model/ScheduleRequest.dart';
import '../Model/schedule_requests_viewmodel.dart';
import '../widgets/SubscriptionNavigation.dart' show NavigationPage;

class SubscriptionAndSchedulePage extends StatefulWidget {
  const SubscriptionAndSchedulePage({super.key});

  @override
  State<SubscriptionAndSchedulePage> createState() => _SubscriptionAndSchedulePageState();
}

class _SubscriptionAndSchedulePageState extends State<SubscriptionAndSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _subRef = FirebaseDatabase.instance.ref('subscriptions');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAccessDialog(Map<String, dynamic> sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Begin Navigation"),
        content: Text("Do you want to begin navigation to ${sub['name']}'s house?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NavigationPage(
                    clientLat: sub['lat'],
                    clientLng: sub['lng'],
                    clientName: sub['name'],
                    clientToken: '', // you can integrate your token logic here
                  ),
                ),
              );
            },
            child: const Text("Start PickUp"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleRequestsViewModel()..loadRequests(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Subscriptions & Schedules"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.subscriptions), text: "Subscriptions"),
              Tab(icon: Icon(Icons.schedule), text: "Schedules"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // --- TAB 1: Subscriptions ---
            StreamBuilder<DatabaseEvent>(
              stream: _subRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No subscriptions yet."));
                }

                final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                final subs = data.entries.map((entry) {
                  final subData = Map<String, dynamic>.from(entry.value);
                  final location = subData['location'] is Map
                      ? Map<String, dynamic>.from(subData['location'])
                      : null;

                  return {
                    'id': entry.key,
                    'name': subData['name'] ?? '',
                    'email': subData['email'] ?? '',
                    'phone': subData['phone'] ?? '',
                    'lat': location?['lat']?.toDouble() ?? 0.0,
                    'lng': location?['lng']?.toDouble() ?? 0.0,
                    'date': subData['date'] ?? '',
                    'time': subData['time'] ?? '',
                  };
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subs.length,
                  itemBuilder: (context, index) {
                    var sub = subs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: ListTile(
                        title: Text(sub['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sub['email']),
                            Text(sub['phone']),
                            Text('Date: ${sub['date']}  Time: ${sub['time']}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _showAccessDialog(sub),
                          child: const Text("Start PickUp"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // --- TAB 2: Scheduled Requests ---
            const _ScheduleRequestList(),
          ],
        ),
      ),
    );
  }
}

// 🧩 Schedule List (unchanged core logic)
class _ScheduleRequestList extends StatelessWidget {
  const _ScheduleRequestList();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScheduleRequestsViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null) {
      return Center(child: Text(viewModel.error!));
    }
    if (viewModel.requests.isEmpty) {
      return const Center(child: Text("No scheduled requests found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.requests.length,
      itemBuilder: (context, index) {
        final req = viewModel.requests[index];
        final isUpcoming = req.scheduledTime.isAfter(DateTime.now());
        return Card(
          color: isUpcoming ? Colors.green[50] : null,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(req.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.clientPhone),
                Text('Scheduled: ${req.formattedScheduledTime}'),
                Text('Created: ${req.formattedCreatedAt}'),
                Text('Location: ${req.location}'),
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NavigationPage(
                      clientLat: req.locationLat ?? 0.0,
                      clientLng: req.locationLng ?? 0.0,
                      clientName: req.clientName,
                      clientToken: '',
                    ),
                  ),
                );
              },
              child: const Text("Start Trip"),
            ),
          ),
        );
      },
    );
  }
}
