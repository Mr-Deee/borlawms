// map_route_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapRoutePage extends StatefulWidget {
  final LatLng destination;
  final String weight;
  final String paused;

  const MapRoutePage({super.key, required this.destination, required this.weight, required this.paused});

  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  LatLng? currentLocation;
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    final locData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locData.latitude!, locData.longitude!);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Info"),
        content: Text("Weight Collected: ${widget.weight}\nPaused: ${widget.paused}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Route to Destination")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocation!,
          zoom: 14,
        ),
        markers: {
          Marker(markerId: const MarkerId("current"), position: currentLocation!),
          Marker(markerId: const MarkerId("destination"), position: widget.destination),
        },
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
