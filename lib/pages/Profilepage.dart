import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/WMSDB.dart';


class Profilepg extends StatefulWidget {
  const Profilepg({super.key});

  @override
  State<Profilepg> createState() => _ProfilepgState();
}

class _ProfilepgState extends State<Profilepg> {
  String _deleteMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _deleteCurrentUser() async {
    try {
      // Get current user
      User? user = _auth.currentUser;

      // Delete the user
      await user!.delete();

      setState(() {
        _deleteMessage = 'User deleted successfully.';
      });
    } catch (e) {
      setState(() {
        _deleteMessage = 'Failed to delete user: $e';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          ProfileWidget(),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _deleteCurrentUser,
                  child: Text('Delete Current User'),
                ),
                SizedBox(height: 120),
                Text(_deleteMessage),
              ],
            ),
          ),

        ],
      ),
    );

  }
}

class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var email = Provider.of<WMS>(context,listen: false).riderInfo?.email??"";
    var lclientname = Provider.of<WMS>(context,listen: false).riderInfo?.firstname??"";
    var phoneNumber = Provider.of<WMS>(context,listen: false).riderInfo?.phone??"";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: 239.0, // Adjust the width as needed
            height: 190, // Adjust the height as needed
            child: Image.asset(
              'assets/images/wms.png',
            ),),
        ),

        SizedBox(height: 10),
        Text(
          lclientname,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(email,style: TextStyle(fontSize: 19),),
        Text(phoneNumber),

        SizedBox(height: 120),

      ],
    );
  }

}