import UIKit
import Firebase
import FirebaseMessaging
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {


  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Initialize Firebase
    FirebaseApp.configure()

    // Set Messaging delegate
    Messaging.messaging().delegate = self

    // Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyC6UDM8O3wlMa5SNLHfcM8MGEFJ3ejc55U")

    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self
    requestNotificationAuthorization(application: application)

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Request notification authorization
  private func requestNotificationAuthorization(application: UIApplication) {
    let center = UNUserNotificationCenter.current()
    center.delegate = self

    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    center.requestAuthorization(options: options) { granted, error in
      if let error = error {
        print("❌ Notification permission error: \(error.localizedDescription)")
      } else {
        print("✅ Notification permission granted: \(granted)")
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      }
    }
  }

  // MARK: - APNs Registration
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("📲 Registered for APNs with device token.")
  }

  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
  }

  // MARK: - Firebase Messaging Token
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 Firebase Messaging token: \(String(describing: fcmToken))")
  }

  // MARK: - Foreground Notification Handling
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }

  // MARK: - Notification Tap Handling
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}
