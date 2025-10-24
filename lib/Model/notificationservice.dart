import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  static const String projectId = 'borlagh-2cc0d'; // 🔑 Replace with your Firebase Project ID
  static const String fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

  /// 🔹 Load service account and get an OAuth2 access token
  static Future<auth.AccessCredentials> _getAccessToken() async {
    final serviceAccountJson =
    await rootBundle.loadString('assets/firebase_service_account.json');
    final serviceAccount = json.decode(serviceAccountJson);
    final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final auth.AccessCredentials accessCredentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
      credentials,
      scopes,
      http.Client(),
    );
    print("✅ Access token acquired");
    return accessCredentials;
  }

  /// 🔹 Send push notification to a client
  static Future<void> sendNotificationToClient({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      print("📢 Preparing to send notification...");
      final credentials = await _getAccessToken();
      final accessToken = credentials.accessToken.data;

      // Build FCM message
      Map<String, dynamic> notification = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {}, // optional extra data
        }
      };

      print("➡️ Sending to token: $token");
      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(notification),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully");
      } else {
        print("❌ Failed to send. Status: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}
