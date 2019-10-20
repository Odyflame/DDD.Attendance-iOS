//
//  SignUpViewModel.swift
//  DDD.Attendance
//
//  Created by Hakyung Kim on 05/10/2019.
//  Copyright © 2019 DDD. All rights reserved.
//
import ReactiveSwift
import ReactiveCocoa
import UIKit

enum SignUpStep: Int {
    case StepOne = 1
    case StepTwo
    case StepThree
    case StepFour
}

enum Position: Int {
    case None = -1
    case Designer
    case And
    case iOS
    case Backend
}

class SignUpViewModel {
    // Inputs
    let firstName = MutableProperty<String?>(nil)
    let lastName = MutableProperty<String?>(nil)
    let email = MutableProperty<String?>(nil)
    let password = MutableProperty<String?>(nil)
    let position = MutableProperty<Position>(.None)
    let step = MutableProperty<SignUpStep>(.StepOne)
    
    // Outputs
    lazy private(set) var progressBarSignal: Signal<Float, Never> = { [unowned self] in
        return self.step.signal.map { Float($0.rawValue) * 0.25 }
    }()
    
    lazy private(set) var currentStepSignal: Signal<String, Never> = { [unowned self] in
        return self.step.signal.map { "Step \($0.rawValue)" }
    }()
    
    lazy private(set) var stepOneBtnEnabledSignal: SignalProducer<Bool, Never> = { [unowned self] in
        let notEmptySignals = [
            self.firstName.producer.skipNil().map { $0 != "" },
            self.lastName.producer.skipNil().map { $0 != "" },
        ]
        return SignalProducer
            .combineLatest(notEmptySignals)
            .map { $0.reduce(true) { $0 && $1 } }
    }()
    
    lazy private(set) var stepTwoBtnEnabledSignal: SignalProducer<Bool, Never> = { [unowned self] in
        let notEmptySignals = [
            self.email.producer.skipNil().map(self.validateEmail),
            self.password.producer.skipNil().map(self.validatePassword),
        ]
        return SignalProducer
            .combineLatest(notEmptySignals)
            .map { $0.reduce(true) { $0 && $1 } }
    }()
    
    lazy private(set) var stepThreeBtnEnabledSignal: SignalProducer<Bool, Never> = { [unowned self] in
       return self.position.producer.map { $0 != .None }
    }()
    
   lazy private(set) var validationResultSignal: SignalProducer<UIColor, Never> = { [unowned self] in
        let result = self.password.producer.skipNil().map(self.validatePassword)
        return result.map { (enabled: Bool) -> UIColor in
            return (enabled ? UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) : UIColor(red: 239/255, green: 48/255, blue: 36/255, alpha: 1.0))
        }
    }()
    
    func pressNextButton() {
        step.value = SignUpStep(rawValue: step.value.rawValue + 1) ?? .StepOne
    }
    
    func pressSignUpButton() {
        step.value = SignUpStep(rawValue: step.value.rawValue + 1) ?? .StepOne
    }
    
    init() {
        
    }
}

private extension SignUpViewModel {
    func validateEmail(_ string: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: string)
    }
    
    func validatePassword(_ string: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,25}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return predicate.evaluate(with: string)
    }
}
