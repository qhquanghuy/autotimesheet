//
//  KeyValueStorage.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/24/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation

protocol KeyValueStorage {
    func save<T: Codable>(_ val: T, forKey: String) -> Either<Error, ()>
    func load<T: Codable>(key: String) -> Either<Error, T>
    
    
    func saveThrows<T: Codable>(_ val: T, forKey: String) throws
    func loadThrows<T: Codable>(key: String) throws -> T
}

enum LocalStorageError: Error {
    case dataNotFoundForKey(String)
}


extension UserDefaults: KeyValueStorage {
    func save<T: Codable>(_ val: T, forKey: String) -> Either<Error, ()> {
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(val)
            
            self.set(json, forKey: forKey)
            return .right(())
        } catch let err {
            return .left(err)
        }
    }
    func load<T: Codable>(key: String) -> Either<Error, T> {
        let decoder = JSONDecoder()
        do {
            guard let data = self.data(forKey: key) else { throw LocalStorageError.dataNotFoundForKey(key) }
            return try .right(decoder.decode(T.self, from: data))
        } catch let err {
            return .left(err)
        }
    }
    
    func saveThrows<T: Codable>(_ val: T, forKey: String) throws {
        let encoder = JSONEncoder()
        let json = try encoder.encode(val)
        self.set(json, forKey: forKey)
        self.synchronize()
    }
    
    func loadThrows<T: Codable>(key: String) throws -> T {
        let decoder = JSONDecoder()
        let data = try optionalThrows(self.data(forKey: key), throw: LocalStorageError.dataNotFoundForKey(key))
        return try decoder.decode(T.self, from: data)
    }
    
}
