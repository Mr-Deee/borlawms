import 'dart:async';

import 'package:borlawms/pages/progressdialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Assistant/assistantmethods.dart';
import '../Assistant/mapKitAssistant.dart';
import '../Model/WMSDB.dart';
import '../configMaps.dart';
import '../main.dart';
import 'CollectFareDialog.dart';
import 'clientDetails.dart';

class NewRequestScreen extends StatefulWidget {
  final Clientdetails clientDetails;

  NewRequestScreen({required this.clientDetails});

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  double _width = 70;
  double _height = 70;
  Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(10);

  bool _isCollapsed = false;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newRideGoogleMapController;
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  var locationOptions =
  LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;
  Position? myPosition;
  String status = "accepted";
  String durationRide = "";
  bool isRequestingDirection = false;
  String btnTitle = "Arrived";
  Color btnColor = Colors.white;
  StreamSubscription<DatabaseEvent>? rideStreamSubscription;
  StreamSubscription<Position>? positionStreamSubscription;

  Timer? timer;
  int durationCounter = 0;

  // Flag to track if widget is disposed
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    acceptRideRequest();
  }

  @override
  void dispose() {
    _isDisposed = true;
    timer?.cancel();
    rideStreamSubscription?.cancel();
    positionStreamSubscription?.cancel();
    newRideGoogleMapController?.dispose();
    _controllerGoogleMap = Completer();
    super.dispose();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/tools.png")
          .then((value) {
        if (!_isDisposed && mounted) {
          animatingMarkerIcon = value;
        }
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (_isDisposed || !mounted) {
        positionStreamSubscription?.cancel();
        return;
      }

      currentPosition = position;
      myPosition = position;
      LatLng mPostion = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, myPosition?.latitude, myPosition?.latitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPostion,
        icon: animatingMarkerIcon!,
        rotation: rot as double,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      if (mounted && !_isDisposed) {
        setState(() {
          CameraPosition cameraPosition =
          CameraPosition(target: mPostion, zoom: 17);
          newRideGoogleMapController
              ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

          markersSet
              .removeWhere((marker) => marker.markerId.value == "animating");
          markersSet.add(animatingMarker);
        });
      }

      oldPos = mPostion;
      updateRideDetails();

      String? rideRequestId = widget.clientDetails.artisan_request_id;
      if (rideRequestId != null) {
        Map locMap = {
          "latitude": currentPosition?.latitude.toString(),
          "longitude": currentPosition?.longitude.toString(),
        };
        clientRequestRef
            .child(rideRequestId)
            .child("WMS_location")
            .set(locMap);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
        body: Stack(children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRequestScreen._kGooglePlex,
            myLocationEnabled: true,
            markers: markersSet,
            circles: circleSet,
            polylines: polyLineSet,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;
              if (mounted && !_isDisposed) {
                setState(() {
                  mapPaddingFromBottom = 265.0;
                });
              }

              if (currentPosition != null && widget.clientDetails.pickup != null) {
                var currentLatLng =
                LatLng(currentPosition!.latitude, currentPosition!.longitude);
                var pickUpLatLng = widget.clientDetails.pickup;
                await getPlaceDirection(currentLatLng, pickUpLatLng!);
              }

              getRideLiveLocationUpdates();
            },
          ),
          Positioned(
              left: 10.0,
              right: 10.0,
              bottom: 10.0,
              child: SingleChildScrollView(
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                      height: 270.0,
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(children: [
                            Text(
                              durationRide,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: "Brand Bold",
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 26.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.clientDetails.client_name ?? "",
                                  style: TextStyle(
                                      fontFamily: "Brand Bold", fontSize: 24.0),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Icon(Icons.work),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 18.0,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      widget.clientDetails.client_Address ?? "",
                                      style: TextStyle(fontSize: 18.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 26.0,
                            ),
                            SizedBox(
                              height: 26.0,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (status == "accepted") {
                                      status = "arrived";
                                      String? rideRequestId =
                                          widget.clientDetails.artisan_request_id;
                                      if (rideRequestId != null) {
                                        clientRequestRef
                                            .child(rideRequestId)
                                            .child("status")
                                            .set(status);
                                      }

                                      if (mounted && !_isDisposed) {
                                        setState(() {
                                          btnTitle = "Bin Picked Up";
                                          btnColor = Colors.lightGreen;
                                        });
                                      }

                                      if (mounted && !_isDisposed) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) =>
                                              ProgressDialog(
                                                message: "Please wait...",
                                              ),
                                        );
                                      }

                                      if (widget.clientDetails.pickup != null &&
                                          widget.clientDetails.dropoff != null) {
                                        await getPlaceDirection(
                                            widget.clientDetails.pickup!,
                                            widget.clientDetails.dropoff!);
                                      }

                                      if (mounted && !_isDisposed && Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    } else if (status == "arrived") {
                                      status = "onride";
                                      String? rideRequestId =
                                          widget.clientDetails.artisan_request_id;
                                      if (rideRequestId != null) {
                                        clientRequestRef
                                            .child(rideRequestId)
                                            .child("status")
                                            .set(status);
                                      }

                                      if (mounted && !_isDisposed) {
                                        setState(() {
                                          btnTitle = "Done";
                                          btnColor = Colors.redAccent;
                                        });
                                      }

                                      initTimer();
                                    } else if (status == "onride") {
                                      await endTheTrip();
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(17.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          btnTitle,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        Icon(
                                          Icons.work,
                                          color: Colors.black,
                                          size: 26.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: btnColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                        side:
                                        const BorderSide(color: Colors.white)),
                                  ),
                                )),
                          ]),
                        ),
                      ))))
        ]));
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    if (!mounted || _isDisposed) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
          message: "Please wait...",
        ));

    var details = await AssistantMethod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    if (mounted && !_isDisposed && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (details == null) return;

    print("This is Encoded Points ::");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
    polylinePoints.decodePolyline(details.encodedPoints!);

    polylineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    if (mounted && !_isDisposed) {
      setState(() {
        Polyline polyline = Polyline(
          color: Colors.black,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polylineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );

        polyLineSet.add(polyline);
      });
    }

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    if (mounted && !_isDisposed) {
      setState(() {
        markersSet.add(pickUpLocMarker);
        markersSet.add(dropOffLocMarker);
      });
    }

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.black,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.black,
      circleId: CircleId("dropOffId"),
    );

    if (mounted && !_isDisposed) {
      setState(() {
        circleSet.add(pickUpLocCircle);
        circleSet.add(dropOffLocCircle);
      });
    }
  }

  void acceptRideRequest() {
    String? rideRequestId = widget.clientDetails.artisan_request_id;
    if (rideRequestId == null) return;

    clientRequestRef.child(rideRequestId).child("status").set("accepted");
    clientRequestRef
        .child(rideRequestId)
        .child("WMS_name")
        .set(Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "");
    clientRequestRef
        .child(rideRequestId)
        .child("WMS_phone")
        .set(Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "");
    clientRequestRef
        .child(rideRequestId)
        .child("WMS_id")
        .set(WMSDBtoken.key);

    clientRequestRef
        .child(rideRequestId)
        .child("profilepicture")
        .set(riderinformation?.profilepicture);

    if (currentPosition != null) {
      Map locMap = {
        "latitude": currentPosition?.latitude.toString(),
        "longitude": currentPosition?.longitude.toString(),
      };
      clientRequestRef.child(rideRequestId).child("WMS_location").set(locMap);
    }

    if (firebaseUser != null) {
      WastemanagementRef
          .child(firebaseUser!.uid)
          .child("history")
          .child(rideRequestId)
          .set(true);
    }
  }

  void updateRideDetails() async {
    if (_isDisposed || !mounted) return;

    if (isRequestingDirection == false) {
      isRequestingDirection = true;
      if (myPosition == null) {
        isRequestingDirection = false;
        return;
      }

      var posLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
      LatLng? destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.clientDetails.pickup;
      } else {
        destinationLatLng = widget.clientDetails.dropoff;
      }

      if (destinationLatLng != null) {
        var directionDetails = await AssistantMethod.obtainPlaceDirectionDetails(
            posLatLng, destinationLatLng);

        if (directionDetails != null && mounted && !_isDisposed) {
          setState(() {
            durationRide = directionDetails.durationText!;
          });
        }
      }

      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      if (!_isDisposed && mounted) {
        durationCounter = durationCounter + 1;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> endTheTrip() async {
    timer?.cancel();

    int? fareAmount;
    if (!mounted || _isDisposed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    try {
      String? rideRequestId = widget.clientDetails.artisan_request_id;

      if (rideRequestId == null) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        throw Exception("Ride request ID is null");
      }

      DatabaseReference rideRef = clientRequestRef.child(rideRequestId);

      print('riderefhere$rideRequestId');
      DataSnapshot snapshot = await rideRef.child("fare").get();
      print('fare${snapshot.value.toString()}');


      if (snapshot.exists && snapshot.value != null) {
        fareAmount =int.parse( snapshot.value.toString());
        print("Fare from database: $fareAmount");
      } else {
        print("No fare in database, calculating locally");
        if (myPosition != null && widget.clientDetails.pickup != null) {
          var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
          var directionalDetails = await AssistantMethod.obtainPlaceDirectionDetails(
              widget.clientDetails.pickup!,
              currentLatLng
          );

        } else {
          throw Exception("Missing position or pickup data for fare calculation");
        }
      }

      if (mounted && !_isDisposed && Navigator.canPop(context)) {
        Navigator.pop(context); // Close progress dialog
      }

      await rideRef.child("status").set("ended");

      rideStreamSubscription?.cancel();
      positionStreamSubscription?.cancel();

      if (mounted && !_isDisposed) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => CollectFareDialog(
            paymentMethod: widget.clientDetails.payment_method,
            fareAmount: fareAmount,
          ),
        );
      }

      await saveEarnings(fareAmount!);

    } catch (e) {
      if (mounted && !_isDisposed && Navigator.canPop(context)) {
        Navigator.pop(context); // Close dialog on error
      }
      print("Error ending trip: $e");
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ending trip: $e")),
        );
      }
    }
  }

  Future<void> saveEarnings(int fareAmount) async {
    try {
      if (currentfirebaseUser == null) {
        print("Current user is null");
        return;
      }

      DatabaseReference earningsRef = clientRequestRef
          .child(currentfirebaseUser!.uid)
          .child("earnings");

      DataSnapshot event = (await earningsRef.once()) as DataSnapshot;

      if (event.exists && event.value != null) {
        double oldEarnings = double.tryParse(event.value.toString()) ?? 0;
        double totalEarnings = fareAmount + oldEarnings;
        await earningsRef.set(totalEarnings.toStringAsFixed(2));
      } else {
        double totalEarnings = fareAmount.toDouble();
        await earningsRef.set(totalEarnings.toStringAsFixed(2));
      }
    } catch (e) {
      print("Error saving earnings: $e");
    }
  }

  void displayToast(String message, BuildContext context) {
    if (mounted && !_isDisposed) {
      Fluttertoast.showToast(msg: message);
    }
  }
}