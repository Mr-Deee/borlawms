
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Model/Client.dart';
import '../Model/RequestModel.dart';
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


  // static void retrieveHistoryInfo(context)
  // {
  //   //retrieve and display Trip History
  //   clientRequestRef.orderByChild("client_name").once().then((event)
  //   {
  //     final dataSnapshot = event.snapshot;
  //     if(dataSnapshot.value != null)
  //     {
  //       print('assistant methods step 84::{}');
  //       //update total number of trip counts to provider
  //       Map<dynamic, dynamic> keys = dataSnapshot as Map;
  //       int tripCounter = keys.length;
  //       Provider.of<AppData>(context, listen: false).updateTripsCounter(tripCounter);
  //       print('assistant methods step 84::{}');
  //       //update trip keys to provider
  //       List<String> tripHistoryKeys = [];
  //       keys.forEach((key, value)
  //       {
  //         tripHistoryKeys.add(key);
  //       });
  //       Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);
  //       obtainTripRequestsHistoryData(context);
  //     }
  //   });
  // }

  // static void obtainTripRequestsHistoryData(context)
  // {
  //   // var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;
  //
  //   for(String key in keys)
  //   {
  //     clientRequestRef.child(key).once().then((event) {
  //       final snapshot = event.snapshot;
  //       if(snapshot.value != null)
  //       {
  //         clientRequestRef.child(key).once().then((event)
  //         {
  //           // final snap = event.snapshot;
  //           final name = event.snapshot;
  //           if(name!=null)
  //          {
  //             // var history = History.fromSnapshot(snapshot);
  //             // Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
  //           }
  //         });
  //       }
  //     });
  //   }
  // }



  static void disableHomeTabLiveLocationUpdates() {
    firebaseUser =
        FirebaseAuth.instance.currentUser;
    homeTabPageStreamSubscription?.pause();
    Geofire.removeLocation(firebaseUser!.uid);
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition
        .latitude},${initialPosition.longitude}&destination=${finalPosition
        .latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);
    if (res == "failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints =
    res["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText =
    res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
    res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
    res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
    res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }


  static String formatTripDate(String date)
  {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }

}