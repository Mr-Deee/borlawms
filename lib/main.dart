
import 'package:borlawms/pages/Aboutpage.dart';
import 'package:borlawms/pages/BinSalesPage.dart';
import 'package:borlawms/pages/Profilepage.dart';
import 'package:borlawms/pages/RecyclePage.dart';
import 'package:borlawms/pages/addwmsdetails.dart';
import 'package:borlawms/pages/homepage.dart';
import 'package:borlawms/pages/onboarding.dart';
import 'package:borlawms/pages/signin.dart';
import 'package:borlawms/pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Assistant/helper.dart';
import 'Model/Users.dart';
import 'Model/WMSDB.dart';
import 'Model/appstate.dart';
import 'Model/otherUserModel.dart';
import 'appData.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
    ),
    ChangeNotifierProvider<Users>(
      create: (context) => Users(),
    ),
    ChangeNotifierProvider<WMS>(
      create: (context) => WMS(),
    ),

// ),
    ChangeNotifierProvider<helper>(
      create: (context) => helper(),
    ),

    ChangeNotifierProvider<otherUsermodel>(
      create: (context) => otherUsermodel(),
    ),

    ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
    ),
  ], child: MyApp()));
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Handle the notification here when the app is in the background.
}



final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;
DatabaseReference clientRequestRef = FirebaseDatabase.instance.ref().child(
    "ClientRequest");
DatabaseReference WastemanagementRef = FirebaseDatabase.instance.ref().child(
    "WMS").child(uid!).child("new WMS");
DatabaseReference clients = FirebaseDatabase.instance.ref().child("Clients");
DatabaseReference WMSDB = FirebaseDatabase.instance.ref().child("WMS");
DatabaseReference WMSDBtoken = FirebaseDatabase.instance.ref()
    .child("WMS")
    .child(uid!);
DatabaseReference WMSAvailable = FirebaseDatabase.instance.ref().child(
    "availableWMS").child(uid!);
Future<String> getInitialRoute() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Fetch detailComp value from Firebase
  DatabaseEvent detailCompSnapshot = await FirebaseDatabase.instance
      .ref()
      .child('WMS')
      .child(uid)
      .child('detailsComp')
      .once();

  DatabaseEvent wmstypeSnapshot = await FirebaseDatabase.instance
      .ref()
      .child('WMS')
      .child(uid).child('wasteManagementInfo')
      .child('WMSTYPE')
      .once();

  bool? detailComp = detailCompSnapshot.snapshot.value as bool?;
  String? wmstype = wmstypeSnapshot.snapshot.value as String?;
print('three:$wmstype');
  if (FirebaseAuth.instance.currentUser == null) {
    return '/Onboarding';
  } else if (detailComp == true) {
    // Additional conditional routing based on WMSTYPE
    if (wmstype == "BinSale") {
      return '/binsale';
    } else if (wmstype == "Recycle") {
      return '/recycle';
    } else if (wmstype == "WMS") {
      return '/Homepage';
    }
  }
  return '/addmoredetails'; // Navigate to addmoredetails if detailComp is false or not set
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  void initState() {
    // super.initState();

    final FirebaseMessaging messaging = FirebaseMessaging.instance;


// PROBLEM STARTS HERE
    Future initialize(context) async {
      print("Start here");


      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        // retrieveRideRequestInfo(getRideRequestId(message.data), context);


      });


      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('in the foreground!');
        //retrieveRideRequestInfo(getRideRequestId(message.data), context);
      });


      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        //retrieveRideRequestInfo(getRideRequestId(context), context);
      }
    }
  }


  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(

              decoration: BoxDecoration(
                  color: Colors.white
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/wms.png',
                      // Replace with your app's icon image path
                      width: 200,
                      height: 180,
                      // Optionally, you can add a color filter or other styling here
                    ),
                  ),
                  CircularProgressIndicator()
                ],),
            ); // Or a splash screen
          } else {
            String? initialRoute = snapshot.data;

            // Handle null case if necessary
            if (initialRoute == null) {
              initialRoute = '/Onboarding'; // Or any default route you want to use
            }

            return MaterialApp(
                title: 'BorlApp_wms',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(


                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
                  useMaterial3: true,
                ),


                initialRoute: initialRoute,

                //'/addmoredetails',

                //initialRoute,

                // FirebaseAuth.instance.currentUser == null ? '/Onboarding' : '/Homepage',
                // '/Homepage',
                //'/Onboarding'
                routes: {
                  "/SignUP": (context) => signup(),
                  "/addmoredetails": (context) => Addwmsdetails(),
                  "/Onboarding": (context) => OnBoardingPage(),
                  "/About": (context) => AboutPage(),
                  "/binsale": (context) => BinSalePage(),
                  "/recycle": (context) => RecyclePage(),
                  // "/OnBoarding": (context) => ,
                  "/SignIn": (context) => signin(),
                  "/Profile": (context) => ProfilePage(),
                  "/Homepage": (context) => homepage(),
                  //    "/addproduct":(context)=>addproduct()
                }
            );
          }
        });
  }

  Widget routeGenerator(RouteSettings settings) {
    switch (settings.name) {
      case '/Onboarding':
        return OnBoardingPage();
      case '/Main':
        return homepage();
      case '/addmoredetails':
        return Addwmsdetails();

      case '/SignUP':
        return signup();
      case '/SignIn':
        return signin();
      case '/Homepage':
        return homepage();
      default:
        return Scaffold(
          body: Center(
            child: Text('Route not found: ${settings.name}'),
          ),
        );
    }
  }


}

