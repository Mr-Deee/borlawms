import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/BorlaRequests.dart';
import '../Model/Users.dart';
import '../Model/WMSDB.dart';

class Requestpage extends StatefulWidget {
  const Requestpage({super.key});

  @override
  State<Requestpage> createState() => _RequestpageState();
}

class _RequestpageState extends State<Requestpage> {
  var username;
  void initState() {
    username=  Provider.of<WMS>(context, listen: false).riderInfo?.firstname;

    super.initState();
    // getPicture();

    _fetchUserRequests();


  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Request> _userRequests = [];

  Future<void> _fetchUserRequests() async {
    if (_auth.currentUser != null) {
      print("1gg+'${username}'");
      final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('ClientRequest');

      final DatabaseEvent event = await databaseReference
          .orderByChild('WMS_name')
          .equalTo(username)
          .once();

      print("ggg" + '${username}');

      List<Request> requests = [];

      if (event.snapshot.value != null&& event.snapshot.value is Map) {
        ( event.snapshot.value as Map).forEach((key, value) {
          // Assuming Request class has appropriate constructor to extract data
          // Adjust this part based on your actual Request class structure
          Request request = Request(
            title: value['client_name'],
            description: value['created_at'],
          );
          requests.add(request);
        });
      }

      setState(() {
        _userRequests = requests;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // username = Provider.of<Users>(context,listen: false).userInfo?.Username??"";
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return  Scaffold(

      body: Column(
        children: [
          SizedBox(height: 45,),
          Column( children: [Text("Borla Requests",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),)]),
          SizedBox(
            height: screenWidth / 0.67,

            child: ListView.builder(
              itemCount: _userRequests.length,
              itemBuilder: (context, index) {
                final request = _userRequests[index];
                return Card(
                  elevation: 4, // Controls the shadow of the card.
                  margin: EdgeInsets.all(16), // Margin around the card.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners.
                  ),
                  child: ListTile(
                    title: Text(request.title),
                    subtitle: Text(request.description),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }





}
