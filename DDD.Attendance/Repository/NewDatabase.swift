//
//  NewDatabase.swift
//  DDD.Attendance
//
//  Created by apple on 2021/03/07.
//  Copyright © 2021 DDD. All rights reserved.
//
import CodableFirebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct CurrentUserDefaults {
    static let displayName = "display_name"
    static let userID = "user_id"
    static let isFirsetVisit = "is_first_visit"
}

class NewFirebase {
    let manager: Auth
    
    private let database = Database.database().reference()
    
    enum LoginStatus {
        case admin
        case `default`
        case failure
    }
    
    init(manager: Auth = Auth.auth()) {
        self.manager = manager
    }
    
    func loginUserToFirebase(credential: AuthCredential, completion: @escaping (_ providerID: String?, _ isError: Bool, _ isNewUser: Bool?) -> Void) {
        Auth.auth().signIn(with: credential) { (AuthDataResult, Error) in
            // Check for errors
            if Error != nil {
                print("Error logging in to Firebase")
                completion(nil, true, nil)
                return
            }
            
            // Check for provider ID
            guard let providerID = AuthDataResult?.user.uid else {
                print("Error getting provider ID")
                completion(nil, true, nil)
                return
            }
            
            self.checkIfUserExistsInDatabase(userID: providerID) { (result) in
                // 데이터베이스에 회원가입 정보가 있으면 그냥 로그인, 없으면 데이터를 넣어줘야지
                switch result {
                case .default:
                    completion(providerID, false, false )
                case .failure:
                    completion(providerID, false, true )
                default:
                    return
                }
            }
        }
    }
    
    func logOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            print("Error \(error)")
            completion(false)
            return
        }
        
    }
    
    func createNewUserInDatabase(with user: UserModel, _ userID: String, completion: @escaping (Bool?) -> Void) {
        
        let userData: [String: Any] = [
            "email": user.email,
            "name": user.name,
            "position": user.position,
            "isManager": false,
            "attendance": []
        ]
        
        database
            .child("users")
            .child(userID)
            .setValue(userData) { (error, _) in
                completion(error == nil)
            }
    }
    
    func checkIfUserExistsInDatabase(userID: String, completion: @escaping (_ existingUser: LoginStatus?) -> Void) {
        //userID에 저장하였다
        
        database
            .child("users")
            .child(userID)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    completion(LoginStatus.default)
                } else {
                    completion(LoginStatus.failure)
                }
            }) { error in
                print(error.localizedDescription)
                completion(LoginStatus.failure)
            }
    }
}
