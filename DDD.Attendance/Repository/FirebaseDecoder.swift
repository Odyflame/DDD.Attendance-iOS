//
//  FirebaseDecoder.swift
//  DDD.Attendance
//
//  Created by seongjun.park on 2020/08/01.
//  Copyright © 2020 DDD. All rights reserved.
//

import Foundation

class FirebaseDecoder<T: Decodable> {

    private let object: [String: Any]?

    enum ErrorCode: Error {
        case notExistData
        case failSerialization
        case failDecoding
    }

    init(from object: [String: Any]?) {
        self.object = object
    }

    func decode() throws -> T {
        do {
            let serializationData = try serialize()
            return try decode(from: serializationData)
        } catch {
            throw error
        }
    }
}

// MARK: - Private
private extension FirebaseDecoder {
    func serialize() throws -> Data {
        guard let object = object else {
            throw ErrorCode.notExistData
        }
        do {
            return try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        } catch {
            throw ErrorCode.failSerialization
        }
    }

    func decode(from serializationData: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: serializationData)
        } catch {
            throw ErrorCode.failDecoding
        }
    }
}
