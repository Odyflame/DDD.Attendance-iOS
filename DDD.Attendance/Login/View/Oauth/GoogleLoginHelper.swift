//
//  GoogleLoginHelper.swift
//  DDD.Attendance
//
//  Created by Hanteo on 2021/03/14.
//  Copyright © 2021 DDD. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

protocol GoogleLoginDelegate: class {
    func googleLogin(name: String, email: String, credential: AuthCredential)
}

class GoogleLoginHelper: NSObject {
    weak var loginDelegate: GoogleLoginDelegate?
    static let shared = GoogleLoginHelper()
    
    func startSignInWithGoogleFlow() {

        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance()?.presentingViewController.modalPresentationStyle = .fullScreen
        GIDSignIn.sharedInstance()?.signIn()
    }
}

extension GoogleLoginHelper: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // ...
            print("ERROR SIGNING IN TO GOOGLE")
            return
        }
        
        let fullName: String = user.profile.name
        let email: String = user.profile.email
        let idToken: String = user.authentication.idToken
        let accessToken: String = user.authentication.accessToken
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // 여기서 파이어베이스랑 또 커넥트해야한다
        loginDelegate?.googleLogin(name: fullName, email: email, credential: credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("disConnected...")
    }
}
