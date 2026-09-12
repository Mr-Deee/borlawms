import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        print("🚀 AppDelegate didFinishLaunching")

        // 🔥 Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        print("✅ Firebase configured")

        // 🗺 Google Maps
        GMSServices.provideAPIKey("AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U")
        print("✅ Google Maps configured")

        // 🔔 Notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { granted, error in
                    if granted {
                        print("✅ Notification permission granted")
                    } else {
                        print("❌ Notification permission denied: \(error?.localizedDescription ?? "unknown error")")
                    }
                }
            )
        }

        application.registerForRemoteNotifications()
        print("✅ Registered for remote notifications")

        GeneratedPluginRegistrant.register(with: self)
        print("✅ Plugins registered")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 📱 APNs token
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("🍏 APNs token: \(token)")
    }

    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs registration failed: \(error)")
    }

    // 🔥 FCM token
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("🌐 FCM token: \(String(describing: fcmToken))")
    }

    // 🔔 SHOW NOTIFICATIONS WHILE APP IS OPEN
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔🔔🔔 FOREGROUND NOTIFICATION RECEIVED! 🔔🔔🔔")
        print("📨 Notification title: \(notification.request.content.title)")
        print("📨 Notification body: \(notification.request.content.body)")
        completionHandler([.banner, .sound, .badge])
    }
}