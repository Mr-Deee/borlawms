import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../Model/schedule_requests_viewmodel.dart';
import '../widgets/SubscriptionNavigation.dart' show NavigationPage;

class SubscriptionAndSchedulePage extends StatefulWidget {
  const SubscriptionAndSchedulePage({super.key});

  @override
  State<SubscriptionAndSchedulePage> createState() =>
      _SubscriptionAndSchedulePageState();
}

class _SubscriptionAndSchedulePageState
    extends State<SubscriptionAndSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _subRef =
  FirebaseDatabase.instance.ref('subscriptions');

  List<Map<String, dynamic>> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 🔹 Listen once and cache results
    _subRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) {
        setState(() {
          _subscriptions = [];
          _isLoading = false;
        });
        return;
      }

      final rawData = Map<dynamic, dynamic>.from(value as Map);
      final data = Map<String, dynamic>.from(rawData.map((key, value) {
        return MapEntry(key.toString(),
            Map<String, dynamic>.from(value as Map));
      }));

      final subs = data.entries.map((entry) {
        final subData = entry.value;
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

      setState(() {
        _subscriptions = subs;
        _isLoading = false;
      });
    });
  }

  Future<void> _reloadSubscriptions() async {
    setState(() => _isLoading = true);
    final snapshot = await _subRef.get();
    final value = snapshot.value;

    if (value == null) {
      setState(() {
        _subscriptions = [];
        _isLoading = false;
      });
      return;
    }

    final rawData = Map<dynamic, dynamic>.from(value as Map);
    final data = Map<String, dynamic>.from(rawData.map((key, value) {
      return MapEntry(key.toString(),
          Map<String, dynamic>.from(value as Map));
    }));

    final subs = data.entries.map((entry) {
      final subData = entry.value;
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

    setState(() {
      _subscriptions = subs;
      _isLoading = false;
    });
  }

  void _showAccessDialog(Map<String, dynamic> sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Begin Navigation",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Start navigation to ${sub['name']}'s location?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NavigationPage(
                    clientLat: sub['lat'],
                    clientLng: sub['lng'],
                    clientName: sub['name'],
                    clientToken: '',
                  ),
                ),
              );
            },
            child: const Text("Start Pickup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleRequestsViewModel()..loadRequests(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: const Text(
            "Subscription & Schedule",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                  icon: Icon(Icons.people_alt_outlined),
                  text: "Subscriptions"),
              Tab(
                  icon: Icon(Icons.calendar_month_outlined),
                  text: "Schedules"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // 🔹 Subscriptions tab (cached)
            RefreshIndicator(
              onRefresh: _reloadSubscriptions,
              color: Colors.green,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _subscriptions.isEmpty
                  ? const Center(child: Text("No subscriptions yet."))
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = _subscriptions[index];
                  return _buildGlassCard(
                    title: sub['name'],
                    subtitle: "${sub['email']}\n${sub['phone']}",
                    extra: "Date: ${sub['date']} • Time: ${sub['time']}",
                    icon: Icons.person_pin_circle_outlined,
                    onPressed: () => _showAccessDialog(sub),
                    buttonLabel: "Start Pickup",
                  );
                },
              ),
            ),

            // 🔹 Schedule tab
            const _ScheduleRequestList(),
          ],
        ),
      ),
    );
  }

  // 💎 Glass Card UI
  Widget _buildGlassCard({
    required String title,
    required String subtitle,
    required String extra,
    required IconData icon,
    required VoidCallback onPressed,
    required String buttonLabel,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Icon(icon, color: Colors.green[700], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.3,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(extra,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onPressed,
                child: Text(buttonLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🧩 Schedules List
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUpcoming
                  ? [Colors.green.shade50, Colors.white]
                  : [Colors.grey.shade200, Colors.white],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Icon(
              isUpcoming
                  ? Icons.calendar_today_outlined
                  : Icons.history_toggle_off,
              color: isUpcoming ? Colors.green[700] : Colors.grey[600],
              size: 30,
            ),
            title: Text(req.clientName,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.clientPhone),
                Text('Scheduled: ${req.formattedScheduledTime}'),
                Text('Location: ${req.location}'),
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
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
              child: const Text("Start Trip", style: TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}
