
import 'dart:io';
import 'package:borlawms/pages/progressdialog.dart';
import 'package:borlawms/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import 'addwmsdetails.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}
TextEditingController _emailcontroller = TextEditingController();
TextEditingController _usernamecontroller = TextEditingController();
TextEditingController _phonecontroller = TextEditingController();
TextEditingController _passwordcontroller = TextEditingController();
File? _riderImage;


final ImagePicker _imagePicker = ImagePicker();
class _signupState extends State<signup> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery
        .of(context)
        .size;
    return   Scaffold(
      // appBar: AppBar(
      //   title: Text("Login Page"),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [




            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:10,left: 18.0),
                  child: Text("Sign Up",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
                ),

              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text("Sign Up to continue using the app",style: TextStyle(fontSize: 12,color: Colors.grey)),
                ),
              ],
            ),




            _buildImagePicker(
              title: 'Rider Image',
              setImage: (File image) {
                setState(() {
                  _riderImage = image;
                });}),

            Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                // Padding(
                //   padding: EdgeInsets.only(
                //     top: size.width * .1,
                //     bottom: size.width * .1,
                //   ),
                //   child: SizedBox(
                //     height: 70,
                //     child: Image.asset(
                //       'assets/images/logo.png',
                //       // #Image Url: https://unsplash.com/photos/bOBM8CB4ZC4
                //       fit: BoxFit.fitHeight,
                //     ),
                //   ),
                // ),

                //Username
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    height: size.width / 7,

                    alignment: Alignment.center,
                    padding: EdgeInsets.only(right: size.width / 30),
                    decoration: BoxDecoration(
                      color:  Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.grey,                      ),
                      controller: _usernamecontroller,
                      // onChanged: (value){
                      //   _firstName = value;
                      // },
                      // obscureText: isPassword,
                      // keyboardType: isEmail ? TextInputType.name : TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.account_circle_outlined,
                          color:  Colors.grey,
                        ),
                        border: InputBorder.none,
                        hintMaxLines: 1,
                        hintText:'UserName',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color:  Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    height: size.width / 7,

                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        right: size.width / 30),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      controller: _phonecontroller,
                      // onChanged: (value){
                      //   _phonecontroller = value as TextEditingController;
                      // },

                      keyboardType:  TextInputType.phone ,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        hintMaxLines: 1,
                        hintText: 'Phone Number...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    height: size.width / 7,

                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        right: size.width / 30),
                    decoration: BoxDecoration(
                      color:  Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      controller: _emailcontroller,
                      // onChanged: (value){
                      //   _emailcontroller = value as TextEditingController;
                      // },
                      // obscureText: isPassword,
                      keyboardType:  TextInputType.emailAddress ,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey
                        ),
                        border: InputBorder.none,
                        hintMaxLines: 1,
                        hintText: 'Email...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),


//pass
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    height: size.width / 7,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        right: size.width / 30),
                    decoration: BoxDecoration(
                      color:  Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      controller: _passwordcontroller,
                      obscureText: true,
                      // onChanged: (value){
                      //   _passwordcontroller=value as TextEditingController;
                      // },
                      // keyboardType: isPassword ? TextInputType.name : TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.password,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        hintMaxLines: 1,
                        hintText: 'Password...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),



                SizedBox(height: size.width * 0.019),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                 // registerInfirestore(context);
                  registerNewUser(context);
                    HapticFeedback.lightImpact();

                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: size.width * .05,
                    ),
                    height: size.width / 8,
                    width: size.width / 1.25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:  Color(0xFFF169F00),
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
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:9.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already Signed-Up,Login?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => signin(),
                            ),);
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


          ],
        ),
      ),
    );;
  }
  User ?firebaseUser;
  User? currentfirebaseUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Widget _buildImagePicker({required String title, required Function(File) setImage}) {
    return Column(
      children: <Widget>[
        Text("ProfileImage",style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height: 14),

        CircleAvatar(
          radius: 50, // Adjust the radius as needed
          backgroundColor: Colors.blue, // Background color of the avatar
          child: _riderImage != null
              ? ClipOval(
            child: Image.file(
              _riderImage!,
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              fit: BoxFit.cover, // Adjust the BoxFit as needed
            ),
          )
              : GestureDetector(
            onTap: () {
              _pickImage(ImageSource.gallery, setImage);
            },

            child: ClipOval(
              child: Image.asset(
                "assets/images/imgicon.png",
                width: 100, // Adjust the width as needed
                height: 100, // Adjust the height as needed
                fit: BoxFit.cover, // Adjust the BoxFit as needed
              ),
            ),
          ),
        ),
        SizedBox(height: 10),

        // _buildImagePreview(setImage),
        // ElevatedButton(
        //   onPressed: () {
        //     _pickImage(ImageSource.gallery, setImage);
        //   },
        //   child: Text('Pick from Gallery'),
        // ),
        // ElevatedButton(
        //   onPressed: () {
        //     _pickImage(ImageSource.camera, setImage);
        //   },
        //   child: Text('Take a Photo'),
        // ),
      ],
    );
  }

  Future<String> _uploadImageToStorage(File? imageFile) async {
    if (imageFile == null) {
      return ''; // Return an empty string if no image is provided
    }

    final Reference storageReference =
    FirebaseStorage.instance.ref().child('profile_images/${DateTime.now().toString()}');
    final UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() => null);
    final String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }
  Future<void> registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering,Please wait.....",
          );
        });


    firebaseUser = (await _firebaseAuth
        .createUserWithEmailAndPassword(
        email: _emailcontroller.text,
        password: _passwordcontroller.text,)
        .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;
    final riderImageUrl = await _uploadImageToStorage(_riderImage);

    if (firebaseUser != null) // user created

        {
      //save use into to database
      await firebaseUser?.sendEmailVerification();
      Map userDataMap = {
        'riderImageUrl': riderImageUrl,
        "email": _emailcontroller.text.trim(),
        "Username":_usernamecontroller.text.trim(),
        "phone": _phonecontroller.text.trim(),
        "Password": _passwordcontroller.text.trim(),
        // 'Date Of Birth': selectedDate!.toLocal().toString().split(' ')[0],
        // "Dob":birthDate,
        // "Gender":Gender,
      };
      WMSDB.child(firebaseUser!.uid).set(userDataMap);
      // Admin.child(firebaseUser!.uid).set(userDataMap);

      currentfirebaseUser = firebaseUser;
      // registerInfirestore(context);
      displayToast("Congratulation, your account has been created", context);
      // displayToast("A verification has been sent to your mail", context);


      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Addwmsdetails()),
              (Route<dynamic> route) => false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return signin();
        }),
      );
      // Navigator.pop(context);
      //error occured - display error
      displayToast("user has not been created", context);
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File) setImage) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      setImage(File(pickedFile.path));
    }
  }

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);

// user created

  }
}
