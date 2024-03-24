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

  Timer? timer;
  int durationCounter = 0;

  @override
  void initState() {
    super.initState();

    acceptRideRequest();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/tools.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    // rideStreamSubscription =
    Geolocator.getPositionStream().listen((Position position) {
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

      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mPostion, zoom: 17);
        newRideGoogleMapController
            ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((marker) => marker.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });
      oldPos = mPostion;
      updateRideDetails();

      String? rideRequestId = widget.clientDetails.artisan_request_id;
      Map locMap = {
        "latitude": currentPosition?.latitude.toString(),
        "longitude": currentPosition?.longitude.toString(),
      };
      clientRequestRef
          .child(rideRequestId!)
          .child("WMS_location")
          .set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isColapsed;
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
          setState(() {
            mapPaddingFromBottom = 265.0;
          });

          var currentLatLng =
              LatLng(currentPosition!.latitude, currentPosition!.longitude);
          var pickUpLatLng = widget.clientDetails.pickup;

          await getPlaceDirection(currentLatLng, pickUpLatLng!);

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
                            // Image.asset(
                            //   "images/pickicon.png", height: 16.0,
                            //   width: 16.0,),
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
                            // ignore: deprecated_member_use
                            child: ElevatedButton(
                              onPressed: () async {
                                if (status == "accepted") {
                                  status = "arrived";
                                  String? rideRequestId =
                                      widget.clientDetails.artisan_request_id;
                                  clientRequestRef
                                      .child(rideRequestId!)
                                      .child("status")
                                      .set(status);

                                  setState(() {
                                    btnTitle = "Bin Picked Up";
                                    btnColor = Colors.lightGreen;
                                  });

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        ProgressDialog(
                                      message: "Please wait...",
                                    ),
                                  );

                                  await getPlaceDirection(
                                      widget.clientDetails.pickup!,
                                      widget.clientDetails.dropoff!);

                                  Navigator.pop(context);
                                } else if (status == "arrived") {
                                  status = "onride";
                                  String? rideRequestId =
                                      widget.clientDetails.artisan_request_id;
                                  clientRequestRef
                                      .child(rideRequestId!)
                                      .child("status")
                                      .set(status);

                                  setState(() {
                                    btnTitle = "Done";
                                    btnColor = Colors.redAccent;
                                  });

                                  initTimer();
                                } else if (status == "onride") {
                                  endTheTrip();
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
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMethod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details!.encodedPoints);

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

    newRideGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

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

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

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

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptRideRequest() {

    String? rideRequestId = widget.clientDetails.artisan_request_id;
    clientRequestRef.child(rideRequestId!).child("status").set("accepted");
    clientRequestRef
        .child(rideRequestId)
        .child("WMS_name")
        .set(Provider.of<WMS>(context,listen: false).riderInfo?.firstname??"");
    clientRequestRef
        .child(rideRequestId)
        .child("WMS_phone")
        .set(Provider.of<WMS>(context,listen: false).riderInfo?.phone??"");
    clientRequestRef
        .child(rideRequestId)
        .child("WMS_id")
        .set (WMSDBtoken.key);
    // clientRequestRef.child(rideRequestId).child("artisan_details").set(
    //     '${artisanInformation?.education} ● ${artisanInformation?.servicetype} ● ${artisanInformation?.phone}');

    clientRequestRef
        .child(rideRequestId)
        .child("profilepicture")
        .set(riderinformation?.profilepicture);

    Map locMap = {
      "latitude": currentPosition?.latitude.toString(),
      "longitude": currentPosition?.longitude.toString(),
    };
    clientRequestRef.child(rideRequestId).child("WMS_location").set(locMap);

    WastemanagementRef
        .child(firebaseUser!.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;
      if (myPosition == null) {
        return;
      }
      //this the drivers position
      var posLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
      LatLng? destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.clientDetails.pickup;
      } else {
        destinationLatLng = widget.clientDetails.dropoff;
      }

      var directionDetails = await AssistantMethod.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng!);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText!;
        });
      }

      isRequestingDirection = false;
    }
  }

  // }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async {
    timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);

    var directionalDetails = await AssistantMethod.obtainPlaceDirectionDetails(
        widget.clientDetails.pickup!, currentLatLng);

    Navigator.pop(context);

    int fareAmount = AssistantMethod.calculateFares(directionalDetails!);

    String? rideRequestId = widget.clientDetails.artisan_request_id;
    clientRequestRef
        .child(rideRequestId!)
        .child("fares")
        .set(fareAmount.toString());
    clientRequestRef.child(rideRequestId).child("status").set("ended");
    rideStreamSubscription?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectFareDialog(
        paymentMethod: widget.clientDetails.payment_method,
        fareAmount: fareAmount,
      ),
    );

    saveEarnings(fareAmount);
  }

  void saveEarnings(int fareAmount) {
    clientRequestRef
        .child(currentfirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((event) {
      if (event != null) {
        double oldEarnings = double.parse(event.toString());
        double totalEarnings = fareAmount + oldEarnings;

        clientRequestRef
            .child(currentfirebaseUser!.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      } else {
        double totalEarnings = fareAmount.toDouble();
        clientRequestRef
            .child(currentfirebaseUser!.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      }



    });
  }
  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }


}
