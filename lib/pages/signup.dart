import 'dart:io';
import 'dart:ui';
import 'package:borlawms/pages/progressdialog.dart';
import 'package:borlawms/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'addwmsdetails.dart';

// Define the DatabaseReference (used later)
final DatabaseReference WMSDB = FirebaseDatabase.instance.ref().child("WMS");

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  // Controllers
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  // Image data: mobile uses File, web uses Uint8List
  dynamic _riderImage; // File? or Uint8List?
  final ImagePicker _imagePicker = ImagePicker();

  User? firebaseUser;
  User? currentfirebaseUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailcontroller.dispose();
    _usernamecontroller.dispose();
    _phonecontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white54.withOpacity(0.5),
                  BlendMode.color,
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 18.0),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          "Sign Up to continue.",
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  _buildImagePicker(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Username
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: size.width / 7,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: size.width / 30),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white70),
                            controller: _usernamecontroller,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.account_circle_outlined, color: Colors.white70),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'UserName',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      // Phone
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: size.width / 7,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: size.width / 30),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white70),
                            controller: _phonecontroller,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone, color: Colors.white70),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Phone Number...',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      // Email
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: size.width / 7,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: size.width / 30),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white70),
                            controller: _emailcontroller,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.white70),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Email...',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      // Password
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: size.width / 7,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: size.width / 30),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white70),
                            controller: _passwordcontroller,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password, color: Colors.white70),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Password...',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.019),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          registerNewUser(context);
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: size.width * .02),
                          height: size.width / 8,
                          width: size.width / 1.25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFF169F00),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Sign-up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already Signed-Up, Login?',
                            style: TextStyle(color: Colors.black),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => signin()),
                                );
                                HapticFeedback.lightImpact();
                              },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Image Picker Widget (cross‑platform)
  // --------------------------------------------------------------------------
  Widget _buildImagePicker() {
    return Column(
      children: [
        Text(
          "Upload Image here⤸",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 11),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white10,
          child: _riderImage != null
              ? ClipOval(
            child: kIsWeb
                ? Image.memory(
              _riderImage as Uint8List,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
                : Image.file(
              _riderImage as File,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          )
              : GestureDetector(
            onTap: () => _pickImage(),
            child: ClipOval(
              child: Image.asset(
                "assets/images/imgicon.png",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Pick image from gallery (works on mobile & web)
  // --------------------------------------------------------------------------
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: read as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _riderImage = bytes;
        });
      } else {
        // Mobile: keep as File
        setState(() {
          _riderImage = File(pickedFile.path);
        });
      }
    }
  }

  // --------------------------------------------------------------------------
  // Upload image to Firebase Storage (supports both File and Uint8List)
  // --------------------------------------------------------------------------
  Future<String> _uploadImageToStorage(dynamic imageData) async {
    if (imageData == null) return '';
    final String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    try {
      if (kIsWeb) {
        // Web: upload bytes
        await storageRef.putData(imageData as Uint8List);
      } else {
        // Mobile: upload file
        await storageRef.putFile(imageData as File);
      }
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      displayToast("Image upload failed: $e", context);
      return '';
    }
  }

  // --------------------------------------------------------------------------
  // Register new user with email/password
  // --------------------------------------------------------------------------
  Future<void> registerNewUser(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Registering, Please wait.....");
      },
    );

    try {
      // 1. Create user with email & password
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );
      firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Upload image (if any)
        final riderImageUrl = await _uploadImageToStorage(_riderImage);

        // 3. Send email verification
        await firebaseUser!.sendEmailVerification();

        // 4. Save user data to Realtime Database
        Map<String, dynamic> userDataMap = {
          'riderImageUrl': riderImageUrl,
          'email': _emailcontroller.text.trim(),
          'Username': _usernamecontroller.text.trim(),
          'phone': _phonecontroller.text.trim(),
          'Password': _passwordcontroller.text.trim(),
          'detailsComp': false,
        };
        await WMSDB.child(firebaseUser!.uid).set(userDataMap);

        currentfirebaseUser = firebaseUser;
        displayToast("Congratulations, your account has been created", context);
        displayToast("A verification email has been sent to your inbox", context);

        // 5. Navigate to next screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Addwmsdetails()),
              (Route<dynamic> route) => false,
        );
      } else {
        // Should not happen, but fallback
        Navigator.pop(context); // dismiss dialog
        displayToast("User creation failed, please try again", context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => signin()));
      }
    } catch (errMsg) {
      // Dismiss loading dialog
      Navigator.pop(context);
      displayToast("Error: ${errMsg.toString()}", context);
    }
  }

  // --------------------------------------------------------------------------
  // Helper: Show toast message
  // --------------------------------------------------------------------------
  void displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}