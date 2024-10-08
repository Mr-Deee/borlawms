
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              Container(
                width: 159.0, // Adjust the width as needed
                height: 120, // Adjust the height as needed
                child: Image.asset(
                  'assets/images/wms.png',
                ),),
          
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 18.0),
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
          
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Text("Login to continue using the app",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
          
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    filled: true,
                    // Set filled to true for a grey background
                    fillColor: Colors.grey[200],
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors.grey), // Set the border color to grey
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors
                              .grey), // Set the border color to grey when focused
                    ),
                  ),
                ),
              ),
          
              SizedBox(
                height: 1,
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.password,
                      color: Colors.grey,
                    ),
                    filled: true,
          
                    // Set filled to true for a grey background
                    fillColor: Colors.grey[200],
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors.grey), // Set the border color to grey
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors
                              .grey), // Set the border color to grey when focused
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 12),
                    child: RichText(
                      text: TextSpan(
                        text: 'Forgotten password?',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                            ),);
                            HapticFeedback.lightImpact();
                            // Fluttertoast.showToast(
                            //   msg: 'Forgotten password! button pressed',
                            // );
                          },
                      ),
                    ),
                  ),
                ],
              ),
              // Implement Apple sign-in button here using the `flutter_apple_sign_in` package.
              Padding(
                padding: const EdgeInsets.only(top: 21.0),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF169F00)),
                    onPressed: () {
                      // sendVerificationCode();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => SMSCodeInputScreen("verificationId"),
                      //   ),
                      // );
                      // _sendVerificationCode();
          
                      loginAndAuthenticateUser(context);
                      // Implement Firebase email/password sign-in logic here
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 9.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'New User? Sign up',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => signup(),
                              ),
                            );
                            HapticFeedback.lightImpact();
                            // Fluttertoast.showToast(
                            //   msg:
                            //   '',
                            // );
                          },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              //
              // ElevatedButton(
              //   onPressed: () {
              //     _handleGoogleSignIn(context);
              //   },
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(
              //           30.0), // Adjust the value to change the roundness
              //     ),
              //   ),
              //   child: Container(
              //     width: 20.0, // Adjust the width as needed
              //     height: 48.0, // Adjust the height as needed
              //     child: Image.asset(
              //       'assets/images/logo.png',
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
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
            message: "Logging you ,Please wait.",
          );
        });

    Future signInWithEmailAndPassword(String email, String password) async {
      try {
        UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
            email: emailcontroller.text.trim(), password: emailcontroller.text.trim());
        User? user = result.user;
        return _firebaseAuth;
      } catch (error) {
        print(error.toString());
        return null;
      }
    }

    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailcontroller.text.trim(),
                password: passwordcontroller.text.trim())
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: emailcontroller.text.trim(), password: passwordcontroller.text.trim());

     if (clients != null) {
       AssistantMethod.getCurrentOnlineUserInfo(context);

       Navigator.of(context).pushNamed("/Homepage");

        displayToast("Logged-in ", context);
      } else {
        displayToast("Error: Cannot be signed in", context);
      }
    } catch (e) {
      // handle error
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
