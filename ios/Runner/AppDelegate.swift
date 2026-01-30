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

    // 🔥 Firebase
    FirebaseApp.configure()
    Messaging.messaging().delegate = self

    // 🗺 Google Maps
    GMSServices.provideAPIKey("AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U")

    // 🔔 Notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound],
        completionHandler: { _, _ in }
      )
    }

    application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)

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
    completionHandler([.banner, .sound, .badge])
  }
}
