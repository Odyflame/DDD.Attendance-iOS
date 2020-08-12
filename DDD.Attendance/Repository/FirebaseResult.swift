//
//  FirebaseResult.swift
//  DDD.Attendance
//
//  Created by seongjun.park on 2020/08/01.
//  Copyright © 2020 DDD. All rights reserved.
//

enum Result<Value> {
    case success(Value)
    case failure(Error)

    var value: Value? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }

    var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}
