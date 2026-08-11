//
//  SceneDelegate.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/22/21.
//

import FirebaseAuth
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // If a user or company is already logged in, skip the login flow and go
        // straight to the drawer/home dashboard.
        if UserDefaultsManager.shared.isUserLoggedIn || UserDefaultsManager.shared.isCompanyLoggedIn {
            // Rehydrate Global session state from persisted user/company info
            if UserDefaultsManager.shared.isUserLoggedIn,
               let storedUser = UserDefaultsManager.shared.userInfo {
                Global.shared.user = storedUser
                // Global.shared.companyVendor = nil  // Temporarily disabled
                Global.shared.isLogedIn = true
                Global.shared.loginType = "user"
            }
            // Companies persist as a `VendorSession` under the "vendor" key, the way Android's
            // `SharedPrefManager.getVendorObject()` works. Without this the flag stays false on a
            // cold launch and a logged-in company lands on the consumer home screen instead of
            // `VendorHomeView`.
            else if let vendor = VendorSession.current, !vendor.id.isEmpty {
                var user = UserViewModel()
                user.id = vendor.id
                user.name = vendor.company_name
                user.phone = vendor.company_phone
                user.userType = vendor.user_type.isEmpty ? "companies" : vendor.user_type
                Global.shared.user = user
                Global.shared.isLogedIn = true
                Global.shared.isVendor = true
                Global.shared.loginType = "company"
            }

            guard let windowScene = (scene as? UIWindowScene) else { return }
            let window = UIWindow(windowScene: windowScene)

            let storyboard = UIStoryboard(name: "Drawer", bundle: nil)
            let root = storyboard.instantiateViewController(withIdentifier: "KYDrawerController") as! KYDrawerController
            window.rootViewController = root
            self.window = window
            window.makeKeyAndVisible()
        } else {
            // Fall back to storyboard-defined initial controller (login flow).
            guard let _ = (scene as? UIWindowScene) else { return }
        }
    }
    /// Phone verification's reCAPTCHA fallback comes back through a custom URL scheme, and on a
    /// scene-based app this is the method that receives it — `AppDelegate.application(_:open:options:)`
    /// is never called once scenes are in play.
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts where Auth.auth().canHandle(context.url) {
            return
        }
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

