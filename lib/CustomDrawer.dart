
import 'package:borlawms/pages/Aboutpage.dart';
import 'package:borlawms/pages/Profilepage.dart';
import 'package:borlawms/pages/Requests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Assistant/assistantmethods.dart';
import 'Model/Users.dart';
import 'Model/WMSDB.dart';


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
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(

              children: [
                Row(
                  children: [
                    Container(
                      width: 118.0, // Adjust the width as needed
                      height: 43, // Adjust the height as needed
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
                          fontSize: 25,
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
                                        context, "/signin", (route) => false);
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
                Row(
                  children: [
                    Text(
                      phoneNumber,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.home,color: Colors.green,),
          //   title: Text('Home',style: TextStyle(color: Colors.black),),
          //   onTap: () {
          //     // Handle Home menu item click
          //     Navigator.pop(context);
          //   },
          // ),




          const SizedBox(height: 9),
          ListTile(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Requestpage(),
                ),);
            },
            leading: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.fire_truck_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            title: const Text(
              "My requests",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ),

          const SizedBox(height: 19),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const ProfilePage()),
                  ));
            },
            leading: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  CupertinoIcons.person_alt_circle,
                  color: Colors.white,
                ),
              ),
            ),
            title: const Text(
              "Profile",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ),


          const SizedBox(height: 19),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutPage(),
                ),);
            },
            leading: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            title: const Text(
              "About",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              thickness: 1,
              height: 20,
            ),
          ),


          const SizedBox(height: 19),
          ListTile(
            onTap: () {
              Navigator.pop(context);
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          const Text(
                            "Confirm logout",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text("Are you sure you want to logout?"),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: MaterialButton(
                                  onPressed: () {
                                    // AuthenticationRepository.instance
                                    //     .logout();
                                  },
                                  color: Colors.green,
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: MaterialButton(
                                  onPressed: () {
                                    //Get.back();
                                  },
                                  color: Colors.red,
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.shade100,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.logout,
                ),
              ),
            ),
            title: const Text(
              "Log out",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(left: 17.0),
            child: Row(
              children: [
                Text(
                  "BorlaGh v1.1",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );

  }
}
