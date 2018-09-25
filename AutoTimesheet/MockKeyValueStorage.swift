//
//  MockKeyValueStorage.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/24/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation

private var _storage: [String: Codable] = [:]

struct MockKeyValueStorage: KeyValueStorage {
    func remove(forKey: String) {
        _storage[forKey] = nil
    }
    
    
    
    
    
    
    func save<T>(_ val: T, forKey: String) -> Either<Error, ()> where T : Decodable, T : Encodable {
        _storage[forKey] = val
        return .right(())
    }
    
    func load<T>(key: String) -> Either<Error, T> where T : Decodable, T : Encodable {
        guard let val = _storage[key] else { return .left(KeyValueStorageError<T>.dataNotFoundForKey(key)) }
        guard let asT = val as? T else { return .left(KeyValueStorageError.typeMisMatch(type(of: val))) }
        return .right(asT)
    }
    
    func saveThrows<T>(_ val: T, forKey: String) throws where T : Decodable, T : Encodable {
        _storage[forKey] = val
    }
    
    func loadThrows<T>(key: String) throws -> T where T : Decodable, T : Encodable {
        guard let val = _storage[key] else { throw KeyValueStorageError<T>.dataNotFoundForKey(key) }
        guard let asT = val as? T else { throw KeyValueStorageError.typeMisMatch(type(of: val)) }
        return asT
    }
    
    
}
