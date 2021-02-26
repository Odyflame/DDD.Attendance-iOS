//
//  AppleLoginHelper.swift
//  DDD.Attendance
//
//  Created by Hanteo on 2021/02/25.
//  Copyright © 2021 DDD. All rights reserved.
//

import Foundation
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
            self.loginDelegate?.login(userIdentifier: userIdentifier, name: name)
        }
    }
}
