import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        print("🚀 AppDelegate didFinishLaunching")

        // 🔥 Firebase (guarded: Dart may have already configured it)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        print("✅ Firebase configured")

        // 🗺 Google Maps
        GMSServices.provideAPIKey("AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U")
        print("✅ Google Maps configured")

        // 🔔 Notifications — set delegate BEFORE requesting permission
        UNUserNotificationCenter.current().delegate = self
        print("🔎 UNUserNotificationCenter delegate set to: \(String(describing: UNUserNotificationCenter.current().delegate))")

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied: \(error?.localizedDescription ?? "unknown error")")
            }
        }

        application.registerForRemoteNotifications()
        print("✅ Registered for remote notifications")

        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        // 🔎 Re-check delegate AFTER Flutter + plugins have initialized.
        // If this prints something other than AppDelegate, a plugin has hijacked it.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let delegate = UNUserNotificationCenter.current().delegate
            print("🔎 Delegate AFTER Flutter init: \(String(describing: delegate))")
            if delegate !== self {
                print("⚠️ WARNING: A plugin replaced UNUserNotificationCenter.delegate!")
            }
        }

        return result
    }

    // 🔌 Plugin registration, deferred until the implicit engine is ready
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        print("✅ Plugins registered")
    }

    // 📱 APNs token
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("🍏 APNs token: \(token)")

        // Forward to super so Flutter plugins also receive it
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs registration failed: \(error)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    // 🔥 FCM token
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("🌐 FCM token: \(String(describing: fcmToken))")
        // Optionally push to Dart via method channel here
    }

    // 🔔 FOREGROUND notification handler
    // This is called when a notification arrives while the app is in the foreground.
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 FOREGROUND NOTIFICATION RECEIVED")
        print("📨 Title: \(notification.request.content.title)")
        print("📨 Body:  \(notification.request.content.body)")
        print("📨 UserInfo: \(notification.request.content.userInfo)")

        // Let FlutterAppDelegate / plugins handle their logic too.
        // They will NOT call completionHandler (that's our job below).
        super.userNotificationCenter(center,
                                     willPresent: notification,
                                     withCompletionHandler: { _ in
            // intentionally swallow — we call the real completionHandler ourselves
        })

        // Show banner + sound + badge while app is in foreground.
        // Change to [] if you want silent foreground delivery handled only in Dart.
        completionHandler([.banner, .list, .sound, .badge])
    }

    // 🔔 Notification tap handler (app was in foreground or background, user tapped it)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👆 Notification TAPPED")
        print("📨 UserInfo: \(response.notification.request.content.userInfo)")

        super.userNotificationCenter(center,
                                     didReceive: response,
                                     withCompletionHandler: completionHandler)
    }
}