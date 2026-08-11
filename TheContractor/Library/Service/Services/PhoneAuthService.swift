//
//  PhoneAuthService.swift
//  TheContractor
//
//  The SMS code on sign-up, replicating Android's `VerifyNumber`.
//
//  There is no server-side OTP endpoint on either platform: `Account/phone_check` only reports whether a
//  number is free, and `Account/user_register` accepts whatever number it is handed. **The entire gate is
//  Firebase Phone Auth in the client**, so this file is the gate. Android's flow, which this follows:
//
//  1. `PhoneAuthProvider.verifyPhoneNumber` with a 60-second timeout → the SMS goes out and a
//     verification id comes back.
//  2. The user types the code; `PhoneAuthProvider.getCredential(verificationId, code)` turns the pair
//     into a credential and `signInWithCredential` proves it.
//  3. Only then does the details form open.
//
//  Android also implements `onVerificationCompleted`, which fires when Play Services reads the SMS off
//  the device and fills the field by itself. iOS has no equivalent — the code is always typed — so that
//  callback has no counterpart here.
//
//  Signing in leaves a Firebase Auth session behind, exactly as Android does. Nothing else in either app
//  reads it: the real session is the backend's, stored by `Account/user_register`.
//

import Foundation
import FirebaseAuth

final class PhoneAuthService {
    static let shared = PhoneAuthService()

    private init() {}

    /// Android passes `setTimeout(60L, SECONDS)` and hides its resend button behind a countdown of the
    /// same length.
    static let resendInterval = 60

    /// Returned by `verifyPhoneNumber` and required to build the credential. Held rather than passed
    /// around because the code screen has no use for it beyond handing it straight back.
    private var verificationID: String?

    /// Sends the code. `phoneNumber` must be E.164 — `PhoneNumber.e164` produces it.
    ///
    /// Resending is the same call again: Android rebuilds its options and calls `verifyPhoneNumber` a
    /// second time, so there is no separate entry point here either.
    func sendCode(to phoneNumber: String, completion: @escaping (_ error: String?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] id, error in
            if let error = error {
                completion(PhoneAuthService.message(for: error))
                return
            }
            self?.verificationID = id
            completion(nil)
        }
    }

    /// Confirms the typed code. Success means the number is genuinely the caller's.
    func verify(code: String, completion: @escaping (_ error: String?) -> Void) {
        guard let verificationID = verificationID else {
            completion("Ask for a new code and try again")
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                verificationCode: code)
        Auth.auth().signIn(with: credential) { _, error in
            completion(error.map(PhoneAuthService.message(for:)))
        }
    }

    /// Drops the stored verification id, so a number that is re-entered starts a fresh verification
    /// rather than being checked against the previous number's code.
    func reset() {
        verificationID = nil
    }

    // MARK: - Errors

    /// Firebase's own messages are written for developers ("The SMS code has expired. Please re-send the
    /// verification code to try again."), and two of the cases are configuration problems that would
    /// otherwise reach a user as gibberish.
    private static func message(for error: Error) -> String {
        let nsError = error as NSError

        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }

        switch code {
        // `.internalError` is Firebase's catch-all, and its message is literally "An internal error has
        // occurred, print and inspect the error details for more information" — which tells a user
        // nothing and a developer only where to look. The server's own reason is in the userInfo, but
        // **which key holds it depends on which wrapper the SDK reached for**: `unexpectedErrorResponse`
        // has four overloads, storing the parsed JSON, the raw body, an underlying error, or some
        // combination. All three are worth trying. `CONFIGURATION_NOT_FOUND`, for instance, means
        // Firebase Authentication has never been enabled on the project.
        case .internalError:
            guard let reason = serverReason(in: nsError) else { return error.localizedDescription }
            return "Verification failed: \(reason)"
        case .invalidVerificationCode:
            return "That code is not right. Check it and try again."
        case .sessionExpired:
            return "That code has expired. Ask for a new one."
        case .invalidPhoneNumber, .missingPhoneNumber:
            return "That mobile number is not valid."
        case .quotaExceeded, .tooManyRequests:
            return "Too many attempts. Try again later."
        case .networkError:
            return "No connection. Check your network and try again."
        // The app could not prove to Firebase that it is the real app. On a device that means APNs is
        // not wired up for this Firebase project; on the simulator it means the number being used is not
        // one of the console's test numbers. Either way it is a setup fault, not something the person
        // holding the phone can fix, so say so rather than blaming their number.
        case .appNotVerified, .missingAppToken, .invalidAppCredential, .notificationNotForwarded,
             .captchaCheckFailed:
            return "Verification is not set up for this app yet. Please contact support."
        default:
            return error.localizedDescription
        }
    }

    /// Digs the backend's own message out of a wrapped Auth error, whichever way the SDK stashed it:
    /// the deserialized JSON, the raw response body, or a nested underlying error.
    private static func serverReason(in error: NSError) -> String? {
        func message(in any: Any?) -> String? {
            guard let dictionary = any as? [String: Any] else { return nil }
            if let message = dictionary["message"] as? String, !message.isEmpty { return message }
            if let nested = dictionary["error"] as? [String: Any],
               let message = nested["message"] as? String, !message.isEmpty { return message }
            return nil
        }

        if let reason = message(in: error.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"]) {
            return reason
        }
        if let data = error.userInfo["FIRAuthErrorUserInfoDataKey"] as? Data,
           let reason = message(in: try? JSONSerialization.jsonObject(with: data)) {
            return reason
        }
        if let underlying = error.userInfo[NSUnderlyingErrorKey] as? NSError {
            return serverReason(in: underlying) ?? underlying.localizedDescription
        }
        return nil
    }
}
