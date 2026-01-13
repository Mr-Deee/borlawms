
import 'dart:convert';
import 'dart:io';
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


// import '../otherUserModel.dart';

class AssistantMethod{
  static void getCurrentOnlineUserInfo(BuildContext context) async {
    print('assistant methods step 3:: get current online user info');
    firebaseUser = FirebaseAuth.instance.currentUser; // CALL FIREBASE AUTH INSTANCE
    print('assistant methods step 4:: call firebase auth instance');
    String? userId = firebaseUser!.uid; // ASSIGN UID FROM FIREBASE TO LOCAL STRING
    print('assistant methods step 5:: assign firebase uid to string');
    print(userId);
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("WMS").child(userId);
    print(
        'assistant methods step 6:: call users document from firebase database using userId');
    reference.once().then(( event) async {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.value!= null) {
        print(
            'assistant methods step 7:: assign users data to usersCurrentInfo object');

        DatabaseEvent event = await reference.once();
        print(event);

        context.read<WMS>().setRider(WMS.fromMap(Map<String, dynamic>.from(event.snapshot.value as dynamic)));
        print('assistant methods step 8:: assign users data to usersCurrentInfo object');


      }
    }
    );






  }

  static int calculateFares(DirectionDetails directionDetails) {
    //in terms of GHS
    double timeTravelFare = (directionDetails.durationValue! / 60) * 0.20;
    double distanceTraveledFare = (directionDetails.distanceValue! / 1000) *
        0.20;
    double totalFareAmount = timeTravelFare + distanceTraveledFare;

    //1$ = 5.76
    double totalLocalAmount = totalFareAmount * 160;

    if (rideType == "Rev-x") {
      double result = (totalFareAmount.truncate()) * 2.0;
      return result.truncate();
    }
    else if (rideType == "Rev-Executive") {
      return totalFareAmount.truncate();
    }
    else if (rideType == "Rev-standard") {
      double result = (totalFareAmount.truncate()) / 2.0;
      return result.truncate();
    }
    else {
      return totalFareAmount.truncate();
    }
  }

  static void enableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription!.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);
  }


  static void getCurrentrequestinfo(BuildContext context) async {
    print('assistant methods step 30:: get current online userOccupation info');
    firebaseUser =
        FirebaseAuth.instance.currentUser; // CALL FIREBASE AUTH INSTANCE
    print('assistant methods step 39:: call firebase auth instance');

    print(
        'assistant methods step 78:: call users document from firebase database using userId');
    clientRequestRef.once().then((event) async {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.value!= null) {
        context.read<ReqModel>().setotherUser(ReqModel.fromSnapshot(dataSnapshot) );
        print(
            'assistant methods step 12:: assign users data to usersCurrentInfo object');
      }
    }
    );



  }

  static void obtainTripRequestsHistoryData(context)
  {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for(String key in keys)
    {
      clientRequestRef.child(key).once().then((event) {
        final snapshot = event.snapshot;
        if(snapshot.value != null)
        {
          clientRequestRef.child(key).once().then((event)
          {
            // final snap = event.snapshot;
            final name = event.snapshot;
            if(name!=null)
            {
              // var history = History.fromSnapshot(snapshot);
              // Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
            }
          });
        }
      });
    }
  }



  static Future<auth.AccessCredentials> _getAccessToken() async {
    final serviceAccountJson =
    await rootBundle.loadString('assets/firebase_service_account.json');
    final serviceAccount = json.decode(serviceAccountJson);
    final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final auth.AccessCredentials accessCredentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
      credentials,
      scopes,
      http.Client(),
    );
    print("accessCred:${accessCredentials}");
    return accessCredentials;
  }

  static const String projectId = 'borlagh-2cc0d'; // Your Firebase project ID
  static const String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

  static sendNotificationToClient(String token, context, String wms_request_id) async {

    print("notistart1");
    // var destination = Provider.of<AppData>(context, listen: false).dropOfflocation;
    try {
      final credentials = await _getAccessToken();
      final accessToken = credentials.accessToken.data;
      print("notistarted2");
      // FCM HTTP v1 API payload
      Map<String, dynamic> notification = {
        'message': {
          'token': token,
          'notification': {
            'body': 'WMS Address',
            'title': 'New BIN Request'
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'AccepetedSchedule', // ✅ Move type here

            'wms_request_id': wms_request_id,
          },
        }
      };
      print("notimap");
      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(notification),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed to send notification. Error: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }



  static void disableHomeTabLiveLocationUpdates() {
    firebaseUser =
        FirebaseAuth.instance.currentUser;
    homeTabPageStreamSubscription?.pause();
    Geofire.removeLocation(firebaseUser!.uid);
  }

  // static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
  //   String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition
  //       .latitude},${initialPosition.longitude}&destination=${finalPosition
  //       .latitude},${finalPosition.longitude}&key=$mapKey";
  //
  //   var res = await RequestAssistant.getRequest(directionUrl);
  //   if (res == "failed") {
  //     return null;
  //   }
  //   DirectionDetails directionDetails = DirectionDetails();
  //   directionDetails.encodedPoints =
  //   res["routes"][0]["overview_polyline"]["points"];
  //   directionDetails.distanceText =
  //   res["routes"][0]["legs"][0]["distance"]["text"];
  //   directionDetails.distanceValue =
  //   res["routes"][0]["legs"][0]["distance"]["value"];
  //
  //   directionDetails.durationText =
  //   res["routes"][0]["legs"][0]["duration"]["text"];
  //   directionDetails.durationValue =
  //   res["routes"][0]["legs"][0]["duration"]["value"];
  //
  //   return directionDetails;
  // }
  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition,) async {

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

    // ✅ Google-compatible encoded polyline
    directionDetails.encodedPoints = route["geometry"];

    // ✅ Distance (meters)
    directionDetails.distanceValue = route["distance"].toInt();
    directionDetails.distanceText =
    "${(directionDetails.distanceValue! / 1000).toStringAsFixed(1)} km";

    // ✅ Duration (seconds)
    directionDetails.durationValue = route["duration"].toInt();
    directionDetails.durationText =
    "${(directionDetails.durationValue! / 60).round()} mins";

    return directionDetails;
  }


  static String formatTripDate(String date)
  {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }

}