//
//  Curry.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/21/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation

func curry<A, B, C> (_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a,b) } }
}


func curry<A, B, C, D> (_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}
