import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String title;
  final String description;

  Request({
    required this.title,
    required this.description,
  });

  factory Request.fromDataSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Request(
      title: data['finalClient_address'] ?? '',
      description: data['client_phone'] ?? '',
    );
  }
}