import 'package:borla_client/pages/Aboutpage.dart';
import 'package:borla_client/pages/Profilepage.dart';
import 'package:borla_client/pages/Requests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Assistant/assistantmethods.dart';
import 'Model/Client.dart';
import 'Model/Users.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
  }
  @override
  Widget build(BuildContext context) {


    var username = Provider.of<WMS>(context,listen: false).riderInfo?.firstname??"";
    var lclientname = Provider.of<WMS>(context,listen: false).riderInfo?.lastname??"";
    var phoneNumber = Provider.of<WMS>(context,listen: false).riderInfo?.phone??"";
    return Drawer(
      child: ListView(

        children: <Widget>[
          SizedBox(
            height: 180,
            child: DrawerHeader(

              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(

                children: [

                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 120.0, // Adjust the width as needed
                            height: 50, // Adjust the height as needed
                            child: Image.asset(
                              'assets/images/wms.png',
                            ),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          IconButton(
                            onPressed: () {


                              showDialog<void>(
                                context: context,
                                barrierDismissible: false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Sign Out'),
                                    backgroundColor: Colors.white,
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          Text('Are you certain you want to Sign Out?'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Yes',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          print('yes');
                                          FirebaseAuth.instance.signOut();
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, "/SignIn", (route) => false);
                                          // Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        phoneNumber,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.home,color: Colors.green,),
            title: Text('Home',style: TextStyle(color: Colors.black),),
            onTap: () {
              // Handle Home menu item click
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.request_page_rounded,color: Colors.green,),
            title: Text('Request',style: TextStyle(color: Colors.black),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => Requestpage(),
              ),);
              // Handle Settings menu item click
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_3_rounded,color: Colors.green,),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profilepg(),
                ),);

            },
          ),
          ListTile(
            leading: Icon(Icons.info,color: Colors.green),
            title: Text('About'),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutPage(),
                ),);
              // Handle About menu item click
            },
          ),
        ],
      ),
    );
  }
}
