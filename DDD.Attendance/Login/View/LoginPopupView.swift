//
//  LoginPopupView.swift
//  DDD.Attendance
//
//  Created by ParkSungJoon on 15/09/2019.
//  Copyright © 2019 DDD. All rights reserved.
//

import UIKit
import ReactiveSwift
import FirebaseAuth
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended
import GoogleSignIn

class LoginPopupView: BaseView {

    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    private let viewModel = LoginPopupViewModel()
    
    var resultHandler: ((Firebase.LoginStatus) -> Void)?
    
    override func bindData() {
        super.bindData()
        
        loginButton.then {
            $0.isEnabled = false
        }
        
        idTextField.then {
            $0.delegate = self
        }
        
        passwordTextField.then {
            $0.delegate = self
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        reactive.pressAppleLoginButton <~ appleLoginButton.reactive.controlEvents(.touchUpInside)
        
        reactive.pressGoogleLoginButton <~ googleLoginButton.reactive.controlEvents(.touchUpInside)
        
//        reactive.pressLoginButton <~ loginButton.reactive
//            .controlEvents(.touchUpInside)
//
//        reactive.requestFirebaseAuth <~ viewModel.outputs.loginAccount
//
//        reactive.loginResultHandler <~ viewModel.outputs.loginResult
//
//        reactive.isEnabledLoginButton <~ viewModel.outputs.isValidAccount
//
//        reactive.checkValidAccount <~ idTextField.reactive.continuousTextValues
//            .combineLatest(with: passwordTextField.reactive.continuousTextValues)
    }
    
    override func bindStyle() {
        appleLoginButton.imageView?.image = UIImage(named: "signup_info")
        googleLoginButton.imageView?.image = UIImage(named: "signup_info")
        appleLoginButton.layer.cornerRadius = 15
        googleLoginButton.layer.cornerRadius = 15
    }
    
    func failureAction() {
        passwordTextField.text?.removeAll()
        idTextField.becomeFirstResponder()
    }
}

private extension LoginPopupView {
    
    func pressLoginButton() {
        endEditing(true)
        viewModel.inputs.pressLoginButton()
        startIndicator()
    }
    
    func pressAppleLoginButton() {
        AppleLoginHelper.shared.setDelegate(self)
        AppleLoginHelper.shared.startSignInWithAppleFlow()
        startIndicator()
    }
    
    func pressGoogleLoginButton() {
        GIDSignIn.sharedInstance()?.signIn()
        startIndicator()
    }
    
    func startIndicator() {
        if !NVActivityIndicatorPresenter.sharedInstance.isAnimating {
            let activityData = ActivityData(type: .pacman)
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        }
    }
    
    func requestFirebaseAuth(with account: (String, String)) {
        viewModel.inputs.requestFirebaseAuth(with: account)
    }
    
    func checkValidAccount(with account: (String, String)) {
        viewModel.inputs.checkValidAccount(with: account)
    }
    
    func isEnabledLoginButton(with isValid: Bool) {
        loginButton.isEnabled = isValid
    }
    
    func requestAppleLogin(credential: String, name: String) {
        
    }
    
    func requestSignUp() {
        
    }
}

extension LoginPopupView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}

extension Reactive where Base: LoginPopupView {
    
    var pressLoginButton: BindingTarget<UIButton> {
        return makeBindingTarget({ base, _ in
            base.pressLoginButton()
        })
    }
    
    var pressAppleLoginButton: BindingTarget<UIButton> {
        return makeBindingTarget({ base, _ in
            base.pressAppleLoginButton()
        })
    }
    
    var pressGoogleLoginButton: BindingTarget<UIButton> {
        return makeBindingTarget({ base, _ in
            base.pressGoogleLoginButton()
        })
    }
    
    var requestFirebaseAuth: BindingTarget<(String, String)> {
        return makeBindingTarget({ base, account in
            base.requestFirebaseAuth(with: account)
        })
    }
    
    var loginResultHandler: BindingTarget<Firebase.LoginStatus> {
        return makeBindingTarget({ base, status in
            base.resultHandler?(status)
        })
    }
    
    var checkValidAccount: BindingTarget<(String, String)> {
        return makeBindingTarget({ base, account in
            base.checkValidAccount(with: account)
        })
    }
    
    var isEnabledLoginButton: BindingTarget<Bool> {
        return makeBindingTarget({ base, isValid in
            base.isEnabledLoginButton(with: isValid)
        })
    }
}

extension LoginPopupView: AppleLoginDelegate {
    func login(name: String, email: String, credential: AuthCredential) {
        
    }
}

extension LoginPopupView: GoogleLoginDelegate {
    func googleLogin(name: String, email: String, credential: AuthCredential) {
            
    }
}
