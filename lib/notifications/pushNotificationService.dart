


import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import '../configMaps.dart';
import '../main.dart';
import '../pages/clientDetails.dart';
import 'notificationDialog.dart';

class PushNotificationService {

  final FirebaseMessaging messaging  = FirebaseMessaging.instance;


// PROBLEM STARTS HERE
  Future initialize(context) async{
    print("Start here");





    FirebaseMessaging.onMessage.listen((RemoteMessage message)   {
      print('Got a message whilst in the foreground!');
      retrieveRideRequestInfo(getRideRequestId(message.data), context);


    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('in the foreground!');
      retrieveRideRequestInfo(getRideRequestId(message.data), context);
    });




    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      retrieveRideRequestInfo(getRideRequestId(context), context);
    }
  }



  Future getToken() async {
    String? token = await messaging.getToken();
    print("This is token :: ");
    print(token);
    WMSDBtoken.child("token").set(token);

    print("JUST GOT IT::"+'$token');
    messaging.subscribeToTopic("alldrivers");
    messaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      print("This is Ride Request Id::");
      rideRequestId = message['WMS_request_id'];
      print("ride_request_id");
      print(rideRequestId);
    }
    else {
      print("This is Ride Request Id:: ");
      rideRequestId = message['WMS_request_id'];
      print(rideRequestId);
    }

    return rideRequestId;
  }

  void retrieveRideRequestInfo(String artisanRequestId, BuildContext context) {
    clientRequestRef.child(artisanRequestId).once().then((event) {

      // var dataSnapshot = value.snapshot;
      // final map = dataSnapshot.value as Map<dynamic, dynamic>;
      //var map = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic,dynamic>;
      //  assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        //assetsAudioPlayer.play();

        double pickUpLocationLat = double.parse(
            map['client_Coordinates']['latitude'].toString());
        double pickUpLocationLng = double.parse(
            map['client_Coordinates']['longitude'].toString());
       String clientAddress = map['Client_address'].toString();
        // String artisanAddress= map["artisan_address"].toString();
        double dropOffLocationLat = double.parse(
            map['client_Coordinates']['latitude'].toString());
        double dropOffLocationLng = double.parse(
            map['client_Coordinates']['longitude'].toString());
        String finalClientaddress = map['finalClient_address']
            .toString();

        String paymentMethod = map['payment_method'].toString();

        String client_name = map["client_name"];
        String client_phone = map["client_phone"];

        Clientdetails clientDetails = Clientdetails();
        clientDetails.artisan_request_id = artisanRequestId;
        clientDetails.client_Address = clientAddress;
        clientDetails.finalClient_address= finalClientaddress;
        clientDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        clientDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        clientDetails.payment_method = paymentMethod;
        clientDetails.client_name = client_name;
        clientDetails.client_phone = client_phone;

        print("Information saaa:: ");
        print(clientDetails.client_Address);
      //  print(clientDetails.artisan_address);


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(clientDetails: clientDetails,),
        );


      }
    }
    );
  }
}


