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
import 'CustomerSupportService.dart';
import 'WMSBINS.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
      var email = Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "";
      var fclientname = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
      var lclientname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
      var phoneNumber =
          Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           CircleAvatar(
            backgroundColor: Colors.lightGreen,
            radius: 50,
            backgroundImage: AssetImage('assets/images/bwmslogo.png'), // Replace with your image asset
          ),
          const SizedBox(height: 10),
           Text(
            '$fclientname $lclientname',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
           Text(
            '$email',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  EditProfilePage(email: email, firstname: fclientname, lastname: '', phone: phoneNumber, onSave: (RiderInfo updatedInfo) {  },)),
              );
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ProfileMenuItem(
                  icon: Icons.settings,
                  title: 'Bins Management',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>    ViewMyBinsPage()
                      ),);

                  },
                ),
                ProfileMenuItem(
                  icon: Icons.call,
                  title: 'Customer Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>    CustomerSupportService()
                      ),);
                  },
                ),

                // ProfileMenuItem(
                //   icon: Icons.info,
                //   title: 'Information',
                //   onTap: () {},
                // ),
                // ProfileMenuItem(
                //   icon: Icons.logout,
                //   title: 'Log Out',
                //   onTap: () {},
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiderInfo {
  final String firstname;
  final String lastname;
  final String email;
  final String phone;

  RiderInfo({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
  });
}
// Edit Profile Page
class EditProfilePage extends StatelessWidget {
  final String? email;
  final String? firstname;
  final String ?lastname;
  final String? phone;
  final Function(RiderInfo updatedInfo)? onSave;

  EditProfilePage({
     required this.email,
    required this.firstname,
    required  this.lastname,
    required this.phone,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = email!;
    firstnameController.text = firstname!;
    lastnameController.text = lastname!;
    phoneController.text = phone!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.lightGreenAccent,
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/bwmslogo.png'), // Replace with your image asset
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: () {
                            // Handle profile picture update
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final updatedInfo = RiderInfo(
                      firstname: firstnameController.text,
                      lastname: lastnameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );
                    onSave!(updatedInfo);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Settings Page (Menu Item Example)
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// Custom TextField for Edit Profile Page
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;

  const CustomTextField({Key? key, required this.label, required this.hint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
  // @override
  // Widget build(BuildContext context) {
  //   String _deleteMessage = '';
  //   final FirebaseAuth _auth = FirebaseAuth.instance;
  //
  //   void _deleteCurrentUser() {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Confirm Deletion'),
  //           content: Text('Are you sure you want to delete your account?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 // Call delete method and handle messages here
  //                 try {
  //                   final User? user = FirebaseAuth.instance.currentUser;
  //                   if (user != null) {
  //                     await FirebaseDatabase.instance
  //                         .ref()
  //                         .child('users')
  //                         .child(user.uid)
  //                         .remove();
  //                     await user.delete();
  //                     setState(() {
  //                       _deleteMessage = 'User deleted successfully.';
  //                     });
  //                   }
  //                 } catch (e) {
  //                   setState(() {
  //                     _deleteMessage = 'Failed to delete user: $e';
  //                   });
  //                 }
  //               },
  //               child: Text('Delete'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  //
  //   final TextEditingController usernameController = TextEditingController();
  //   final TextEditingController emailController = TextEditingController();
  //   final TextEditingController contactController = TextEditingController();
  //
  //   Future<void> updateProfile() async {
  //     final User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       DatabaseReference userRef =
  //           FirebaseDatabase.instance.ref().child('Clients').child(user.uid);
  //       await userRef.update({
  //         'Username': usernameController.text,
  //         'email': emailController.text,
  //         'phone': contactController.text,
  //       });
  //     }
  //   }
  //

  //   return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: Text(
  //         "Profile",
  //         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //             ),
  //       ),
  //     ),
  //     backgroundColor: Colors.grey.shade200,
  //     body: SafeArea(
  //       child: Stack(
  //         children: [
  //           Container(
  //             height: MediaQuery.of(context).size.height,
  //             width: MediaQuery.of(context).size.width,
  //             decoration: BoxDecoration(
  //               image: DecorationImage(
  //                 image: AssetImage("assets/images/bg.jpeg"),
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //           Positioned.fill(
  //             child: BackdropFilter(
  //               filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
  //               child: Container(
  //                 color: Colors.grey.withOpacity(0.9),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(11.0),
  //             child: Center(
  //               child: Container(
  //                 height: 300,
  //                 width: MediaQuery.of(context).size.width,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(20),
  //                   color: Colors.white,
  //                   // boxShadow: [
  //                   //   BoxShadow(
  //                   //     blurRadius: 1.5,
  //                   //     spreadRadius: 3,
  //                   //     color: Colors.grey.shade100,
  //                   //   ),
  //                   // ],
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     const CircleAvatar(
  //                       backgroundColor: Colors.greenAccent,
  //                       radius: 50,
  //                       child: Icon(
  //                         Icons.person,
  //                         size: 55,
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             lclientname,
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 16,
  //                             ),
  //                           ),
  //                           Text(
  //                             phoneNumber,
  //                             style: TextStyle(
  //                               fontSize: 13,
  //                               color: Colors.black,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 5),
  //                           GestureDetector(
  //                             onTap: () {
  //                               showDialog(
  //                                 barrierDismissible: true,
  //                                 context: context,
  //                                 builder: (BuildContext context) {
  //                                   return AlertDialog(
  //                                     backgroundColor: Colors.white,
  //                                     shape: const RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.vertical(
  //                                         top: Radius.circular(10.0),
  //                                         bottom: Radius.circular(10),
  //                                       ),
  //                                     ),
  //                                     actions: [
  //                                       Column(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.center,
  //                                         children: [
  //                                           const SizedBox(height: 25),
  //                                           const Text(
  //                                             "Edit Profile",
  //                                             style: TextStyle(
  //                                               fontWeight: FontWeight.bold,
  //                                               fontSize: 18,
  //                                             ),
  //                                           ),
  //                                           const SizedBox(height: 25),
  //                                           Form(
  //                                             key: formKey,
  //                                             child: Column(
  //                                               children: [
  //                                                 TextFormWidget(
  //                                                   textInputType:
  //                                                       TextInputType.name,
  //                                                   prefixIcon:
  //                                                       Icons.person_4_rounded,
  //                                                   hintText: 'Username',
  //                                                   controller:
  //                                                       usernameController,
  //                                                 ),
  //                                                 SizedBox(height: 8),
  //                                                 // TextFormWidget(
  //                                                 //   textInputType: TextInputType
  //                                                 //       .emailAddress,
  //                                                 //   prefixIcon: Icons.email,
  //                                                 //   hintText: 'Email',
  //                                                 //   controller: emailController,
  //                                                 // ),
  //                                                 SizedBox(height: 8),
  //                                                 TextFormWidget(
  //                                                   textInputType:
  //                                                       TextInputType.phone,
  //                                                   prefixIcon: Icons
  //                                                       .phone_android_rounded,
  //                                                   hintText: 'Contact',
  //                                                   controller:
  //                                                       contactController,
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                           const SizedBox(height: 14),
  //                                           GestureDetector(
  //                                             onTap: () async {
  //                                               updateProfile();
  //                                               if (formKey.currentState!
  //                                                   .validate()) {
  //                                                 formKey.currentState!.save();
  //                                               }
  //                                             },
  //                                             child: Container(
  //                                               height: 50,
  //                                               width: double.infinity,
  //                                               decoration: BoxDecoration(
  //                                                 color: Colors.green,
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(5),
  //                                               ),
  //                                               child: Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment.center,
  //                                                 children: [
  //                                                   Text(
  //                                                     "Update Profile",
  //                                                     style: Theme.of(context)
  //                                                         .textTheme
  //                                                         .bodyLarge!
  //                                                         .copyWith(
  //                                                           color: Colors.white,
  //                                                           fontWeight:
  //                                                               FontWeight.bold,
  //                                                         ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ],
  //                                   );
  //                                 },
  //                               );
  //                             },
  //                             child: Container(
  //                               height: 30,
  //                               width: 120,
  //                               decoration: BoxDecoration(
  //                                 color: Colors.red,
  //                                 borderRadius: BorderRadius.circular(20),
  //                               ),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 crossAxisAlignment: CrossAxisAlignment.center,
  //                                 children: [
  //                                   const Icon(
  //                                     CupertinoIcons.pen,
  //                                     color: Colors.white,
  //                                     size: 15,
  //                                   ),
  //                                   const SizedBox(width: 5),
  //                                   Text(
  //                                     "Edit Profile",
  //                                     style: Theme.of(context)
  //                                         .textTheme
  //                                         .bodyMedium!
  //                                         .copyWith(
  //                                           fontWeight: FontWeight.bold,
  //                                           fontSize: 13,
  //                                           color: Colors.white,
  //                                         ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                           // const Divider(
  //                           //   thickness: 1,
  //                           //   height: 20,
  //                           // ),
  //                         ],
  //                       ),
  //                     ),
  //
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //
  //         ],
  //       ),
  //     ),
  //   );
  //
  // }
//}
