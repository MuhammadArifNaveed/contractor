//
//  AppDelegate.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/22/21.
//

import UIKit
import IQKeyboardManagerSwift
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
}
