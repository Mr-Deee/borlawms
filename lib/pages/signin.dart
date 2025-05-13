
// import 'package:borla_client/pages/smscode.dart';
import 'package:borlawms/pages/progressdialog.dart';
import 'package:borlawms/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import '../Assistant/assistantmethods.dart';
import '../configMaps.dart';
import '../main.dart';
import 'GuestMode.dart';
import 'forgotpassword.dart';
import 'homepage.dart';

class signin extends StatefulWidget {
  const signin({super.key});

  @override
  State<signin> createState() => _signinState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _userRef =
    FirebaseDatabase.instance.ref().child('users');
TextEditingController phoneNumberController = TextEditingController();
TextEditingController emailcontroller = TextEditingController();
TextEditingController passwordcontroller = TextEditingController();
// Define googleSignIn here

String? phoneNumber;
String? verificationId;
String? smsCode;

Future<void> verifyPhoneNumber() async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      print('Authentication successful');
    },
    verificationFailed: (FirebaseAuthException e) {
      print('Failed to verify phone number: ${e.message}');
    },
    codeSent: (String? verificationId, int? resendToken) {
      // +233
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Timeout handling if needed
    },
  );
}



Future<void> writeEmailToDatabase(String userId, String email) async {
  // Write the email to the database under the user's ID
  _userRef.child(userId).set({'email': email});
}

Future<bool> checkIfEmailExistsInDatabase(String email) async {
  DatabaseEvent snapshot =
      await _userRef.orderByChild('email').equalTo(email).once();
  var data = snapshot.snapshot.value;

  return data != null;
}

class _signinState extends State<signin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
    requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Login Page"),
      // ),
      body: Container(

        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.greenAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image
                Container(
                  width: 160.0,
                  height: 120.0,
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Image.asset('assets/images/wms.png'),
                ),



                // Subheader Text
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:20.0),
                      child: Text(
                        "Login to continue using the app",
                        style: TextStyle(fontSize: 14, color: Colors.black45,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.0),

                // Email Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black12,

                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.0),

                // Password Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                    obscureText: true,
                    controller: passwordcontroller,

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black12,

                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Forgotten Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0, top: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text(
                        "Forgotten password?",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Continue Button
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF169F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      loginAndAuthenticateUser(context);
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: 16.0),

                // Sign-up Prompt
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => signup()),
                    );
                  },
                  child: Text(
                    "New User? Sign up",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                SizedBox(height: 30.0),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GuestModeScreen()));
                  },
                  child: Text(
                    "Guest Mode",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  // final FirebaseAuth _aut= FirebaseAuth.instance;

  final Random random = Random();



  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: "Logging you in, Please wait.",
        );
      },
    );

    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Get the user ID
        String userId = firebaseUser.uid;

        // Fetch the user's WMSTYPE from Firebase Realtime Database
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("WMS").child(userId).child("wasteManagementInfo");

        userRef.once().then((DatabaseEvent event) {
          if (event.snapshot.exists) {
            Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;

            if (userData != null && userData['WMSTYPE'] != null) {
              String wmstype = userData['WMSTYPE'];

              // Navigate based on WMSTYPE
              if (wmstype == "BinSale") {
                Navigator.of(context).pushNamedAndRemoveUntil("/binsale", (route) => false);
              } else if (wmstype == "Recycle") {
                Navigator.of(context).pushNamedAndRemoveUntil("/recycle", (route) => false);
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil("/Homepage", (route) => false);
              }

              displayToast("Logged in successfully", context);
            } else {
              Navigator.pop(context);
              displayToast("Error: Unable to retrieve user data", context);
            }
          } else {
            Navigator.pop(context);
            displayToast("Error: User does not exist in the database", context);
          }
        });
      } else {
        Navigator.pop(context);
        displayToast("Error: Unable to log in", context);
      }
    } catch (e) {
      Navigator.pop(context);
      displayToast("Error: ${e.toString()}", context);
    }
  }



  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);

// user created
  }

  GoogleMapController? newGoogleMapController;
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
    new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }


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
}
