//
//  Either.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/22/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation

enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either {
    func map <A> (_ f: (R) -> A) -> Either<L, A> {
        switch self {
        case .right(let r):
            return .right(f(r))
        case .left(let l):
            return .left(l)
        }
    }
    
    func bimap <A, B>(left: (L) -> A, right: (R) -> B) -> Either<A, B> {
        switch self {
        case .right(let r):
            return .right(right(r))
        case .left(let l):
            return .left(left(l))
        }
    }
    
    func flatMap <A> (_ f: (R) -> Either<L, A>) -> Either<L, A> {
        switch self {
        case .right(let r):
            return f(r)
        case .left(let l):
            return .left(l)
        }
    }
    
    func apply <A> (_ f: Either<L, (R) -> A>) -> Either<L, A> {
        return f.flatMap(self.map)
    }
}

extension Either where L == Optional<R> {
    var value: L {
        switch self {
        case .left(let l):
            return l
        case .right(let r):
            return r
        }
    }
}

extension Either where R == Optional<L> {
    var value: R {
        switch self {
        case .left(let l):
            return l
        case .right(let r):
            return r
        }
    }
}

extension Either where L == R {
    var value: R {
        switch self {
        case .left(let l):
            return l
        case .right(let r):
            return r
        }
    }
}

extension Either: Equatable where L: Equatable, R: Equatable {
    
}

extension Either: Codable where L: Codable, R: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .left(let l):
            try container.encode(l)
        case .right(let r):
            try container.encode(r)
        }
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        let r = try? value.decode(R.self)
        if let r = r {
            self = .right(r)
        } else {
            self = .left(try value.decode(L.self))
        }
    }
}


