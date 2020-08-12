//
//  UserModel.swift
//  DDD.Attendance
//
//  Created by Hakyung Kim on 23/10/2019.
//  Copyright © 2019 DDD. All rights reserved.
//

struct SignUpUserModel {
    let email: String
    let password: String
    let name: String
    let position: String
    let isManager: Bool
}

struct StoredUserModel {
    let email: String
    let name: String
    let position: String
    let isManager: Bool
    let uid: String
    let attendance: [String: String]
}
