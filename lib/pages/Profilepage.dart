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
        //
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert),
        //     onPressed: () {},
        //   ),
        // ],
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

                ProfileMenuItem(
                  title: "Delete Account",
                  icon: Icons.delete,
                  onTap: () async {
                    try {
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        final uid = user.uid;

                        // Delete user data from Realtime Database
                        await FirebaseDatabase.instance.ref().child("WMS").child(uid).remove();

                        // Delete user authentication account
                        await user.delete();

                        // Optionally navigate or notify
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Account and data deleted successfully.')),
                        );

                        // Example navigation
                        // Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No user is currently signed in.')),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'requires-recent-login') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please re-authenticate to delete your account.')),
                        );
                        // Redirect to re-authentication logic
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete account: ${e.message}')),
                        );
                      }
                    }
                  },
                ),

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
