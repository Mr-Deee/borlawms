import 'dart:async';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    print("🔔🔔🔔 INITIALIZING PUSH NOTIFICATIONS 🔔🔔🔔");

    // ✅ STEP 1: Check FCM Token
    try {
      String? token = await messaging.getToken();
      print("📱 FCM Token: $token");
      if (token == null || token.isEmpty) {
        print("❌ ERROR: No FCM token received!");
        return;
      }
    } catch (e) {
      print("❌ ERROR getting FCM token: $e");
      return;
    }

    // ✅ STEP 2: Request permissions
    try {
      print("📢 Requesting notification permissions...");
      await _requestNotificationPermissions();
    } catch (e) {
      print("❌ Error during notification permission request: $e");
    }

    // ✅ STEP 3: iOS foreground presentation
    if (Platform.isIOS) {
      try {
        print("📱 Setting iOS foreground presentation...");
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        print("✅ iOS foreground presentation set");
      } catch (e) {
        print("❌ Error setting iOS presentation: $e");
      }
    }

    // ✅ STEP 4: FOREGROUND MESSAGE LISTENER - WITH FULL DEBUG
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("✅✅✅ FOREGROUND NOTIFICATION RECEIVED! ✅✅✅");
      print("📨 Title: ${message.notification?.title}");
      print("📨 Body: ${message.notification?.body}");
      print("📨 Data: ${message.data}");
      print("📨 Message ID: ${message.messageId}");
      print("📨 Message Type: ${message.data['type']}");

      // ✅ ADD THIS - Check if navigatorKey is available
      print("🔑 Checking navigatorKey...");
      if (navigatorKey.currentContext == null) {
        print("❌ navigatorKey.currentContext is NULL!");
      } else {
        print("✅ navigatorKey.currentContext is available");
      }

      // ✅ WRAP EVERYTHING IN TRY-CATCH
      try {
        print("⏰ Attempting to show dialog...");

        // Show snackbar using navigatorKey
        if (navigatorKey.currentContext != null) {
          try {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(message.notification?.title ?? 'New Notification'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
            print("✅ Snackbar shown");
          } catch (e) {
            print("❌ Error showing snackbar: $e");
          }
        }

        // ✅ Use Future.delayed to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            print("⏰ Future.delayed triggered - showing dialog now!");
            _showNotificationDialogDirectly(message);
          } catch (e) {
            print("❌ Error in Future.delayed: $e");
          }
        });

        print("✅ Listener execution completed");
      } catch (e) {
        print("❌ CRITICAL ERROR in onMessage listener: $e");
        print("📚 Stack trace: ${StackTrace.current}");
      }
    });

    // ✅ STEP 5: BACKGROUND TAP LISTENER
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("✅ App opened from notification (user tapped banner)");
      print("📨 Title: ${message.notification?.title}");
      print("📨 Data: ${message.data}");

      Future.delayed(const Duration(milliseconds: 300), () {
        print("✅ Showing dialog from tap...");
        _showNotificationDialogDirectly(message);
      });
    });

    // ✅ STEP 6: Check initial message
    try {
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        print("✅ Initial message found (app opened from terminated)");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print("✅ Handling initial message...");
          _showNotificationDialogDirectly(initialMessage);
        });
      }
    } catch (e) {
      print("❌ Error getting initial message: $e");
    }

    // ✅ STEP 7: Store token and subscribe to topics
    try {
      await getToken();
    } catch (e) {
      print("Error getting token or subscribing to topics: $e");
    }

    print("🔔 Push notification initialization COMPLETE");
  }

  // ✅ Show dialog using GLOBAL NAVIGATOR KEY
  void _showNotificationDialogDirectly(RemoteMessage message) {
    print("🚀 _showNotificationDialogDirectly called");

    try {
      // Get the request ID from data
      final rideRequestId = message.data['wms_request_id'] ??
          message.data['request_id'] ??
          '';

      print("📩 Ride Request ID: $rideRequestId");

      if (rideRequestId.isEmpty) {
        print("❌ No request ID found, showing generic dialog");
        _showGenericDialog(message);
        return;
      }

      // Check if navigatorKey is available
      if (navigatorKey.currentContext == null) {
        print("❌ navigatorKey.currentContext is null, cannot show dialog");
        return;
      }

      // ✅ Show loading indicator
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // ✅ Fetch data and show dialog
      clientRequestRef.child(rideRequestId).once().then((event) {
        // Dismiss loading
        if (navigatorKey.currentContext != null) {
          Navigator.pop(navigatorKey.currentContext!);
        }

        if (event.snapshot.value != null) {
          final map = event.snapshot.value as Map<dynamic, dynamic>;
          print("📦 Request data found: $map");

          // Parse client details
          double pickUpLocationLat = 0.0;
          double pickUpLocationLng = 0.0;

          if (map['client_Coordinates'] != null) {
            final coords = map['client_Coordinates'] as Map;
            pickUpLocationLat = double.parse(coords['latitude'].toString());
            pickUpLocationLng = double.parse(coords['longitude'].toString());
          }

          String clientAddress = map['Client_address']?.toString() ?? '';
          String finalClientaddress = map['finalClient_address']?.toString() ?? '';
          String paymentMethod = map['payment_method']?.toString() ?? '';
          String client_name = map["client_name"]?.toString() ?? '';
          String client_phone = map["client_phone"]?.toString() ?? '';

          Clientdetails clientDetails = Clientdetails();
          clientDetails.artisan_request_id = rideRequestId;
          clientDetails.client_Address = clientAddress;
          clientDetails.finalClient_address = finalClientaddress;
          clientDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
          clientDetails.dropoff = LatLng(pickUpLocationLat, pickUpLocationLng);
          clientDetails.payment_method = paymentMethod;
          clientDetails.client_name = client_name;
          clientDetails.client_phone = client_phone;

          print("✅ Client details: ${clientDetails.client_name}");

          // ✅ Show the NotificationDialog using navigatorKey
          if (navigatorKey.currentContext != null) {
            print("✅ SHOWING NOTIFICATION DIALOG AUTO using navigatorKey!");
            showDialog(
              context: navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) => NotificationDialog(
                clientDetails: clientDetails,
              ),
            );
          } else {
            print("❌ navigatorKey.currentContext is null");
          }
        } else {
          print("❌ No data found");
          _showGenericDialog(message);
        }
      }).catchError((error) {
        // Dismiss loading
        if (navigatorKey.currentContext != null) {
          Navigator.pop(navigatorKey.currentContext!);
        }
        print("❌ Error fetching data: $error");
        _showGenericDialog(message);
      });
    } catch (e) {
      print("❌ Error in _showNotificationDialogDirectly: $e");
      _showGenericDialog(message);
    }
  }

  // ✅ Show generic dialog using navigatorKey
  void _showGenericDialog(RemoteMessage message) {
    print("📢 Showing generic dialog");

    try {
      if (navigatorKey.currentContext == null) {
        print("❌ navigatorKey.currentContext is null");
        return;
      }

      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? 'You have a new notification';

      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                if (message.data.isNotEmpty) ...[
                  Divider(),
                  Text(
                    '📊 Details:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ...message.data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• ${entry.key}: ${entry.value}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('View Details'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("❌ Error showing generic dialog: $e");
    }
  }

  // ✅ Show in-app snackbar notification using navigatorKey
  void _showInAppNotification(RemoteMessage message) {
    try {
      final notification = message.notification;
      if (notification == null) {
        print("⚠️ No notification payload");
        return;
      }

      if (navigatorKey.currentContext == null) {
        print("❌ navigatorKey.currentContext is null");
        return;
      }

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification.title ?? 'New Notification',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.body ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      print("❌ Error showing in-app notification: $e");
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      if (Platform.isIOS) {
        print("Requesting iOS notification permissions...");

        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        print('iOS Notification permission status: ${settings.authorizationStatus}');

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('✅ iOS notification permission granted');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          print('⚠️ iOS provisional permission granted');
        } else {
          print('❌ iOS notification permission denied');
        }
      } else if (Platform.isAndroid) {
        print("Requesting Android notification permissions...");

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
    print("🔍 _handleMessage called");

    try {
      if (message.data.isEmpty && message.notification == null) {
        print("⚠️ Empty message received");
        return;
      }

      final messageType = message.data['type'] ?? 'immediate';
      print("📩 Message type: $messageType");
      print("📩 Full data: ${message.data}");

      final rideRequestId = getRideRequestId(message.data);
      print("📩 Ride Request ID: $rideRequestId");

      if (messageType == 'recycling') {
        print("♻️ Handling recycling notification...");
        _handleRecyclingNotification(message, context);
      } else if (messageType == 'scheduled') {
        print("📅 Handling scheduled request...");
        _handleScheduledRequest(message, context);
      } else if (rideRequestId.isNotEmpty) {
        print("🚗 Handling ride request: $rideRequestId");
        retrieveRideRequestInfo(rideRequestId, context);
      } else {
        print("📢 Showing immediate notification dialog");
        _showImmediateNotificationDialog(message);
      }
    } catch (e, stack) {
      print("❌ Error handling message: $e");
      print(stack);
    }
  }

  void _showImmediateNotificationDialog(RemoteMessage message) {
    print("📢 Showing immediate notification dialog");

    try {
      if (navigatorKey.currentContext == null) {
        print("❌ navigatorKey.currentContext is null");
        return;
      }

      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? 'You have a new notification';

      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      print("✅ Generic dialog shown");
    } catch (e) {
      print("❌ Error showing generic dialog: $e");
    }
  }

  void _handleRecyclingNotification(RemoteMessage message, BuildContext context) {
    print("♻️ _handleRecyclingNotification called");

    try {
      final data = message.data;
      final recycleItemId = data['recycle_item_id'] ?? '';
      final userName = data['user_name'] ?? 'Someone';
      final userPhone = data['user_phone'] ?? '';
      final recycleType = data['recycle_type'] ?? 'Recyclable items';
      final weight = data['weight'] ?? '';
      final location = data['location'] ?? '';
      final description = data['description'] ?? '';
      final imageUrl = data['image_url'] ?? '';

      print('♻️ Recycling request from $userName');
      print('📦 Type: $recycleType, Weight: $weight kg');
      print('📍 Location: $location');

      if (context.mounted) {
        print("✅ Context mounted, showing recycling dialog...");
        _showRecyclingRequestDialog(
          context,
          recycleItemId: recycleItemId,
          userName: userName,
          userPhone: userPhone,
          recycleType: recycleType,
          weight: weight,
          location: location,
          description: description,
          imageUrl: imageUrl,
        );
      } else {
        print("❌ Context not mounted for recycling dialog");
      }
    } catch (e) {
      print('❌ Error handling recycling notification: $e');
    }
  }

  void _showRecyclingRequestDialog(
      BuildContext context, {
        required String recycleItemId,
        required String userName,
        required String userPhone,
        required String recycleType,
        required String weight,
        required String location,
        required String description,
        required String imageUrl,
      }) {
    print("📢 Showing recycling request dialog");

    try {
      if (!context.mounted) {
        print("❌ Context not mounted, cannot show dialog");
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.recycling, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  '♻️ Recycling Request',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '👤 Client: $userName',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.category, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('📦 Type: $recycleType'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.line_weight, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('⚖️ Weight: $weight kg'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.purple, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('📍 Location: $location'),
                        ),
                      ],
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('📝 $description'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (userPhone.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: Colors.teal, size: 20),
                          SizedBox(width: 8),
                          Text('📞 Phone: $userPhone'),
                        ],
                      ),
                    ),
                  ],
                  if (imageUrl.isNotEmpty) ...[
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.check),
                          label: Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _acceptRecyclingRequest(
                              context,
                              recycleItemId,
                              userName,
                              userPhone,
                              recycleType,
                              weight,
                              location,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.close),
                          label: Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _declineRecyclingRequest(context, recycleItemId);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      print("✅ Recycling dialog shown");
    } catch (e) {
      print("❌ Error showing recycling dialog: $e");
    }
  }

  void _acceptRecyclingRequest(
      BuildContext context,
      String recycleItemId,
      String userName,
      String userPhone,
      String recycleType,
      String weight,
      String location,
      ) async {
    try {
      print('✅ Accepting recycling request: $recycleItemId');

      await FirebaseDatabase.instance
          .ref('recycle_items/$recycleItemId/status')
          .set('accepted');

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseDatabase.instance
            .ref('recycle_items/$recycleItemId')
            .update({
          'wms_id': currentUser.uid,
          'wms_name': await _getWMSName(currentUser.uid),
          'accepted_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await _notifyClientAboutRecyclingStatus(
        userPhone: userPhone,
        recycleItemId: recycleItemId,
        status: 'accepted',
        message: 'Your recycling request has been accepted!',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Recycling request accepted! Client notified.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Error accepting recycling request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _declineRecyclingRequest(BuildContext context, String recycleItemId) async {
    try {
      print('❌ Declining recycling request: $recycleItemId');

      await FirebaseDatabase.instance
          .ref('recycle_items/$recycleItemId/status')
          .set('declined');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recycling request declined'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Error declining recycling request: $e');
    }
  }

  Future<void> _notifyClientAboutRecyclingStatus({
    required String userPhone,
    required String recycleItemId,
    required String status,
    required String message,
  }) async {
    try {
      final tokenSnapshot = await FirebaseDatabase.instance
          .ref('Clients')
          .orderByChild('phone')
          .equalTo(userPhone)
          .once();

      if (tokenSnapshot.snapshot.value != null) {
        final clients = tokenSnapshot.snapshot.value as Map;
        clients.forEach((key, value) async {
          final clientData = value as Map;
          final token = clientData['token'];
          if (token != null && token.isNotEmpty) {
            await _sendRecyclingStatusNotification(
              token: token,
              status: status,
              recycleItemId: recycleItemId,
              message: message,
              companyName: await _getWMSName(FirebaseAuth.instance.currentUser?.uid ?? ''),
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error notifying client: $e');
    }
  }

  Future<String> _getWMSName(String uid) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('WMS/$uid/wasteManagementInfo/FullName')
          .once();

      if (snapshot.snapshot.value != null) {
        return snapshot.snapshot.value.toString();
      }
    } catch (e) {
      print('Error getting WMS name: $e');
    }
    return 'Recycling Company';
  }

  Future<void> _sendRecyclingStatusNotification({
    required String token,
    required String status,
    required String recycleItemId,
    required String message,
    required String companyName,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;
      final function = functions.httpsCallable('sendRecyclingStatusNotification');

      await function.call({
        'token': token,
        'status': status,
        'recycle_item_id': recycleItemId,
        'message': message,
        'companyName': companyName,
      });

      print('✅ Recycling status notification sent to client');
    } catch (e) {
      print('❌ Error sending status notification: $e');
    }
  }

  void _handleScheduledRequest(RemoteMessage message, BuildContext context) async {
    print("📅 _handleScheduledRequest called");

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

      DatabaseEvent? event;
      DatabaseReference ref;

      try {
        ref = FirebaseDatabase.instance
            .ref()
            .child("Request")
            .child("ScheduledRequest")
            .child(wmsRequestId);

        event = (await ref.get()) as DatabaseEvent?;

        if (!event!.snapshot.exists) {
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

      final clientName = data['client_name'] ?? data['RequesterName'] ?? 'Unknown';
      final requestId = data['Requesterid'] ?? data['client_id'] ?? 'Unknown';
      final requeststreamId = data['request_id'] ?? wmsRequestId;
      final clientPhone = data['client_phone'] ?? data['phone'] ?? 'N/A';
      final scheduledTime = data['dateTime'] ?? data['scheduled_time'] ?? 'Not set';

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

      print("✅ Showing scheduled request dialog");
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
      await FirebaseDatabase.instance
          .ref('Request/ScheduledRequest/$requestId/status')
          .set('accepted');

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

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

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
    print("🚗 retrieveRideRequestInfo called for ID: $artisanRequestId");

    try {
      if (!context.mounted) {
        print("❌ Context not mounted");
        return;
      }

      DatabaseEvent event = await clientRequestRef.child(artisanRequestId).once();

      if (!context.mounted) return;

      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        print("📦 Request data found: $map");

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

        print("✅ Client details received: ${clientDetails.client_Address}");

        if (context.mounted) {
          print("✅ Showing NotificationDialog...");
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => NotificationDialog(
              clientDetails: clientDetails,
            ),
          );
          print("✅ NotificationDialog shown");
        }
      } else {
        print("❌ No data found for request ID: $artisanRequestId");

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Request Not Found'),
              content: Text('No request found with ID: $artisanRequestId'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error retrieving ride request info: $e");

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load request details: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}