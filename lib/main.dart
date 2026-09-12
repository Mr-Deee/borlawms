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
import 'package:permission_handler/permission_handler.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FirebaseAuth auth = FirebaseAuth.instance;

// ✅ FIX: Use getters instead of top-level refs to avoid empty uid issues
DatabaseReference get clientRequestRef =>
    FirebaseDatabase.instance.ref().child("ClientRequest");

DatabaseReference get WastemanagementRef {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return FirebaseDatabase.instance.ref().child("WMS").child("").child("new WMS");
  }
  return FirebaseDatabase.instance.ref().child("WMS").child(user.uid).child("new WMS");
}

DatabaseReference get clients =>
    FirebaseDatabase.instance.ref().child("Clients");

DatabaseReference get WMSDB =>
    FirebaseDatabase.instance.ref().child("WMS");

DatabaseReference get WMSDBtoken {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return FirebaseDatabase.instance.ref().child("WMS").child("");
  }
  return FirebaseDatabase.instance.ref().child("WMS").child(user.uid);
}

DatabaseReference get WMSAvailable {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return FirebaseDatabase.instance.ref().child("availableWMS").child("");
  }
  return FirebaseDatabase.instance.ref().child("availableWMS").child(user.uid);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _requestNotificationPermissions();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppData>(create: (context) => AppData()),
      ChangeNotifierProvider<Users>(create: (context) => Users()),
      ChangeNotifierProvider<ReqModel>(create: (context) => ReqModel()),
      ChangeNotifierProvider<WMS>(create: (context) => WMS()),
      ChangeNotifierProvider<helper>(create: (context) => helper()),
      ChangeNotifierProvider<otherUsermodel>(create: (context) => otherUsermodel()),
      ChangeNotifierProvider<AppState>(create: (context) => AppState()),
    ],
    child: MyApp(),
  ));
}

/// Single place that requests notification permissions, on both platforms.
Future<void> _requestNotificationPermissions() async {
  NotificationSettings settings =
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  print('Notification permission status: ${settings.authorizationStatus}');

  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  if (Platform.isAndroid) {
    final PermissionStatus status = await Permission.notification.request();
    print('Android notification permission: $status');
  }
}

Future<String> getInitialRoute() async {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return '/Onboarding';
  }

  final uid = currentUser.uid;

  try {
    DatabaseEvent detailCompSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('WMS')
        .child(uid)
        .child('detailsComp')
        .once();

    DatabaseEvent wmstypeSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('WMS')
        .child(uid)
        .child('wasteManagementInfo')
        .child('WMSTYPE')
        .once();

    bool? detailComp = detailCompSnapshot.snapshot.value as bool?;
    String? wmstype = wmstypeSnapshot.snapshot.value as String?;
    print('details:$detailComp three:$wmstype');

    if (detailComp == true) {
      if (wmstype == "BinSale") {
        return '/binsale';
      } else if (wmstype == "Recycle") {
        return '/recycle';
      } else if (wmstype == "WMS") {
        return '/Homepage';
      }
    }
    return '/addmoredetails';
  } catch (e) {
    print('Error getting initial route: $e');
    return '/Onboarding';
  }
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
    // ✅ FIX: Initialize FCM after auth state is restored
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeFCM(context);
    });
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
                const CircularProgressIndicator(),
              ],
            ),
          );
        } else {
          String? initialRoute = snapshot.data ?? '/Onboarding';
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'BorlApp_wms',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
              useMaterial3: true,
            ),
            initialRoute: initialRoute,
            routes: {
              "/SignUP": (context) => SignUp(),
              "/addmoredetails": (context) => AddWmsDetails(),
              "/Onboarding": (context) => OnBoardingPage(),
              "/About": (context) => AboutPage(),
              "/binsale": (context) => BinSalePage(),
              "/recycle": (context) => RecyclePage(),
              "/SignIn": (context) => SignIn(),
              "/Profile": (context) => ProfilePage(),
              "/Homepage": (context) => homepage(),
            },
          );
        }
      },
    );
  }
}

Future<void> initializeFCM(BuildContext context) async {
  print("Initializing FCM");

  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      _handleForegroundMessage(message, context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened via notification!');
      _handleMessageTap(message, context);
    });

    final RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageTap(initialMessage, context);
      });
    }

    // ✅ FIX: Wait for Firebase Auth to restore the user
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("FCM: authenticated user = ${user.uid}");
      // ✅ FIX: Add delay for iOS to get APNS token
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 2));
      }
      await _saveCurrentToken();
    } else {
      print("FCM: no authenticated user yet");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM token refreshed");

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("FCM: token refreshed but no authenticated user");
        return;
      }

      await _writeToken(newToken);
    });
  } catch (e) {
    print("Error initializing FCM: $e");
  }
}

Future<void> _saveCurrentToken() async {
  try {
    // ✅ FIX: For iOS, wait a moment for APNS token to be ready
    if (Platform.isIOS) {
      await Future.delayed(const Duration(seconds: 2));
    }

    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    if (token != null && token.isNotEmpty) {
      await _writeToken(token);
    }
  } catch (e) {
    print("Error getting FCM token: $e");
  }
}

Future<void> _writeToken(String token) async {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("⚠️ No authenticated user, cannot store token");
    return;
  }

  try {
    // ✅ CORRECT: Store ONLY the token string
    await FirebaseDatabase.instance
        .ref('WMS')
        .child(currentUser.uid)
        .child('token')
        .set(token);  // ← This should be a String, NOT a Map!

    print('✅ Token stored successfully for user: ${currentUser.uid}');
    print('   Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
  } catch (e) {
    print("❌ Error storing token: $e");
  }
}
void _handleForegroundMessage(RemoteMessage message, BuildContext context) {
  try {
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');

    if (message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'New notification'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    _handleMessageTap(message, context);
  } catch (e) {
    print("Error handling foreground message: $e");
  }
}

void _handleMessageTap(RemoteMessage message, BuildContext context) {
  try {
    final messageType = message.data['type'];
    print("Message type: $messageType");

    if (messageType == 'scheduled') {
      _showScheduledRequestDialog(message, context);
    } else if (messageType == 'immediate') {
      final requestId = message.data['request_id'];
      if (requestId != null && requestId.isNotEmpty) {
        _navigateToRequestDetails(requestId, context);
      }
    }
  } catch (e) {
    print("Error handling message tap: $e");
  }
}

void _showScheduledRequestDialog(RemoteMessage message, BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Scheduled Request'),
      content: Text(message.data['message'] ?? 'You have a new scheduled request'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionAndSchedulePage()),
            );
          },
          child: const Text('View'),
        ),
      ],
    ),
  );
}

void _navigateToRequestDetails(String requestId, BuildContext context) {
  // Navigate to request details screen
  // Navigator.push(context, MaterialPageRoute(builder: (_) => RequestDetailsScreen(requestId: requestId)));
}