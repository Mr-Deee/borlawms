import 'package:borlawms/Model/ScheduleRequest.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleRequestsViewModel with ChangeNotifier {
  final DatabaseReference _requestsRef =
  FirebaseDatabase.instance.ref().child("Request").child('ScheduledRequest');

  List<ScheduledRequest> _requests = [];
  bool _isLoading = true;
  String? _error;

  List<ScheduledRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadRequests() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _requestsRef.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        final now = DateTime.now();

        if (data == null) {
          _requests = [];
          _error = 'No scheduled requests found';
        } else {
          _requests = data.entries.map((entry) {
            return ScheduledRequest.fromMap(
              entry.key.toString(),
              entry.value as Map<dynamic, dynamic>,
            );
          })
              .where((request) => request.scheduledTime.isAfter(now) ||
              _isSameDay(request.scheduledTime, now))
              .toList()
            ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        }
      } catch (e) {
        _error = 'Failed to load requests: ${e.toString()}';
        _requests = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (e) {
      _error = 'Database error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _requestsRef.child(requestId).remove();
    } catch (e) {
      _error = 'Failed to cancel request: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }
}