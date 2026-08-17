//
//  AppDelegate.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/22/21.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseAuth
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
 var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true

        // Android configures Firebase through the google-services plugin; on iOS it is this call plus
        // GoogleService-Info.plist in the bundle. Everything Firebase-backed depends on it: the SMS code
        // on sign-up (Auth), chat (Firestore), and the `firebase_token` the backend pushes to
        // (Messaging).
        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications(application)

        return true
    }

    // MARK: - Push registration

    /// Android asks for the token on start and sends it with login and registration. iOS has to ask the
    /// user for permission first; the token arrives either way, so a declined prompt still lets the
    /// backend store one — it simply cannot deliver an alert.
    private func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("push authorisation failed: \(error.localizedDescription)")
            }
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Messaging needs the APNs token to mint an FCM one.
        Messaging.messaging().apnsToken = deviceToken
        // Auth needs it too, for a different reason: phone verification proves the app is genuine by
        // having Firebase send it a silent push. Without this the SMS step falls back to a reCAPTCHA
        // page in a browser. `.unknown` lets the SDK read sandbox-vs-production off the provisioning
        // profile rather than us hardcoding it per build.
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    /// The silent push that proves the app is genuine during phone verification. Returning early when
    /// Auth claims it keeps that internal message out of the rest of the notification handling.
    ///
    /// This method is why `Info.plist` declares `UIBackgroundModes = [remote-notification]`. iOS logged
    /// a warning on every launch without it, and the consequence is not cosmetic: a silent push cannot
    /// wake the app, so Firebase Phone Auth falls back to the reCAPTCHA browser flow instead of
    /// verifying silently — the same fallback seen on the simulator, but on real devices too.
    ///
    /// If App Review asks what the background mode is for, that is the answer: silent notifications for
    /// Firebase phone-authentication app verification. It is not used for background content fetching.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.noData)
    }

    /// The reCAPTCHA fallback's callback, for when there is no APNs token to verify the app with — a
    /// simulator, or a build whose Firebase project has no APNs key. The scheme it returns on is
    /// registered in Info.plist as `app-<GOOGLE_APP_ID with colons as dashes>`; `PhoneAuthProvider`
    /// calls `fatalError` outright if that scheme is missing, so it is not optional.
    ///
    /// This app is scene-based, so `SceneDelegate.scene(_:openURLContexts:)` is what actually fires;
    /// this stays for completeness and for any pre-scene path.
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Auth.auth().canHandle(url)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("remote notification registration failed: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

// MARK: - Firebase Messaging

extension AppDelegate: MessagingDelegate {

    /// The registration token, which is what `firebase_token` on every login and registration call is
    /// supposed to carry. Until now iOS sent the literal `"testtoken123"`, so the backend held a token it
    /// could never deliver to. It is cached because the token can arrive before or after a sign-in.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken, !fcmToken.isEmpty else { return }
        Global.shared.fcmToken = fcmToken

        // Android subscribes every install to `toAll` in `Home.subscribeFirebaseToken()`, ungated, so a
        // broadcast sent to that topic reaches every Android device and — until now — no iOS one. This
        // is separate from the token-addressed push problem: fixing delivery would not have helped,
        // because the app was never in the topic.
        //
        // Subscribing here rather than at launch because a topic subscription needs a registration
        // token to exist; this callback is the first moment one does.
        Messaging.messaging().subscribe(toTopic: "toAll") { error in
            if let error = error {
                print("toAll topic subscription failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Notification presentation

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Android shows chat notifications while the app is open; iOS suppresses them by default.
        completionHandler([.banner, .list, .sound])
    }

    /// A tapped notification. This is the one callback Android's `PendingIntent` stands in for, and it
    /// fires for both a running app and a cold launch from the lock screen — the delegate is set in
    /// `didFinishLaunching`, before the launch notification is delivered. On a cold launch the
    /// container does not exist yet, which `PushRouter` handles by holding the payload.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        PushRouter.handle(response.notification.request.content.userInfo)
        completionHandler()
    }
}
