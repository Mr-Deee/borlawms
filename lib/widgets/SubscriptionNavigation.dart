import 'dart:math';

import 'package:borlawms/configMaps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class NavigationPage extends StatefulWidget {
  final double clientLat;
  final double clientLng;
  final String clientName;

  const NavigationPage({
    super.key,
    required this.clientLat,
    required this.clientLng,
    required this.clientName,
  });

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  GoogleMapController? mapController;
  Position? currentPosition;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();
  bool arrived = false;
  double distance = 0;
  double duration = 0;
  final String googleAPIKey = "AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    currentPosition = await Geolocator.getCurrentPosition();

    // Custom marker icons
    final BitmapDescriptor currentIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/driver_pin.png',
    );

    final BitmapDescriptor destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/destination_pin.png',
    );

    markers.add(
      Marker(
        markerId: const MarkerId("current"),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        icon: currentIcon,
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId("client"),
        position: LatLng(widget.clientLat, widget.clientLng),
        icon: destinationIcon,
        infoWindow: InfoWindow(title: widget.clientName),
      ),
    );

    await _getPolyline();
    setState(() {});
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
        // Calculate distance and duration (approximate)
        distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          widget.clientLat,
          widget.clientLng,
        ) / 1000; // in km

        duration = distance * 2; // Approximate minutes (assuming 30km/h average)

        setState(() {
          polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.red,
              width: 6,
              points: result.points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList(),
            ),
          );
        });

        // Zoom to fit both markers
        mapController?.animateCamera(
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
            100, // padding
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No route found between locations")),
        );
      }
    } catch (e) {
      print('Failed to get polyline: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching route")),
      );
    }
  }

  void _handleArrival() {
    setState(() {
      arrived = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Arrived at Destination"),
        content: const Text("You have successfully reached the client location."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

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
                zoom: 14,
              ),
              markers: markers,
              polylines: polylines,
              onMapCreated: (controller) => mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
            ),

          // Floating trip details panel
          if (currentPosition != null)
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
                          backgroundColor: arrived ? Colors.green : Colors.black12,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: arrived ? null : _handleArrival,
                        child: Text(
                          arrived ? "Arrived" : "I've Arrived",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}