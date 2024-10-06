


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
            Text("New WMS Request",
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
                       checkAvailabilityOfRide(context);
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

  void checkAvailabilityOfRide(context)
  {
    WastemanagementRef.once().then((event){
      Navigator.pop(context);
      String theRideId = "";
      if(event.snapshot.value != null)
      {
        theRideId = event.snapshot.value.toString();
      }
      else
      {
        displayToast("Ride not exists.", context);
      }


      if(theRideId == clientDetails?.artisan_request_id)
      {
        WastemanagementRef.set("accepted");
        AssistantMethod.disableHomeTabLiveLocationUpdates();
        Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRequestScreen(clientDetails: clientDetails!)));
      }
      else if(theRideId == "cancelled")
      {
        displayToast("Ride has been Cancelled.", context);
      }
      else if(theRideId == "timeout")
      {
        displayToast("Ride has time out.", context);
      }
      else
      {
        displayToast("Ride not exists.", context);
      }


    });
  }
  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }


}
