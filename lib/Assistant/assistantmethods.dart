
//   }
//
// }

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:borlawms/Assistant/requestAssistant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Model/RequestModel.dart';
import '../Model/WMSDB.dart';
import '../Model/directDetails.dart';
import '../appData.dart';
import '../configMaps.dart';
import '../main.dart';
import 'package:cloud_functions/cloud_functions.dart';
class AssistantMethod {

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;



 // Send notification to client
  static Future<void> sendNotificationToClient(
  String token,
  BuildContext context,
  String rideRequestId,
  ) async {
  try {

  final result = await _functions.httpsCallable('sendNotificationToClient').call({
  'token': token,
  'title': 'Ride Request Accepted',
  'body': 'Your ride request has been accepted!',
  'rideRequestId': rideRequestId,
  });

  print('✅ Notification sent: ${result.data}');
  return result.data;

  } catch (e) {
  print('❌ Error sending notification: $e');
  throw Exception('Failed to send notification: $e');
  }
  }

  // Send scheduled notification
  static Future<void> sendScheduledNotification({
  required String token,
  required String wmsRequestId,
  required String clientName,
  required String clientPhone,
  required String pickupLocation,
  required String scheduledTime,
  String? title,
  String? body,
  }) async {
  try {
  final functions = FirebaseFunctions.instance;

  final result = await functions.httpsCallable('sendScheduledNotification').call({
  'token': token,
  'title': title ?? 'Scheduled Pickup Request',
  'body': body ?? 'You have a scheduled pickup request',
  'wmsRequestId': wmsRequestId,
  'clientName': clientName,
  'clientPhone': clientPhone,
  'pickupLocation': pickupLocation,
  'scheduledTime': scheduledTime,
  });

  print('✅ Scheduled notification sent: ${result.data}');
  return result.data;

  } catch (e) {
  print('❌ Error sending scheduled notification: $e');
  throw Exception('Failed to send scheduled notification: $e');
  }
  }

  // Save FCM token
  static Future<void> saveFCMToken({
  required String userId,
  required String fcmToken,
  String? userType, // 'wms' or 'client'
  }) async {
  try {
  final functions = FirebaseFunctions.instance;

  final result = await functions.httpsCallable('saveFCMToken').call({
  'userId': userId,
  'fcmToken': fcmToken,
  'userType': userType ?? 'wms',
  });

  print('✅ FCM token saved: ${result.data}');
  return result.data;

  } catch (e) {
  print('❌ Error saving FCM token: $e');
  throw Exception('Failed to save FCM token: $e');
  }
  }


  // FIXED: Properly await and handle the database read
  static Future<void> getCurrentOnlineUserInfo(BuildContext context) async {
    print('assistant methods step 3:: get current online user info');

    firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print('No user logged in');
      return;
    }

    print('assistant methods step 4:: call firebase auth instance');
    String? userId = firebaseUser!.uid;
    print('assistant methods step 5:: assign firebase uid to string');
    print(userId);

    DatabaseReference reference = FirebaseDatabase.instance.ref().child("WMS").child(userId);
    print('assistant methods step 6:: call users document from firebase database using userId');

    try {
      // FIXED: Use await instead of .then() to properly handle the async operation
      DatabaseEvent event = await reference.once();
      final dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        print('assistant methods step 7:: assign users data to usersCurrentInfo object');

        // FIXED: Properly cast the snapshot value to Map
        Map<String, dynamic> userMap;
        if (dataSnapshot.value is Map) {
          userMap = Map<String, dynamic>.from(dataSnapshot.value as Map);
        } else {
          print('Unexpected data format: ${dataSnapshot.value.runtimeType}');
          return;
        }

        // FIXED: Check if context is still valid before using provider
        if (context.mounted) {
          context.read<WMS>().setRider(WMS.fromMap(userMap));
          print('assistant methods step 8:: assign users data to usersCurrentInfo object');
        }
      } else {
        print('No user data found for userId: $userId');
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  static int calculateFares(DirectionDetails directionDetails, {double? estimatedWeight}) {
    // Base fare
    double baseFare = 5.00;

    // Distance fare
    double distanceFare = (directionDetails.distanceValue! / 1000) * 2.00;

    // Weight-based fare (if weight is provided)
    double weightFare = 0.00;
    if (estimatedWeight != null && estimatedWeight > 0) {
      // Assume weight in kg, charge 1 GHS per 5 kg
      weightFare = (estimatedWeight / 5) * 1.00;
    }

    // Time fare (for loading/unloading)
    double timeFare = (directionDetails.durationValue! / 60) * 0.30;

    double totalFareAmount = baseFare + weightFare;

    // Minimum fare guarantee
    if (totalFareAmount < 10.00) {
      totalFareAmount = 10.00;
    }

    return totalFareAmount.toInt();
  }

  static void enableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription!.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);
  }

  // FIXED: Properly await the database read
  static Future<void> getCurrentrequestinfo(BuildContext context) async {
    print('assistant methods step 30:: get current online userOccupation info');

    firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print('No user logged in');
      return;
    }

    print('assistant methods step 39:: call firebase auth instance');
    print('assistant methods step 78:: call users document from firebase database using userId');

    try {
      DatabaseEvent event = await clientRequestRef.once();
      final dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null && context.mounted) {
        context.read<ReqModel>().setotherUser(ReqModel.fromSnapshot(dataSnapshot));
        print('assistant methods step 12:: assign users data to usersCurrentInfo object');
      }
    } catch (e) {
      print('Error loading request info: $e');
    }
  }

  static void obtainTripRequestsHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for (String key in keys) {
      clientRequestRef.child(key).once().then((event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          clientRequestRef.child(key).once().then((event) {
            final name = event.snapshot;
            if (name != null) {
              // var history = History.fromSnapshot(snapshot);
              // Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
            }
          });
        }
      });
    }
  }

  static Future<auth.AccessCredentials> _getAccessToken() async {
    final serviceAccountJson = await rootBundle.loadString('assets/firebase_service_account.json');
    final serviceAccount = json.decode(serviceAccountJson);
    final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final auth.AccessCredentials accessCredentials = await auth.obtainAccessCredentialsViaServiceAccount(
      credentials,
      scopes,
      http.Client(),
    );
    print("accessCred:${accessCredentials}");
    return accessCredentials;
  }

  static const String projectId = 'borlagh-2cc0d';
  static const String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';






  // ==================== GET WMS NAME ====================

  // static sendNotificationToClient(String token, context, String wms_request_id) async {
  //   print("notistart1");
  //   try {
  //     final credentials = await _getAccessToken();
  //     final accessToken = credentials.accessToken.data;
  //     print("notistarted2");
  //
  //     Map<String, dynamic> notification = {
  //       'message': {
  //         'token': token,
  //         'notification': {
  //           'body': 'WMS Address',
  //           'title': 'New BIN Request'
  //         },
  //         'data': {
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'id': '1',
  //           'status': 'done',
  //           'type': 'AccepetedSchedule',
  //           'wms_request_id': wms_request_id,
  //         },
  //       }
  //     };
  //     print("notimap");
  //
  //     final response = await http.post(
  //       Uri.parse(fcmEndpoint),
  //       headers: {
  //         HttpHeaders.authorizationHeader: 'Bearer $accessToken',
  //         HttpHeaders.contentTypeHeader: 'application/json',
  //       },
  //       body: jsonEncode(notification),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Notification sent successfully.');
  //     } else {
  //       print('Failed to send notification. Error: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error sending notification: $e');
  //   }
  // }

  static void disableHomeTabLiveLocationUpdates() {
    firebaseUser = FirebaseAuth.instance.currentUser;
    homeTabPageStreamSubscription?.pause();
    Geofire.removeLocation(firebaseUser!.uid);
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://router.project-osrm.org/route/v1/driving/"
        "${initialPosition.longitude},${initialPosition.latitude};"
        "${finalPosition.longitude},${finalPosition.latitude}"
        "?overview=full&geometries=polyline";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == null || res == "failed") {
      return null;
    }

    final route = res["routes"][0];

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = route["geometry"];
    directionDetails.distanceValue = route["distance"].toInt();
    directionDetails.distanceText = "${(directionDetails.distanceValue! / 1000).toStringAsFixed(1)} km";
    directionDetails.durationValue = route["duration"].toInt();
    directionDetails.durationText = "${(directionDetails.durationValue! / 60).round()} mins";

    return directionDetails;
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }
}