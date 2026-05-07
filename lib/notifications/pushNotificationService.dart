import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:io' show Platform;
import '../Assistant/assistantmethods.dart';
import '../configMaps.dart';
import '../main.dart';
import '../pages/clientDetails.dart';
import 'notificationDialog.dart';

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    print("Initializing push notifications...");

    try {
      print("Step 1: Requesting notification permissions...");
      await _requestNotificationPermissions();
      print("Step 1 Complete: Permissions requested.");
    } catch (e) {
      print("Error during notification permission request: $e");
    }

    try {
      print("Step 2: Setting up foreground message listener...");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.messageId}');
        if (context.mounted) {
          _handleMessage(message, context);
        }
      });
      print("Step 2 Complete: Foreground listener set.");
    } catch (e) {
      print("Error setting up onMessage listener: $e");
    }

    try {
      print("Step 3: Setting up background message tap listener...");
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.messageId}');
        if (context.mounted) {
          _handleMessage(message, context);
        }
      });
      print("Step 3 Complete: onMessageOpenedApp listener set.");
    } catch (e) {
      print("Error setting up onMessageOpenedApp listener: $e");
    }

    try {
      print("Step 4: Checking for initial notification...");
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('Initial notification found: ${initialMessage.messageId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _handleMessage(initialMessage, context);
          }
        });
      } else {
        print("No initial notification found.");
      }
      print("Step 4 Complete: Initial message check done.");
    } catch (e) {
      print("Error fetching initial message: $e");
    }

    try {
      print("Step 5: Getting FCM token and subscribing to topics...");
      await getToken();
      print("Step 5 Complete: Token retrieved and topics subscribed.");
    } catch (e) {
      print("Error getting token or subscribing to topics: $e");
    }

    print("Push notification initialization complete.");
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      if (Platform.isIOS) {
        print("Requesting iOS notification permissions...");

        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        print("Foreground presentation options set.");

        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        print('iOS Notification permission status: ${settings.authorizationStatus}');
      } else if (Platform.isAndroid) {
        // For Android 13+, request permission
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        print('Android Notification permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }

  Future<void> getToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        print("FCM Token: $token");

        try {
          await WMSDBtoken.child("token").set(token);
          print("Token stored successfully");
        } catch (e) {
          print("Error storing token: $e");
        }

        try {
          await Future.wait([
            messaging.subscribeToTopic("alldrivers"),
            messaging.subscribeToTopic("allusers")
          ]);
          print("Subscribed to topics successfully");
        } catch (e) {
          print("Error subscribing to topics: $e");
        }
      } else {
        print("Failed to get FCM token");
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  String getRideRequestId(Map<String, dynamic> message) {
    try {
      String rideRequestId = message['wms_request_id'] ??
          message['request_id'] ??
          message['rideRequestId'] ?? "";
      print("Ride Request ID: $rideRequestId");
      return rideRequestId;
    } catch (e) {
      print("Error getting ride request ID: $e");
      return "";
    }
  }

  void _handleMessage(RemoteMessage message, BuildContext context) {
    try {
      if (message.data.isEmpty) {
        print("⚠️ Empty message data received");
        return;
      }

      final messageType = message.data['type'] ?? 'immediate';
      print("📩 Message type: $messageType");

      if (messageType == 'scheduled') {
        _handleScheduledRequest(message, context);
      } else {
        final rideRequestId = getRideRequestId(message.data);
        if (rideRequestId.isNotEmpty) {
          retrieveRideRequestInfo(rideRequestId, context);
        } else {
          print("⚠️ No ride request ID found in message");
        }
      }
    } catch (e, stack) {
      print("❌ Error handling message: $e");
      print(stack);
    }
  }






  void _handleScheduledRequest(RemoteMessage message, BuildContext context) async {
    if (!context.mounted) {
      print("Context not mounted, cannot show dialog");
      return;
    }

    try {
      final String wmsRequestId = message.data['wms_request_id'] ??
          message.data['request_id'] ??
          '';

      if (wmsRequestId.isEmpty) {
        print("⚠️ Missing request ID in notification data");
        return;
      }

      print("📦 Fetching scheduled request details for ID: $wmsRequestId");

      // Try multiple database paths
      DatabaseEvent? event;
      DatabaseReference ref;

      // Try the ScheduledRequest path first
      try {
        ref = FirebaseDatabase.instance
            .ref()
            .child("Request")
            .child("ScheduledRequest")
            .child(wmsRequestId);

        event = (await ref.get()) as DatabaseEvent?;

        if (!event!.snapshot.exists) {
          // Try alternative path
          ref = FirebaseDatabase.instance
              .ref()
              .child("Request")
              .child(wmsRequestId);
          event = (await ref.get()) as DatabaseEvent?;
        }
      } catch (e) {
        print("Error accessing database: $e");
        return;
      }

      if (event == null || !event.snapshot.exists) {
        print("❌ No scheduled request found for ID $wmsRequestId");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request not found')),
          );
        }
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      // Safely extract data with fallbacks
      final clientName = data['client_name'] ?? data['RequesterName'] ?? 'Unknown';
      final requestId = data['Requesterid'] ?? data['client_id'] ?? 'Unknown';
      final requeststreamId = data['request_id'] ?? wmsRequestId;
      final clientPhone = data['client_phone'] ?? data['phone'] ?? 'N/A';
      final scheduledTime = data['dateTime'] ?? data['scheduled_time'] ?? 'Not set';

      // Safely parse coordinates
      double pickupLat = 0.0;
      double pickupLng = 0.0;

      if (data['latitude'] != null && data['longitude'] != null) {
        try {
          pickupLat = (data['latitude'] as num).toDouble();
          pickupLng = (data['longitude'] as num).toDouble();
        } catch (e) {
          print("Error parsing coordinates: $e");
        }
      } else if (data['client_Coordinates'] != null) {
        try {
          final coords = data['client_Coordinates'] as Map;
          pickupLat = (coords['latitude'] as num).toDouble();
          pickupLng = (coords['longitude'] as num).toDouble();
        } catch (e) {
          print("Error parsing nested coordinates: $e");
        }
      }

      final locationName = data['location_name'] ??
          data['Client_address'] ??
          'Unknown location';

      if (!context.mounted) return;

      // Show the request details in a dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '🚗 Scheduled Pickup Request',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: $clientName'),
                const SizedBox(height: 8),
                Text('Phone: $clientPhone'),
                const SizedBox(height: 8),
                Text('Pickup: $locationName'),
                const SizedBox(height: 8),
                Text('Scheduled Time: $scheduledTime'),
                const SizedBox(height: 20),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FirebaseDatabase.instance
                      .ref('Request/ScheduledRequest/$requeststreamId/status')
                      .set('declined')
                      .catchError((e) => print("Error updating status: $e"));
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Decline',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await _acceptScheduledRequest(
                    dialogContext,
                    context,
                    requeststreamId,
                    clientName,
                    clientPhone,
                    pickupLat,
                    pickupLng,
                    locationName,
                    scheduledTime,
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e, stack) {
      print("❌ Error in _handleScheduledRequest: $e");
      print(stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading request: $e')),
        );
      }
    }
  }



  Future<void> _acceptScheduledRequest(
      BuildContext dialogContext,
      BuildContext parentContext,
      String requestId,
      String clientName,
      String clientPhone,
      double pickupLat,
      double pickupLng,
      String locationName,
      String scheduledTime,
      ) async {
    try {
      // Update status to accepted
      await FirebaseDatabase.instance
          .ref('Request/ScheduledRequest/$requestId/status')
          .set('accepted');

      // Get client token and send notification
      final event = await clients.once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? clientMap =
        snapshot.value as Map<dynamic, dynamic>?;

        if (clientMap != null) {
          for (var entry in clientMap.entries) {
            final clientData = entry.value as Map<dynamic, dynamic>?;
            if (clientData == null) continue;

            final token = clientData["token"];
            if (token != null && token.toString().trim().isNotEmpty) {
              await AssistantMethod.sendNotificationToClient(
                token.toString(),
                parentContext,
                requestId,
              );
              break;
            }
          }
        }
      }

      // Close the dialog
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      // Show success message
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('Request accepted! Client notified.')),
        );
      }
    } catch (e) {
      print("Error accepting request: $e");
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('Failed to accept request.')),
        );
      }
    }
  }

  Future<void> retrieveRideRequestInfo(String artisanRequestId, BuildContext context) async {
    try {
      DatabaseEvent event = await clientRequestRef.child(artisanRequestId).once();

      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;

        double pickUpLocationLat = 0.0;
        double pickUpLocationLng = 0.0;

        if (map['client_Coordinates'] != null) {
          final coords = map['client_Coordinates'] as Map;
          pickUpLocationLat = double.parse(coords['latitude'].toString());
          pickUpLocationLng = double.parse(coords['longitude'].toString());
        }

        double dropOffLocationLat = pickUpLocationLat;
        double dropOffLocationLng = pickUpLocationLng;

        String clientAddress = map['Client_address']?.toString() ?? '';
        String finalClientaddress = map['finalClient_address']?.toString() ?? '';
        String paymentMethod = map['payment_method']?.toString() ?? '';
        String client_name = map["client_name"]?.toString() ?? '';
        String client_phone = map["client_phone"]?.toString() ?? '';

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

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => NotificationDialog(
              clientDetails: clientDetails,
            ),
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