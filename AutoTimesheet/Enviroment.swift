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
    var fireTime: DateComponents = {
        var _fireTime = 17.hours
        _fireTime.minute = 30
        _fireTime.second = 0
        return _fireTime
    }()
    
    var fireInterval = 1.days
    
    var defaultWkTime = 4.5
    var defaultWkDes = "Reading articles"
    
    static let mock = Configuration(fireTime: {
        var _fireTime = 17.hours
        _fireTime.minute = 30
        _fireTime.second = 0
        return _fireTime
    }(), fireInterval: 1.minutes, defaultWkTime: 4.5, defaultWkDes: "Reading articles")
}


struct KeyValueStorageKey {
    static let todayProjects = "TodayProjects"
}


struct AutoTimesheetErrorMessage {
    let alreadyLoggedTimesheet = "You've already logged timesheet for today"
    let addedNewProject = "You've added new project, auto timesheet for today will suspend, please configure auto time sheet then submit it manually!"
}

struct Enviroment {
    var service: ServiceType = TimesheetService()
    var date = { Date() }
    var calendar = Calendar.autoupdatingCurrent
    var configuration = Configuration()
    var notifcation: NotificationCenterType = NotificationCenter()
    var keyValueStorage: KeyValueStorage = UserDefaults.standard
    
    
    let errorMessage = AutoTimesheetErrorMessage()
    let credential = Credential(email: "quanghuy.nguyen@savvycomsoftware.com",
                                password: "123456789")
    
    let appName = "AutoTimesheet"
}

extension Enviroment {
    static let mock = Enviroment(service: MockService(),
                                 date: { Date(year: 2018, month: 9, day: 24, hour: 0, minute: 0) },
                                 calendar: Calendar.current,
                                 configuration: .mock,
                                 notifcation: MockNotificationCenter(),
                                 keyValueStorage: MockKeyValueStorage())
}

var Current: Enviroment = .init()
