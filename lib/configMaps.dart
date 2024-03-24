import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

// import 'Models/Users.dart';
// import 'Models/arti_san.dart';
import 'package:geolocator/geolocator.dart';

import 'Model/WMSDB.dart';


// String mapKey ="AIzaSyALq45ym3PbPzoeBB8ULxsVdQ2VSRFWWuQ";
String mapKey ="AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U";


// Arti_san? artisanInformation;
WMS? riderinformation;
//User firebaseUser;
User? firebaseUser;


User? currentfirebaseUser;
// Users? userCurrentInfo; // CURRENT USER INFO

Position ?currentPosition;

User? currentUser;

String title="";
double starCounter=0.0;

StreamSubscription<Position>?  homeTabPageStreamSubscription;
String rideType="";
String serverToken = "key=AAAAVtKD6xg:APA91bFcNoAC4CKFdKqZEU8eNWWvcl_mHtWI12bMDChOUvq7lFTxs5QzDiiInaRwMCgN9YuuQPEgJ64Po4w9GujcG2maNOe18cvFUVavbq31giVxmu0wRGY84iDRd884azPUKkruthhl";