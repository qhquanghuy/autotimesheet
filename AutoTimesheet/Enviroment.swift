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

struct Configuration {
    let fireTime: DateComponents = {
        var _fireTime = 15.hours
        _fireTime.minute = 24
        _fireTime.second = 0
        return _fireTime
    }()
    
    let fireInterval = 1.minutes
    
    let defaultWkTime = 4.5
    let defaultWkDes = "Reading articles"
}


struct KeyValueStorageKey {
    static let todayProjects = "TodayProjects"
}



struct Enviroment {
    var service: ServiceType = TimesheetService()
    var date = { Date() }
    var calendar = Calendar.autoupdatingCurrent
    var configuration = Configuration()
    var notifcation: NotificationCenterType = NotificationCenter()
    var keyValueStorage: KeyValueStorage = UserDefaults.standard
    
    
    
    let credential = Credential(email: "quanghuy.nguyen@savvycomsoftware.com",
                                password: "123456789")
    
    let appName = "AutoTimesheet"
}

extension Enviroment {
    static let mock = Enviroment(service: MockService(),
                                 date: { Date(year: 2018, month: 9, day: 24, hour: 0, minute: 0) },
                                 calendar: Calendar.current,
                                 configuration: Configuration(),
                                 notifcation: MockNotificationCenter(),
                                 keyValueStorage: UserDefaults.standard)
}

var Current: Enviroment = .init()
