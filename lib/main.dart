import 'dart:io';

import 'package:borlawms/Model/RequestModel.dart';
import 'package:borlawms/pages/Aboutpage.dart';
import 'package:borlawms/pages/BinSalesPage.dart';
import 'package:borlawms/pages/Profilepage.dart';
import 'package:borlawms/pages/RecyclePage.dart';
import 'package:borlawms/pages/addwmsdetails.dart';
import 'package:borlawms/pages/homepage.dart';
import 'package:borlawms/pages/onboarding.dart';
import 'package:borlawms/pages/signin.dart';
import 'package:borlawms/pages/signup.dart';
import 'package:borlawms/widgets/Subscriptions&Schedules.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shimmer/main.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);


  // iOS notification permission + foreground display
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
    ),
    ChangeNotifierProvider<Users>(
      create: (context) => Users(),
    ),
    ChangeNotifierProvider<ReqModel>(
      create: (context) => ReqModel(),
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
  // Request permissions for notifications
  await requestNotificationPermissions();

  // Retrieve the APNS token
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.getAPNSToken().then((apnsToken) {
    if (apnsToken != null) {
      print("APNS Token: $apnsToken");
    } else {
      print("APNS Token not set");
    }
  });


  FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
// FIXED: Commented out crashing line
DatabaseReference WastemanagementRef = FirebaseDatabase.instance.ref().child("WMS").child(uid??"").child("new WMS");
DatabaseReference clients = FirebaseDatabase.instance.ref().child("Clients");
DatabaseReference WMSDB = FirebaseDatabase.instance.ref().child("WMS");
// FIXED: Commented out crashing line
DatabaseReference WMSDBtoken = FirebaseDatabase.instance.ref().child("WMS").child(uid??"");
// FIXED: Commented out crashing line
DatabaseReference WMSAvailable = FirebaseDatabase.instance.ref().child(
    "availableWMS").child(uid??"");

Future<String> getInitialRoute() async {
  // FIXED: Added null check to prevent crash
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser == null) {
    return '/Onboarding';
  }
  
  final uid = currentUser.uid;

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


// Future<void> initFCM(String email) async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   // Request permission (iOS)
//   await messaging.requestPermission();
//
//   // Get token
//   String? token = await messaging.getToken();
//   print("✅ Device FCM Token: $token");
//
//   if (token != null) {
//     // Save token under subscriptions (match by email)
//     DatabaseReference ref = FirebaseDatabase.instance.ref("subscriptions");
//
//     DatabaseEvent event = await ref.orderByChild("email").equalTo(email).once();
//
//     if (event.snapshot.value != null) {
//       Map data = event.snapshot.value as Map;
//       data.forEach((key, value) async {
//         await ref.child(key).update({
//           "fcmToken": token,
//         });
//       });
//     }
//   }
//
//
// }



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
initializeFCM(context);

    _requestNotificationPermissions();


  }



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
              "/Homepage": (context) =>homepage()
            },
          );
        }
      },
    );
  }
}
final FirebaseMessaging messaging = FirebaseMessaging.instance;


// Add this to your main widget or app initialization
Future<void> initializeFCM(BuildContext context) async {
  print("Initializing FCM");

  try {
    // Request permissions first
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      _handleForegroundMessage(message, context);
    });

    // Handle when app is opened from background/terminated state via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened via notification!');
      _handleMessageTap(message, context);
    });

    // Handle when app is opened from terminated state via notification
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state via notification');
      // Delay to ensure widget tree is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageTap(initialMessage, context);
      });
    }

    // Get and store FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');

    // Store token in your database if needed
    if (token != null && token.isNotEmpty) {
      // await FirebaseDatabase.instance.ref('users/${userId}/fcmToken').set(token);
    }

  } catch (e) {
    print("Error initializing FCM: $e");
  }
}

void _handleForegroundMessage(RemoteMessage message, BuildContext context) {
  try {
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');

    // Show in-app notification
    if (message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'New notification'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Handle the message content
    _handleMessageTap(message, context);
  } catch (e) {
    print("Error handling foreground message: $e");
  }
}

void _handleMessageTap(RemoteMessage message, BuildContext context) {
  try {
    final messageType = message.data['type'];
    print("Message type: $messageType");

    // Navigate based on message type
    if (messageType == 'scheduled') {
      // Navigate to scheduled request screen or show dialog
      _showScheduledRequestDialog(message, context);
    } else if (messageType == 'immediate') {
      // Handle immediate request
      final requestId = message.data['request_id'];
      if (requestId != null && requestId.isNotEmpty) {
        // Navigate to request details
        _navigateToRequestDetails(requestId, context);
      }
    }
  } catch (e) {
    print("Error handling message tap: $e");
  }
}

void _showScheduledRequestDialog(RemoteMessage message, BuildContext context) {
  // Show dialog or navigate to scheduled request screen
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Scheduled Request'),
      content: Text(message.data['message'] ?? 'You have a new scheduled request'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            // Navigate to scheduled requests screen
            Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionAndSchedulePage()));
          },
          child: Text('View'),
        ),
      ],
    ),
  );
}

void _navigateToRequestDetails(String requestId, BuildContext context) {
  // Navigate to request details screen
  // Navigator.push(context, MaterialPageRoute(builder: (_) => RequestDetailsScreen(requestId: requestId)));
}

// Call this from your main app or splash screen
Future<void> _initNotifications(BuildContext context) async {
  try {
    final pushNotificationService = PushNotificationService();
    await pushNotificationService.initialize(context);
  } catch (e) {
    print("Error initializing push notifications: $e");
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