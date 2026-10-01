import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Assistant/assistantmethods.dart';
import '../configMaps.dart';
import '../main.dart';
import '../pages/clientDetails.dart';
import '../pages/newRequestScreen.dart';

class NotificationDialog extends StatelessWidget {
  final Clientdetails? clientDetails;

  NotificationDialog({this.clientDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section with gradient background
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/images/wms.png",
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "New Borla Request",
                    style: TextStyle(
                      fontFamily: "Brand Bold",
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6.0),
                  Text(
                    "A new pickup request is available",
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                children: [
                  // Location card
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Color(0xFFC5E1A5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Image.asset(
                            "assets/images/100l.png",
                            height: 22.0,
                            width: 16.0,
                          ),
                        ),
                        SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup Location",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 6.0),
                              Text(
                                clientDetails!.client_Address ?? "Address not available",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        backgroundColor: Colors.grey.shade50,
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.0),

                  // Accept button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        checkAvailabilityOfBorla(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        backgroundColor: Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Color(0xFF2E7D32).withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20.0),
                          SizedBox(width: 8.0),
                          Text(
                            "Accept Request",
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (event.snapshot.value != null) {
        rideRef.update({"status": "accepted"}).then((_) {
          AssistantMethod.disableHomeTabLiveLocationUpdates();

          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) =>
                  NewRequestScreen(clientDetails: clientDetails!),
            ),
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