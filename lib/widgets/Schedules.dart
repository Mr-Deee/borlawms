import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Model/ScheduleRequest.dart';
import '../Model/schedule_requests_viewmodel.dart';
import '../widgets/SubscriptionNavigation.dart' show NavigationPage;

class ScheduleRequestsScreen extends StatelessWidget {
  const ScheduleRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleRequestsViewModel()..loadRequests(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scheduled Requests'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<ScheduleRequestsViewModel>().loadRequests(),
            ),
          ],
        ),
        body: const _RequestList(),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList();

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
      return const Center(child: Text('No scheduled requests found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.requests.length,
      itemBuilder: (context, index) {
        final request = viewModel.requests[index];
        return _RequestCard(request: request);
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ScheduledRequest request;

  const _RequestCard({required this.request});

  void _showNavigationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Begin Trip"),
        content: Text(
          "Start navigation to ${request.clientName}'s location?",
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
                    clientLat: request.locationLat ?? 0.0,
                    clientLng: request.locationLng ?? 0.0,
                    clientName: request.clientName,
                  ),
                ),
              );
            },
            child: const Text("Start Trip"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ScheduleRequestsViewModel>();
    final isUpcoming = request.scheduledTime.isAfter(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: isUpcoming ? Colors.green[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUpcoming)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('UPCOMING', style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                    )),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.clientName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (request.locationLat != null && request.locationLng != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => _showNavigationDialog(context),
                        child: const Text(
                          "Start Trip",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Cancellation'),
                            content: const Text('Are you sure you want to cancel this request?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await viewModel.cancelRequest(request.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request cancelled')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(Icons.phone, request.clientPhone),
            _buildInfoRow(Icons.calendar_today,
                'Scheduled: ${request.formattedScheduledTime}'),
            _buildInfoRow(Icons.access_time,
                'Created: ${request.formattedCreatedAt}'),
            _buildInfoRow(Icons.location_on, request.location),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}