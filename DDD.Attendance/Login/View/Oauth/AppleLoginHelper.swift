//
//  AppleLoginHelper.swift
//  DDD.Attendance
//
//  Created by Hanteo on 2021/02/25.
//  Copyright © 2021 DDD. All rights reserved.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

protocol AppleLoginDelegate: class {
    func login(userIdentifier: String, name: String)
}

class AppleLoginHelper: NSObject {
    weak var loginDelegate: AppleLoginDelegate?
    
    static let shared = AppleLoginHelper()
    
    func setDelegate(_ loginDelegate: AppleLoginDelegate) {
        self.loginDelegate = loginDelegate
    }
    
    func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

extension AppleLoginHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let name = (appleIDCredential.fullName?.familyName ?? "") + (appleIDCredential.fullName?.givenName ?? "")
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            self.loginDelegate?.login(userIdentifier: userIdentifier, name: name)
        }
    }
}
