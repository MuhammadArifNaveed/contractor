//
//  ChatAuthService.swift
//  TheContractor
//
//  The iOS half of locking down Firestore. Step 2 of the three in the header of `firestore.rules`.
//
//  Chat identity in this app is the backend's account `uuid` — `user_uuid` for a consumer,
//  `company_uuid` for a company. Firestore can only scope a query by `request.auth`, a Firebase Auth
//  identity, and the app has never had one for chat. That is the whole reason `firestore.rules` has to
//  leave reads open: there is nothing to match a uuid against.
//
//  The fix is for the backend to mint a Firebase **custom token** at login, with the account uuid as
//  the Firebase uid, and for the app to sign in with it. Then `request.auth.uid == resource.data
//  .user_uuid` works and the `participantsOnly` rules at the bottom of `firestore.rules` can be
//  deployed.
//
//  **The backend does not mint tokens yet.** This is wired and dormant: it reads a token from the login
//  response if one is there, and does nothing at all if it is not — which is every login today. When the
//  backend adds the field, iOS needs no further change.
//
//  Deliberately off the login critical path. It runs *after* a login has already succeeded, reports
//  only to the console, and its failure cannot reach the user or stop them getting in. Signing in to
//  the app must not depend on a Firebase round trip.
//
//  Not exercised end to end — no token exists to exercise it with. What is verified is the negative
//  case, which is the one that runs today: a login response without the field leaves this a no-op.
//

import Foundation
import FirebaseAuth
import SwiftyJSON

enum ChatAuthService {

    /// The key the backend is expected to add to the login response. Named to match the `firebase_token`
    /// / `firebase_token_device` fields already on the user record, so it reads as one family.
    ///
    /// If the backend ships a different name, this is the only line that changes.
    static let tokenKey = "firebase_custom_token"

    /// Called after a successful app login, with the whole login response. Signs in to Firebase Auth if
    /// the response carries a custom token; otherwise does nothing.
    static func signIn(fromLoginResponse json: JSON?) {
        guard let json = json else { return }

        // The token may sit at the top level or inside the account object, depending on how the backend
        // adds it. Checking both costs nothing and saves a round trip of "it's there but iOS can't see
        // it" when it does land.
        let token = [json[tokenKey],
                     json["user"][tokenKey],
                     json["Vendor"][tokenKey]]
            .compactMap { $0.string }
            .first { !$0.isEmpty }

        guard let token = token else { return }

        Auth.auth().signIn(withCustomToken: token) { result, error in
            if let error = error {
                // Chat still works — the rules are open. This only matters once the participant-scoped
                // rules are live, at which point a failure here means an empty inbox rather than a
                // broken app, and this line is where to start looking.
                print("Firebase chat sign-in failed: \(error.localizedDescription)")
                return
            }
            print("Firebase chat sign-in ok, uid \(result?.user.uid ?? "?")")
        }
    }

    /// Called from the app's sign-out. Without this the Firebase session outlives the app session, and
    /// the next account to sign in on the device would read the previous one's threads for as long as
    /// the stale token stayed valid.
    ///
    /// Signing out of Firebase when never signed in is a no-op that throws, hence the `try?`.
    static func signOut() {
        try? Auth.auth().signOut()
    }
}
