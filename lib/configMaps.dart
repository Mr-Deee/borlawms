import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'Model/WMSDB.dart';

String mapKey = "AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U";
WMS? riderinformation;
User? firebaseUser;
User? currentfirebaseUser;
Position? currentPosition;
User? currentUser;
String title = "";
double starCounter = 0.0;
StreamSubscription<Position>? homeTabPageStreamSubscription;
String rideType = "";
String serverToken =
    "key=AAAAVtKD6xg:APA91bFcNoAC4CKFdKqZEU8eNWWvcl_mHtWI12bMDChOUvq7lFTxs5QzDiiInaRwMCgN9YuuQPEgJ64Po4w9GujcG2maNOe18cvFUVavbq31giVxmu0wRGY84iDRd884azPUKkruthhl";
