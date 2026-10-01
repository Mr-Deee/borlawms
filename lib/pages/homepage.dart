import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import '../Assistant/assistantmethods.dart';
import '../Assistant/helper.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../CustomDrawer.dart';
import '../Model/Users.dart';
import '../Model/WMSDB.dart';
import '../Model/appstate.dart';
import '../Model/otherUserModel.dart';
import '../configMaps.dart';
import '../main.dart';
import '../notifications/pushNotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

import 'Requestsfolder.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: const LatLng(5.614818, -0.205874),
    zoom: 24.4746,
  );

  @override
  State<homepage> createState() => _homepageState();
}

loc.Location location = loc.Location();

class _homepageState extends State<homepage> {
  String? currentSelectedValue;

  final location = TextEditingController();

  @override
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var geoLocator = Geolocator();

  String driverStatusText = "Go Online ";
  User? currentfirebaseUser;
  Color driverStatusColor = Colors.white70;
  bool drawerOpen = true;
  bool isDriverAvailable = false;
  bool isDriverActivated = false;

  Set<Marker> markersSet = {};
  Position? _currentPosition;
  String? _currentAddress;
  String ArtisanStatusText = "Go Online ";

  Color ArtisanStatusColor = Colors.white70;

  double bottomPaddingOfMap = 0;

  // ✅ NEW: subscription that watches availableWMS/<uid>
  StreamSubscription<DatabaseEvent>? _availabilitySubscription;
  bool _isUpdatingFromListener = false;

  Future<void> requestLocationPermission() async {
    final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;

    bool isLocation =
        serviceStatusLocation == Permission.location.serviceStatus.isEnabled;

    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  Color _textColor = Colors.black;

  Future<void> _initNotifications() async {
    final pushNotificationService = PushNotificationService();
    await pushNotificationService.initialize(context);
  }

  getartisanType() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    WastemanagementRef.child(user.uid)
        .child("WMS_type")
        .once()
        .then((value) {
      if (value != null) {
        print("Info got");
        setState(() {
          rideType = value.toString();
        });
      }
    }).catchError((e) {
      print('Error getting artisan type: $e');
    });
  }

  Future<void> getCurrentWMSInfo() async {
    try {
      currentfirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentfirebaseUser == null) return;

      final event = await WMSDB
          .child(currentfirebaseUser!.uid)
          .once();

      print("value::");

      if (event.snapshot.value != null &&
          event.snapshot.value is Map) {
        riderinformation =
            WMS.fromMap(Map<String, dynamic>.from(
                event.snapshot.value as Map));
        print("value:: $riderinformation");
      }

      getartisanType();

    } catch (e, stack) {
      print('getCurrentWMSInfo error: $e');
      print(stack);
    }
  }

  String WMSStatusText = "Go Online ";
  Color WMSStatusColor = Colors.white70;
  bool isArtisanAvailable = false;
  bool isArtisanActivated = false;

  @override
  void initState() {
    super.initState();
    _startupSequence();
  }

  @override
  void dispose() {
    // ✅ NEW: clean up listeners
    _availabilitySubscription?.cancel();
    homeTabPageStreamSubscription?.cancel();
    super.dispose();
  }

  bool isSwitched = false;

  Future<void> _startupSequence() async {
    await _initNotifications();
    await requestLocationPermission();
    locatePosition();
    AssistantMethod.getCurrentOnlineUserInfo(context);
    await getCurrentWMSInfo();
    AssistantMethod.getCurrentrequestinfo(context);
    AssistantMethod.obtainTripRequestsHistoryData(context);

    // ✅ NEW: after we know the user, start watching their availability node
    await _listenToAvailability();
  }

  /// ✅ NEW: watches availableWMS/<uid> and syncs the switch
  Future<void> _listenToAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Cancel any previous listener
    await _availabilitySubscription?.cancel();

    _availabilitySubscription = FirebaseDatabase.instance
        .ref()
        .child('availableWMS')
        .child(user.uid)
        .onValue
        .listen((event) {
      final bool isOnline = event.snapshot.value != null;

      if (!mounted) return;

      final appState = context.read<AppState>();

      // Only update if it actually changed
      if (appState.isSwitched != isOnline) {
        _isUpdatingFromListener = true;
        appState.setSwitch(isOnline);
        _isUpdatingFromListener = false;
        setState(() {});

        // Keep geofire in sync when toggled externally
        if (isOnline) {
          isArtisanAvailable = true;
          getLocationLiveUpdates();
        } else {
          isArtisanAvailable = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            padding: EdgeInsets.only(top: 24, bottom: bottomPaddingOfMap),
            initialCameraPosition: homepage._kGooglePlex,
            myLocationEnabled: true,
            markers: markersSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              locatePosition();
            },
          ),
          // hamburger for drawer
          Positioned(
            top: 30.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState?.openDrawer();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: const Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(children: [
                if (Provider.of<WMS>(context).riderInfo?.firstname != null)
                  Switch(
                    // ✅ Switch now reflects Firebase state
                    value: context.watch<AppState>().isSwitched,
                    onChanged: (value) async {
                      try {
                        if (value) {
                          await makeArtisanOnlineNow();
                          isArtisanAvailable = true;
                          getLocationLiveUpdates();
                          displayToast("Online.", context);
                        } else {
                          await makeArtisanOfflineNow();
                          isArtisanAvailable = false;
                          displayToast("Offline.", context);
                        }
                        // No manual toggle here — the listener updates the UI
                      } catch (error) {
                        print("Error: $error");
                        displayToast("Error occurred.", context);
                      }
                    },
                    activeTrackColor: Colors.green.withOpacity(0.6),
                    inactiveTrackColor: Colors.white12.withOpacity(0.3),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.black,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FadeInDown(
                            delay: const Duration(milliseconds: 1000),
                            child: const SizedBox(
                              height: 160,
                              width: 240,
                            ),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 10),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void locatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPosition = position;

      LatLng latLatPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition =
      CameraPosition(target: latLatPosition, zoom: 14);
      newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    } catch (e) {
      print('Error locating position: $e');
    }
  }

  Future<void> makeArtisanOnlineNow() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        displayToast("Please sign in first", context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;

      Map<String, dynamic> artisanMap = {
        "Profilepicture":
        Provider.of<Users>(context, listen: false).userInfo?.profilepicture ?? "",
        "Username": Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "",
        "WMS_type": "WMS",
        "client_phone": Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "",
        "email": Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "",
      };

      WastemanagementRef.set("searching");
      Geofire.initialize("availableWMS");
      Geofire.setLocation(
        user.uid,
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      // ✅ This is what the listener watches
      DatabaseReference wmsAvailableRef = FirebaseDatabase.instance
          .ref()
          .child("availableWMS")
          .child(user.uid);

      // Auto-remove on disconnect
      wmsAvailableRef.onDisconnect().remove();

      await wmsAvailableRef.set(artisanMap);

      WastemanagementRef.onValue.listen((event) {});
    } catch (e) {
      print('Error making artisan online: $e');
      displayToast("Error going online", context);
    }
  }

  void requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not granted permission');
    }
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription?.cancel();
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
          currentPosition = position;

          if (isArtisanAvailable == true) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              Geofire.setLocation(
                  user.uid, position.latitude, position.longitude);
            }
          }
        });
  }

  Future<void> ArtisanActivated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Geofire.removeLocation(user.uid);
    WastemanagementRef.onDisconnect();
    WastemanagementRef.remove();

    displayToast("Sorry You are not Activated", context);
  }

  Future<void> makeArtisanOfflineNow() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Geofire.removeLocation(user.uid);

      // ✅ Remove from availableWMS → listener flips the switch off
      await FirebaseDatabase.instance
          .ref()
          .child("availableWMS")
          .child(user.uid)
          .remove();

      WastemanagementRef.onDisconnect();
      WastemanagementRef.remove();
    } catch (e) {
      print('Error making artisan offline: $e');
    }
  }

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}