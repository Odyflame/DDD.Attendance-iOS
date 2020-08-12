//
//  Auth.swift
//  DDD.Attendance
//
//  Created by ParkSungJoon on 06/10/2019.
//  Copyright © 2019 DDD. All rights reserved.
//

import CodableFirebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebaseClient {
    
    let manager: Auth
    
    private let database = Database.database().reference()
    
    enum AccountType {
        case admin
        case `default`
    }

    enum ErrorCode: Error {
        case notFoundUser
        case notExistedUid
        case notExistedAccountType
    }
    
    init(manager: Auth = Auth.auth()) {
        self.manager = manager
    }
    
    func requestSignIn(with email: String,
                       _ password: String,
                       completion: @escaping (Result<User>) -> Void
    ) {
        manager.signIn(withEmail: email, password: password) { value, error in
            guard let user = value?.user else {
                completion(.failure(ErrorCode.notFoundUser))
                return
            }
            completion(.success(user))
        }
    }
    
    func requestSignUp(with signUpUserModel: SignUpUserModel,
                       completion: @escaping (Result<StoredUserModel>) -> Void
    ) {
        manager.createUser(withEmail: signUpUserModel.email, password: signUpUserModel.password) { value, error in
            guard let uid = value?.user.uid else {
                completion(.failure(ErrorCode.notFoundUser))
                return
            }
            let userModel = StoredUserModel(email: signUpUserModel.email,
                                            name: signUpUserModel.name,
                                            position: signUpUserModel.position,
                                            isManager: false,
                                            uid: uid,
                                            attendance: [String: String]())
            completion(.success(userModel))
        }
    }
    
    func requestSignOut(completion: @escaping (Result<Void>) -> Void) {
        do {
            try manager.signOut()
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }

    func storeUserAccount(with userModel: StoredUserModel) {
        /// Firebase Database에 적재하기 위해서는 NSNumber, NSString, NSDictionary, and NSArray 을 준수하여야 함
        let userData: [String: Any] = [
            "email": userModel.email,
            "name": userModel.name,
            "position": userModel.position,
            "isManager": userModel.isManager,
            "attendance": userModel.attendance
        ]
        database
            .child(FirebasePath.users.rawValue)
            .child(userModel.uid)
            .setValue(userData)
    }
    
    func verifyAccountType(completion: @escaping (Result<AccountType>) -> Void) {
        guard let uid = manager.currentUser?.uid else {
            completion(.failure(ErrorCode.notExistedUid))
            return
        }
        database
            .child(FirebasePath.users.rawValue)
            .child(uid)
            .observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                if let isManager = value?["isManager"] as? Bool {
                    let loginStatus = isManager
                        ? AccountType.admin
                        : AccountType.default
                    completion(.success(loginStatus))
                } else {
                    completion(.failure(ErrorCode.notExistedAccountType))
                }
            }) { error in
                completion(.failure(error))
        }
    }
    
    func requestAttendance(userId: String,
                           isLate: Bool,
                           timeStamp: Int64,
                           completion: @escaping(Bool) -> Void
    ) {
        let attendance: [String: String] = [
            "result": isLate ? "1" : "0"
        ]
        database
            .child(FirebasePath.users.rawValue)
            .child(userId)
            .child(FirebasePath.attendance.rawValue)
            .child("\(timeStamp)")
            .setValue(attendance, withCompletionBlock: { error, _ in
                completion(error == nil)
            })
    }
    
    func fetchCurriculumList(completion: @escaping ([Curriculum]?) -> Void) {
        database.child(FirebasePath.curriculum.rawValue)
            .observeSingleEvent(of: .value) { snapshot in
                guard
                    let value = snapshot.value,
                    let result = value as? [[String: Any]] else {
                        completion(nil)
                        return
                }
                
                let results = result.enumerated().map { offset, element in
                    return Curriculum(date: element["date"] as? String ?? "",
                                      title: element["title"] as? String ?? "",
                                      isDone: element["isDone"] as? Bool ?? false,
                                      index: offset + 1)
                }
                completion(results)
        }
    }
    
    func fetchBanner(completion: @escaping(Banner?) -> Void) {
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "banner/banner.png")
        
        database.child(FirebasePath.banner.rawValue)
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value, let result = value as? [String: String] else {
                    completion(nil)
                    return
                }
                
                pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    let imageData = error != nil ? nil : data
                    let banner = Banner(title: result["title"] ?? "",
                                        subTitle: result["subTitle"] ?? "",
                                        imageData: imageData)
                    completion(banner)
                }
        }
    }

    func fetchUserAttendanceList(name userName: String,
                                 completion: @escaping(Result<AttendanceStatusModel>) -> Void
    ) {
        database
            .child(FirebasePath.users.rawValue)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard
                    let value = snapshot.value,
                    let result = value as? [String: Any] else {
                        return
                }
                
                let targetUser = result.values
                    .compactMap { ($0 as? [String: Any]) }
                    .first(where: { ($0["name"] as? String) == userName })
                
                if let targetUser = targetUser {
                    do {
                        let decodedValue = try FirebaseDecoder<AttendanceStatusModel>(from: targetUser)
                            .decode()
                        completion(.success(decodedValue))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(ErrorCode.notFoundUser))
                }
            })
    }
}
