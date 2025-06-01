import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import '../configMaps.dart';
import '../main.dart';
import '../pages/clientDetails.dart';
import 'notificationDialog.dart';

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    print("Initializing push notifications");

    // Request permissions (especially important for iOS)
    await _requestNotificationPermissions();

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received');
      _handleMessage(message, context);
    });

    // Set up background/opened app handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification');
      _handleMessage(message, context);
    });

    // Check for initial notification (app launched from terminated state)
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from terminated state via notification');
      _handleMessage(initialMessage, context);
    }

    // Get and save the FCM token
    await getToken();
  }

  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('Notification permissions granted: ${settings.authorizationStatus}');
    }
  }

  Future<void> getToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        await WMSDBtoken.child("token").set(token);

        // Subscribe to topics
        await Future.wait([
          messaging.subscribeToTopic("alldrivers"),
          messaging.subscribeToTopic("allusers")
        ]);
        print("Subscribed to topics successfully");
      } else {
        print("Failed to get FCM token");
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequestId = message['wms_request_id'] ?? "";
    print("Ride Request ID: $rideRequestId");
    return rideRequestId;
  }

  void _handleMessage(RemoteMessage message, BuildContext context) {
    try {
      if (message.data.isNotEmpty) {
        String rideRequestId = getRideRequestId(message.data);
        if (rideRequestId.isNotEmpty) {
          retrieveRideRequestInfo(rideRequestId, context);
        } else {
          print("No ride request ID found in message");
        }
      } else {
        print("Empty message data received");
      }
    } catch (e) {
      print("Error handling message: $e");
    }
  }

  Future<void> retrieveRideRequestInfo(String artisanRequestId, BuildContext context) async {
    try {
      DatabaseEvent event = await clientRequestRef.child(artisanRequestId).once();

      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;

        double pickUpLocationLat = double.parse(map['client_Coordinates']['latitude'].toString());
        double pickUpLocationLng = double.parse(map['client_Coordinates']['longitude'].toString());
        String clientAddress = map['Client_address'].toString();
        double dropOffLocationLat = double.parse(map['client_Coordinates']['latitude'].toString());
        double dropOffLocationLng = double.parse(map['client_Coordinates']['longitude'].toString());
        String finalClientaddress = map['finalClient_address'].toString();
        String paymentMethod = map['payment_method'].toString();
        String client_name = map["client_name"].toString();
        String client_phone = map["client_phone"].toString();

        Clientdetails clientDetails = Clientdetails();
        clientDetails.artisan_request_id = artisanRequestId;
        clientDetails.client_Address = clientAddress;
        clientDetails.finalClient_address = finalClientaddress;
        clientDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        clientDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        clientDetails.payment_method = paymentMethod;
        clientDetails.client_name = client_name;
        clientDetails.client_phone = client_phone;

        print("Client details received: ${clientDetails.client_Address}");

        // Show notification dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(clientDetails: clientDetails),
          );
        }
      } else {
        print("No data found for request ID: $artisanRequestId");
      }
    } catch (e) {
      print("Error retrieving ride request info: $e");
    }
  }
}