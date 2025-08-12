
import 'dart:io';

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
import 'package:flutter/foundation.dart';
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
import 'notifications/pushNotificationService.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize push notification service
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // iOS-specific setup
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads-up notification
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

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

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("Notification permission denied");
  } else {
    print("Notification permission granted");
    // saveFCMToken(); // Fetch token after permission is granted
  }
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
    .child("WMS").child(uid!);
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
  print('object:$uid');
  bool? detailComp = detailCompSnapshot.snapshot.value as bool?;
  String? wmstype = wmstypeSnapshot.snapshot.value as String?;
  print('details:$detailComp');
print('three:$wmstype');

  if (FirebaseAuth.instance.currentUser == null) {
    return '/Onboarding';
  } else if (detailComp == true) {
    print('detail$detailComp');
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


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();


    _requestNotificationPermissions();


  }

  // Future<void> initializeFCM(BuildContext context) async {
  //   print("Initializing FCM");
  //
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Got a message whilst in the foreground!');
  //     PushNotificationService._handleMessage;
  //     // Handle foreground notification
  //   });
  //
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print('App opened via notification!');
  //     // Handle background/opened app notification
  //   });
  //
  //   final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  //   if (initialMessage != null) {
  //     // Handle notification that opened the app from terminated state
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/wms.png',
                  width: 200,
                  height: 180,
                ),
                CircularProgressIndicator(),
              ],
            ),
          );
        } else {
          String? initialRoute = snapshot.data ?? '/Onboarding';
          return MaterialApp(
            title: 'BorlApp_wms',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
              useMaterial3: true,
            ),
            initialRoute: initialRoute,
            routes: {
              "/SignUP": (context) => signup(),
              "/addmoredetails": (context) => Addwmsdetails(),
              "/Onboarding": (context) => OnBoardingPage(),
              "/About": (context) => AboutPage(),
              "/binsale": (context) => BinSalePage(),
              "/recycle": (context) => RecyclePage(),
              "/SignIn": (context) => signin(),
              "/Profile": (context) => ProfilePage(),
              "/Homepage": (context) => homepage(),
            },
          );
        }
      },
    );
  }
}
final FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> initializeFCM(BuildContext context) async {
  print("Initializing FCM");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    // Handle foreground notification
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App opened via notification!');
    // Handle background/opened app notification
  });

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Handle notification that opened the app from terminated state
  }
}

void setupFCMTokenListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    // saveFCMToken(); // Save new token when it changes
  }).onError((err) {
    print("FCM Token Refresh Error: $err");
  });
}

Future<void> _requestNotificationPermissions() async {
  if (Platform.isIOS) {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Notification permissions granted: ${settings.authorizationStatus}');
  }
}
