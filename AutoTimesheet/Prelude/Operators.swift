//
//  Operator.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/21/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation

precedencegroup ForwardCompositon {
    associativity: left
    higherThan: ForwardApplication
}

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator >>>: ForwardCompositon
infix operator |>: ForwardApplication


func >>> <A, B, C> (_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

func |> <A, B> (_ x: A, _ f: (A) -> B) -> B {
    return f(x)
}
