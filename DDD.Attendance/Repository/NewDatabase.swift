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
    
    func login(credential: AuthCredential, completion: @escaping (_ providerID: String?, _ isError: Bool, _ isNewUser: Bool?, _ userID: String?) -> Void) {
        Auth.auth().signIn(with: credential) { (AuthDataResult, Error) in
            // Check for errors
            if Error != nil {
                print("Error logging in to Firebase")
                completion(nil, true, nil, nil)
                return
            }
            
            // Check for provider ID
            guard let providerID = AuthDataResult?.user.uid else {
                print("Error getting provider ID")
                completion(nil, true, nil, nil)
                return
            }
            
            self.checkIfUserExistsInDatabase(providerID: providerID) { (returnedUserID) in
                
            }
        }
    }
    
    func createNewUserInDatabase(name: String, email: String, providerID: String, provider: String, profileImage: UIImage, handler: @escaping (_ userID: String?) -> Void) {
        
    }
    
    func checkIfUserExistsInDatabase(providerID: String, completion: @escaping (_ existingUserID: String?) -> Void) {
        database
            .child("users")
            .child(providerID)
    }
}
