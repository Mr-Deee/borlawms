import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/Client.dart';

class Profilepg extends StatefulWidget {
  const Profilepg({super.key});

  @override
  State<Profilepg> createState() => _ProfilepgState();
}

class _ProfilepgState extends State<Profilepg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: ProfileWidget(),
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
            height: 120, // Adjust the height as needed
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

        SizedBox(height: 20),

      ],
    );
  }
}