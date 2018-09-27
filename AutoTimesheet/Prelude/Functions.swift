//
//  Function.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/21/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation
func const<A, B>(_ x: @escaping @autoclosure () -> A) -> (B) -> A {
    return { _ in x() }
}

func flip<A, B, C> (_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in {a in f(a)(b) } }
}

func identity<A> (_ x: A) -> A {
    return x
}

func ensure<A, B> (_ f: @escaping (A) -> B?) -> (A) -> B {
    return { f($0)! }
}

enum NilError: Error {
    case gotNil
}


func optionalThrows<A> (_ x: A?, throw: Error = NilError.gotNil) throws -> A {
    guard let a = x  else {
        throw NilError.gotNil
    }
    return a
}


func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
    return { pair in
        (f(pair.0), pair.1)
    }
}

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
    return { pair in
        (pair.0, f(pair.1))
    }
}

func set<W, P>(_ keyPath: WritableKeyPath<W, P>, val: P) -> (W) -> W {
    return {
        var x = $0
        x[keyPath: keyPath] = val
        return x
    }
}
