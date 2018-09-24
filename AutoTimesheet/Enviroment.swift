//
//  Enviroment.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation
import SwiftDate

struct Credential {
    let email: String
    let password: String
}

struct Enviroment {
    var service: ServiceType = TimesheetService()
    var date = { Date() }
    
    let credential = Credential(email: "quanghuy.nguyen@savvycomsoftware.com",
                                password: "123456789")
    
    let appName = "AutoTimesheet"
    let notifcation = NotificationCenter()
}

extension Enviroment {
    static let mock = Enviroment.init(service: MockService(), date: { Date(year: 2018, month: 9, day: 20, hour: 0, minute: 0) })
}

var Current: Enviroment = .init()
