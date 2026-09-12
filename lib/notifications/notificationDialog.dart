


import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Assistant/assistantmethods.dart';
import '../configMaps.dart';
import '../main.dart';
import '../pages/clientDetails.dart';
import '../pages/newRequestScreen.dart';

class NotificationDialog extends StatelessWidget {
  //final assetsAudioPlayer =AssetsAudioPlayer();


  final Clientdetails? clientDetails;
  NotificationDialog({this.clientDetails});


  @override
  Widget build(BuildContext context)
  {

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.0),
            Image.asset("assets/images/wms.png", width: 150.0,),
            SizedBox(height: 0.12,),
            Text("New Borla Request",
              style: TextStyle(fontFamily: "Brand Bold", fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.black),),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text("Pick Up", style: TextStyle(fontSize: 20.0,color: Colors.black),),
                   Image.asset("assets/images/100l.png", height: 23.0, width: 16.0,),
                      SizedBox(width: 20.0,),
                     Expanded(child: Container(
                         child:  Container(child: Text(clientDetails!.client_Address??"", style: TextStyle(fontSize: 18.0,color: Colors.black), )),
                         //Text("Artisan Address", style: TextStyle(fontSize: 18.0,color: Colors.black), )),
                     ),
                     ) ],
                  ),
                  SizedBox(height: 20.0),



                ],
              ),
            ),

            SizedBox(height: 15.0),
            Divider(height: 2.0, thickness: 4.0,),
            SizedBox(height: 0.0),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    ElevatedButton(
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(18.0),
                      //     side: BorderSide(color: Colors.red)),
                      // color: Colors.white,
                      // textColor: Colors.red,
                      // padding: EdgeInsets.all(8.0),
                      onPressed: ()
                      {
                        //assetsAudioPlayer.stop();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel".toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),

                    SizedBox(width: 25.0),

                    ElevatedButton(
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(18.0),
                      //     side: BorderSide(color: Colors.green)),
                      onPressed: ()
                      {
                        //assetsAudioPlayer.stop();
                        checkAvailabilityOfBorla(context);
                     //  return context;


                      },
                      //color: Colors.green,
                     // textColor: Colors.white,
                      child: Text("Accept".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),

                  ],
                ),
              ),
            ),

            SizedBox(height: 0.0),
          ],
        ),
      ),
    );
  }




  void checkAvailabilityOfBorla(BuildContext context) {
    if (clientDetails?.artisan_request_id == null ||
        clientDetails!.artisan_request_id.toString().isEmpty) {
      displayToast("Invalid request.", context);
      Navigator.pop(context);
      return;
    }

    String requestId = clientDetails!.artisan_request_id.toString();
    DatabaseReference rideRef = FirebaseDatabase.instance
        .ref()
        .child("ClientRequest")
        .child(requestId);

    rideRef.once().then((event) {
      // Close the notification dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (event.snapshot.value != null) {
        // Update status to accepted
        rideRef.update({"status": "accepted"}).then((_) {
          AssistantMethod.disableHomeTabLiveLocationUpdates();

          // Use the global navigator key instead of context
          navigatorKey.currentState?.push(
              MaterialPageRoute(
                  builder: (context) => NewRequestScreen(
                      clientDetails: clientDetails!
                  )
              )
          );
        }).catchError((error) {
          displayToast("Error: $error", context);
        });
      } else {
        displayToast("Ride not found.", context);
      }
    }).catchError((error) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      displayToast("Error: $error", context);
    });
  }

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }


}
