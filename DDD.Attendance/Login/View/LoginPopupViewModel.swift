//
//  LoginPopupViewModel.swift
//  DDD.Attendance
//
//  Created by ParkSungJoon on 16/10/2019.
//  Copyright © 2019 DDD. All rights reserved.
//

import ReactiveSwift
import NVActivityIndicatorView

protocol LoginPopupViewModelInputs {
    
    func pressLoginButton()
    
    func requestFirebaseAuth(with account: LoginPopupViewModel.Account)
    
    func checkValidAccount(with account: LoginPopupViewModel.Account)
}

protocol LoginPopupViewModelOutputs {
    
    var loginAccount: Signal<LoginPopupViewModel.Account, Never> { get }
    
    var loginSuccess: Signal<FirebaseClient.AccountType, Never> { get }
    
    var isValidAccount: Signal<Bool, Never> { get }

    var loginFailure: Signal<Error, Never> { get }
}

protocol LoginPopupViewModelTypes {
    
    var inputs: LoginPopupViewModelInputs { get }
    
    var outputs: LoginPopupViewModelOutputs { get }
}

class LoginPopupViewModel {
    
    typealias Account = (String, String)
    
    private let firebase: FirebaseClient
    private let isValidAccountProperty = MutableProperty<Bool?>(nil)
    private let pressLoginButtonProperty = MutableProperty<Void?>(nil)
    private let emailProperty = MutableProperty<String>("")
    private let passwordProperty = MutableProperty<String>("")
    private let accountTypeProperty = MutableProperty<FirebaseClient.AccountType?>(nil)
    private let loginFailureProperty = MutableProperty<Error?>(nil)
    
    init(firebase: FirebaseClient = FirebaseClient()) {
        self.firebase = firebase
//        self.checkLoginSession()
    }
}

extension LoginPopupViewModel: LoginPopupViewModelTypes {
    
    var inputs: LoginPopupViewModelInputs { return self }
    
    var outputs: LoginPopupViewModelOutputs { return self }
}

extension LoginPopupViewModel: LoginPopupViewModelInputs {
    
    func pressLoginButton() {
        pressLoginButtonProperty.value = ()
        isValidAccountProperty.value = false
    }
    
    func requestFirebaseAuth(with account: LoginPopupViewModel.Account) {
        loginFirebase(with: account.0, account.1)
    }
    
    func checkValidAccount(with account: LoginPopupViewModel.Account) {
        emailProperty.value = account.0
        passwordProperty.value = account.1
    }
}

extension LoginPopupViewModel: LoginPopupViewModelOutputs {
    
    var loginAccount: Signal<Account, Never> {
        return isValidAccountProperty.signal.skipNil()
            .sample(on: pressLoginButtonProperty.signal.skipNil())
            .filter { $0 }
            .map { [unowned self] _ -> Account in
                return (self.emailProperty.value, self.passwordProperty.value)
            }
    }
    
    var loginSuccess: Signal<FirebaseClient.AccountType, Never> {
        return accountTypeProperty.signal.skipNil()
    }
    
    var isValidAccount: Signal<Bool, Never> {
        return emailProperty.signal
            .combineLatest(with: passwordProperty.signal)
            .compactMap { [unowned self] (email, password) in
                let isValid = self.validateEmail(from: email) && self.validatePassword(from: password)
                self.isValidAccountProperty.value = isValid
                return isValid
        }
    }

    var loginFailure: Signal<Error, Never> {
        return loginFailureProperty.signal.skipNil()
    }
}

private extension LoginPopupViewModel {
    
    func loginFirebase(with email: String, _ password: String) {
        firebase.requestSignIn(with: email, password) { [weak self] result in
            switch result {
            case .success(_):
                self?.fetchLoginStatus()
            case .failure(let error):
                self?.loginFailureProperty.value = error
            }
        }
    }
    
    func fetchLoginStatus() {
        firebase.verifyAccountType { [weak self] result in
            switch result {
            case .success(let accountType):
                self?.accountTypeProperty.value = accountType
            case .failure(let error):
                self?.loginFailureProperty.value = error
            }
        }
    }
    
    func validateEmail(from text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: text)
    }
    
    func validatePassword(from text: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: text)
    }
}
