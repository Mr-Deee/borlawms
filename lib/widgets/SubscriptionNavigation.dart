import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:borlawms/configMaps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NavigationPage extends StatefulWidget {
  final double clientLat;
  final double clientLng;
  final String clientName;
  final String clientToken; // ✅ add this

  const NavigationPage({
    super.key,
    required this.clientLat,
    required this.clientLng,
    required this.clientName,
    required this.clientToken, // ✅ add this

  });

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late GoogleMapController mapController;
  Position? currentPosition;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();
  bool arrived = false;
  double distance = 0;
  double duration = 0;
  Timer? locationUpdateTimer;
  BitmapDescriptor? vehicleIcon;
  BitmapDescriptor? destinationIcon;
  final String googleAPIKey = "AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U";

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    // Custom vehicle icon (you can replace with your asset)
    vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/BCAR.png', // Add this asset to your project
    );

    // Custom destination icon
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(18, 18)),
      'assets/images/destin.png', // Add this asset to your project
    );
  }

  void _startLocationUpdates() {
    const duration = Duration(seconds: 5); // Update every 5 seconds
    locationUpdateTimer = Timer.periodic(duration, (timer) async {
      await _updateDriverLocation();
    });
  }

  Future<void> _updateDriverLocation() async {
    try {
      final newPosition = await Geolocator.getCurrentPosition();

      // Calculate distance to destination
      final distanceToDestination = Geolocator.distanceBetween(
        newPosition.latitude,
        newPosition.longitude,
        widget.clientLat,
        widget.clientLng,
      );

      // Check if arrived (within 50 meters)
      if (distanceToDestination < 50 && !arrived) {
        _handleArrival();
      }

      setState(() {
        currentPosition = newPosition;
        markers.removeWhere((marker) => marker.markerId.value == "current");
        markers.add(
          Marker(
            markerId: const MarkerId("current"),
            position: LatLng(newPosition.latitude, newPosition.longitude),
            icon: vehicleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            rotation: _calculateBearing(
              currentPosition?.latitude ?? 0,
              currentPosition?.longitude ?? 0,
              newPosition.latitude,
              newPosition.longitude,
            ),
            infoWindow: const InfoWindow(title: "Your Location"),
            anchor: const Offset(0.5, 0.5),
          ),
        );
      });

      // Update camera position smoothly
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(newPosition.latitude, newPosition.longitude),
        ),
      );
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  double _calculateBearing(double startLat, double startLng, double endLat, double endLng) {
    final startLatRad = startLat * pi / 180.0;
    final startLngRad = startLng * pi / 180.0;
    final endLatRad = endLat * pi / 180.0;
    final endLngRad = endLng * pi / 180.0;

    final y = sin(endLngRad - startLngRad) * cos(endLatRad);
    final x = cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(endLngRad - startLngRad);
    final bearingRad = atan2(y, x);
    final bearingDeg = (bearingRad * 180.0 / pi + 360) % 360;

    return bearingDeg;
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    currentPosition = await Geolocator.getCurrentPosition();
    _updateMarkers();
    await _getPolyline();
    _startLocationUpdates();
  }

  void _updateMarkers() {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId("current"),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        icon: vehicleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Your Location"),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId("client"),
        position: LatLng(widget.clientLat, widget.clientLng),
        icon: destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.clientName),
      ),
    );
  }





  bool collected = false;

  Future<void> _handleArrival() async {
    // 1️⃣ Send "Arrived" notification
    await sendNotificationToClient(
      token: widget.clientToken,
      title: "WMS Update",
      body: "Your WMS has arrived at your location.",
    );

    setState(() {
      arrived = true;
    });
  }






  Future<void> sendNotificationToClient({
    required String token,
    required String title,
    required String body,
  }) async {
    // ⚠️ Replace with your Firebase project's server key
    const String serverKey = "key=AAAAVtKD6xg:APA91bFcNoAC4CKFdKqZEU8eNWWvcl_mHtWI12bMDChOUvq7lFTxs5QzDiiInaRwMCgN9YuuQPEgJ64Po4w9GujcG2maNOe18cvFUVavbq31giVxmu0wRGY84iDRd884azPUKkruthhl"; // 🔑 Your FCM server key


    final url = Uri.parse("https://fcm.googleapis.com/fcm/send");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serverKey",
      },
      body: jsonEncode({
        "to": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "priority": "high",
      }),
    );

    if (response.statusCode != 200) {
      print("❌ FCM Error: ${response.body}");
    } else {
      print("✅ Notification sent: $title");
    }
  }

  Future<void> _handleCollection() async {
    // 2️⃣ Send "Trash Collected" notification
    await sendNotificationToClient(
      token: widget.clientToken,
      title: "WMS Update",
      body: "Trash has been collected.",
    );

    setState(() {
      collected = true;
    });

    // 3️⃣ Show dialog for WMS to input price
    _showPriceInputDialog();
  }

  Future<void> _showPriceInputDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Price"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter collection price",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = controller.text.trim();
              Navigator.pop(ctx);

              if (price.isNotEmpty) {
                // 4️⃣ Send notification with price to client
                await sendNotificationToClient(
                  token: widget.clientToken,
                  title: "Payment Request",
                  body: "Your WMS has set a price of GHS $price for collection.",
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Price sent to client: GHS $price")),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<void> _getPolyline() async {
    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleAPIKey,
        request: PolylineRequest(
          origin: PointLatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
          destination: PointLatLng(
            widget.clientLat,
            widget.clientLng,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          widget.clientLat,
          widget.clientLng,
        ) / 1000;

        duration = distance * 2; // Approximate minutes (assuming 30km/h average)

        setState(() {
          polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.red.withOpacity(0.7),
              width: 5,
              points: result.points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList(),
            ),
          );
        });

        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                max(currentPosition!.latitude, widget.clientLat),
                max(currentPosition!.longitude, widget.clientLng),
              ),
              southwest: LatLng(
                min(currentPosition!.latitude, widget.clientLat),
                min(currentPosition!.longitude, widget.clientLng),
              ),
            ),
            100,
          ),
        );
      }
    } catch (e) {
      print('Failed to get polyline: $e');
    }
  }

  // void _handleArrival() {
  //   setState(() {
  //     arrived = true;
  //   });
  //   locationUpdateTimer?.cancel();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Arrived at Destination"),
  //       content: const Text("You have successfully reached the client location."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          if (currentPosition == null)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                ),
                zoom: 16, // Higher zoom level for better movement visibility
              ),
              markers: markers,
              polylines: polylines,
              onMapCreated: (controller) {
                mapController = controller;
              },
              myLocationEnabled: false, // Disabled to show our custom marker
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
            ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Trip to ${widget.clientName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(Icons.directions_car, "${distance.toStringAsFixed(1)} km"),
                      _buildInfoItem(Icons.timer, "${duration.toStringAsFixed(0)} mins"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: collected
    ? Colors.grey
        : arrived
    ? Colors.orange
        : Colors.green,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
    ),
    onPressed: collected
    ? null
        : arrived
    ? _handleCollection
        : _handleArrival,
    child: Text(
    collected
    ? "Completed"
        : arrived
    ? "Collected Trash"
        : "I've Arrived",
    style: const TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    ),
    ),
                  ),
                  )],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}