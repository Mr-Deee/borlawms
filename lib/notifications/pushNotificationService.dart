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
import '../configMaps.dart';
import '../main.dart';
import '../pages/clientDetails.dart';
import 'notificationDialog.dart';

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    print("Initializing push notifications...");

    try {
      print("Step 1: Requesting iOS notification permissions...");
      await _requestNotificationPermissions();
      print("Step 1 Complete: Permissions requested.");
    } catch (e) {
      print("Error during notification permission request: $e");
    }

    try {
      print("Step 2: Setting up foreground message listener...");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.messageId}');
        _handleMessage(message, context);
      });
      print("Step 2 Complete: Foreground listener set.");
    } catch (e) {
      print("Error setting up onMessage listener: $e");
    }

    try {
      print("Step 3: Setting up background message tap listener...");
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.messageId}');
        _handleMessage(message, context);
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
        _handleMessage(initialMessage, context);
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
    if (Platform.isIOS) {
      print("Requesting iOS notification permissions...");

      try {
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
      } catch (e) {
        print("Error requesting iOS permissions: $e");
      }
    } else {
      print("Notification permissions not required for non-iOS platforms.");
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
      if (message.data.isEmpty) {
        print("⚠️ Empty message data received");
        return;
      }

      // Extract type safely
      final messageType = message.data['type'] ?? 'immediate';
      print("📩 Message type: $messageType");

      if (messageType == 'scheduled') {
        // 🔹 Call your new scheduled request handler
        _handleScheduledRequest(message, context);
      } else {
        // 🔹 Default: handle normal ride requests
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
    try {
      final String wmsRequestId = message.data['wms_request_id'] ?? '';

      if (wmsRequestId.isEmpty) {
        print("⚠️ Missing wms_request_id in notification data");
        return;
      }

      print("📦 Fetching scheduled request details for ID: $wmsRequestId");

      // 🔹 Correct database path based on your structure
      final ref = FirebaseDatabase.instance
          .ref()
          .child("Request")
          .child("ScheduledRequest")
          .child(wmsRequestId);

      final requestSnapshot = await ref.get();

      if (!requestSnapshot.exists) {
        print("❌ No scheduled request found for ID $wmsRequestId");
        return;
      }

      final data = Map<String, dynamic>.from(requestSnapshot.value as Map);
      final clientName = data['client_name'] ?? 'Unknown';
      final clientPhone = data['client_phone'] ?? 'N/A';
      final scheduledTime = data['dateTime'] ?? 'Not set';
      final pickupLat = (data['latitude'] as num).toDouble();
      final pickupLng = (data['longitude'] as num).toDouble();
      final locationName = data['location_name'] ?? 'Unknown location';

      // 🔹 Show the request details in a bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🚗 Scheduled Pickup Request',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text('Client: $clientName'),
                Text('Phone: $clientPhone'),
                Text('Pickup: $locationName'),
                Text('Scheduled Time: $scheduledTime'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Accept & View Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScheduledMapScreen(
                          clientName: clientName,
                          clientPhone: clientPhone,
                          pickupLat: pickupLat,
                          pickupLng: pickupLng,
                          pickupLocation: locationName,
                          scheduledTime: scheduledTime,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e, stack) {
      print("❌ Error in _handleScheduledRequest: $e");
      print(stack);
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
class ScheduledMapScreen extends StatefulWidget {
  final String clientName;
  final String clientPhone;
  final String pickupLocation;
  final double pickupLat;
  final double pickupLng;
  final String scheduledTime;

  const ScheduledMapScreen({
    super.key,
    required this.clientName,
    required this.clientPhone,
    required this.pickupLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.scheduledTime,
  });

  @override
  State<ScheduledMapScreen> createState() => _ScheduledMapScreenState();
}

class _ScheduledMapScreenState extends State<ScheduledMapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    final location = Location();
    _currentLocation = await location.getLocation();

    final start = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    final destination = LatLng(widget.pickupLat, widget.pickupLng);

    _addMarkers(start, destination);
    await _drawPolyline(start, destination);
    _calculateDistance(start, destination);

    // Center camera on route
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          min(start.latitude, destination.latitude),
          min(start.longitude, destination.longitude),
        ),
        northeast: LatLng(
          max(start.latitude, destination.latitude),
          max(start.longitude, destination.longitude),
        ),
      ),
      100.0,
    ));
  }

  void _addMarkers(LatLng start, LatLng destination) {
    _markers = {
      Marker(markerId: const MarkerId('current'), position: start, infoWindow: const InfoWindow(title: 'You')),
      Marker(
          markerId: const MarkerId('client'),
          position: destination,
          infoWindow: InfoWindow(title: widget.clientName, snippet: widget.pickupLocation)),
    };
  }

  Future<void> _drawPolyline(LatLng start, LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    // final result = await polylinePoints.getRouteBetweenCoordinates(
    //   'YOUR_GOOGLE_MAPS_API_KEY',
    //
    // );
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(

        googleApiKey: mapKey,
        request: PolylineRequest(
          origin:      PointLatLng(start.latitude, start.longitude),

          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,

        )
    );
    if (result.points.isNotEmpty) {
      final polylineCoordinates = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 6,
            points: polylineCoordinates,
          ),
        };
      });
    }
  }

  void _calculateDistance(LatLng start, LatLng destination) {
    const R = 6371; // km
    final dLat = _deg2rad(destination.latitude - start.latitude);
    final dLon = _deg2rad(destination.longitude - start.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(start.latitude)) *
            cos(_deg2rad(destination.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    setState(() {
      _distanceKm = R * c;
    });
  }

  double _deg2rad(double deg) => deg * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To ${widget.clientName} (${_distanceKm?.toStringAsFixed(2) ?? '--'} km)")),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: 14.5,
            ),
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController.complete(controller),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📍 ${widget.pickupLocation}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Scheduled: ${widget.scheduledTime}'),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('Start Navigation'),
                    onPressed: () {
                      // You can add external navigation logic here (e.g., Google Maps intent)
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}