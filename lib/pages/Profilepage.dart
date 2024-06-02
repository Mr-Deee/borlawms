


import 'dart:ui';

import 'package:borlawms/Model/WMSDB.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

// import '../../constants/color_constants.dart';
import '../Model/Users.dart';
import '../widgets/textform_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String _deleteMessage = '';
    final FirebaseAuth _auth = FirebaseAuth.instance;




    void _deleteCurrentUser() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete your account?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Call delete method and handle messages here
                  try {
                    final User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseDatabase.instance.ref().child('users').child(user.uid).remove();
                      await user.delete();
                      setState(() {
                        _deleteMessage = 'User deleted successfully.';
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _deleteMessage = 'Failed to delete user: $e';
                    });
                  }
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    }
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController contactController = TextEditingController();


    Future<void> updateProfile() async {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Clients').child(user.uid);
        await userRef.update({
          'Username': usernameController.text,
          'email': emailController.text,
          'phone': contactController.text,
        });
      }
    }


    var email = Provider.of<WMS>(context,listen: false).riderInfo?.email??"";
    var lclientname = Provider.of<WMS>(context,listen: false).riderInfo?.firstname??"";
    var phoneNumber = Provider.of<WMS>(context,listen: false).riderInfo?.phone??"";
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: Colors.grey.withOpacity(0.9),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    // boxShadow: [
                    //   BoxShadow(
                    //     blurRadius: 1.5,
                    //     spreadRadius: 3,
                    //     color: Colors.grey.shade100,
                    //   ),
                    // ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          size: 55,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              lclientname,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10.0),
                                          bottom: Radius.circular(10),
                                        ),
                                      ),
                                      actions: [
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 25),
                                            const Text(
                                              "Edit Profile",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            Form(
                                              key: formKey,
                                              child:  Column(
                                                children: [
                                                  TextFormWidget(
                                                    textInputType:
                                                    TextInputType.name,
                                                    prefixIcon:
                                                    Icons.person_4_rounded,
                                                    hintText: 'Username', controller: usernameController,
                                                  ),
                                                  SizedBox(height: 8),
                                                  // TextFormWidget(
                                                  //   textInputType: TextInputType
                                                  //       .emailAddress,
                                                  //   prefixIcon: Icons.email,
                                                  //   hintText: 'Email',
                                                  //   controller: emailController,
                                                  // ),
                                                  SizedBox(height: 8),
                                                  TextFormWidget(
                                                    textInputType:
                                                    TextInputType.phone,
                                                    prefixIcon: Icons
                                                        .phone_android_rounded,
                                                    hintText: 'Contact', controller: contactController,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            GestureDetector(
                                              onTap: () async {
                                                updateProfile();
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  formKey.currentState!.save();
                                                }
                                              },
                                              child: Container(
                                                height: 50,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Update Profile",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 30,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.pen,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Edit Profile",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      ElevatedButton(
                        onPressed: _deleteCurrentUser,
                        child: Column(
                          children: [
                            Text('Delete Current User'), Text(_deleteMessage)
                          ],
                        ),
                      ),
                      //     SizedBox(height: 120),
                      //    ,
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }



}