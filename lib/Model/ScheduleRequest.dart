import 'package:intl/intl.dart';

class ScheduledRequest {
  final String id;
  final String clientPhone;
  final String requesterId;
  final String clientName;
  final DateTime createdAt;
  final DateTime scheduledTime;
  final String location;
  final double? locationLat;
  final double? locationLng;

  ScheduledRequest({
    required this.id,
    // ... existing parameters ...
    required this.locationLat,
    required this.locationLng,
    required this.clientPhone,
    required this.requesterId,
    required this.clientName,
    required this.createdAt,
    required this.scheduledTime,
    required this.location,
  });

  factory ScheduledRequest.fromMap(String id, Map<dynamic, dynamic> data) {
    return ScheduledRequest(
      id: id,
      clientPhone: data['client_phone']?.toString() ?? 'Not provided',
      requesterId: data['Requesterid']?.toString() ?? 'Unknown',
      clientName: data['client_name']?.toString() ?? 'Anonymous',
      createdAt: _parseDateTime(data['created_at']?.toString()),
      scheduledTime: _parseDateTime(data['dateTime']?.toString()),
      location: data['location']?.toString() ?? 'Location unknown',
      // ... existing mappings ...
      locationLat: _parseLocation(data['location'], 'lat'),
      locationLng: _parseLocation(data['location'], 'lng'),
    );
  }




  static double? _parseLocation(dynamic location, String coord) {
    if (location is Map) {
      final value = location[coord];
      if (value is num) return value.toDouble();
    }
    return null;
  }
  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null) return DateTime.now();

    try {
      if (dateString.contains('T')) {
        return DateTime.parse(dateString);
      }
      return DateFormat('yyyy-MM-dd HH:mm').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedScheduledTime {
    return DateFormat('MMM d, yyyy - h:mm a').format(scheduledTime);
  }

  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy - h:mm a').format(createdAt);
  }
}