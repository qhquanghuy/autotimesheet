//
//  Enviroment.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation
import SwiftDate


struct KeyValueStorageKey {
    static let todayProjects = "TodayProjects"
}


struct AutoTimesheetErrorMessage {
    let alreadyLoggedTimesheet = "You've already logged timesheet for today"
    let addedNewProject = "You've added new project, auto timesheet for today will suspend, please configure auto time sheet then submit it manually!"
    let unprovideCredentials = "Please provide your credentials"
}

struct Enviroment {
    var service: ServiceType = TimesheetService()
    var utcDate = { Date() }
    var calendar = Calendar.autoupdatingCurrent
    var configuration = Configuration()
    var notifcation: NotificationCenterType = NotificationCenter()
    var keyValueStorage: KeyValueStorage = UserDefaults.standard
    
    let fileManager = FileManager.default
    let dateFormater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    let errorMessage = AutoTimesheetErrorMessage()
    let credential = Credential()
    
    let appName = "AutoTimesheet"
}

extension Enviroment {
    static let mock = Enviroment(service: MockService(),
                                 utcDate: { Date() },
                                 calendar: Calendar.current,
                                 configuration: .mock,
                                 notifcation: MockNotificationCenter(),
                                 keyValueStorage: MockKeyValueStorage())
}

var Current: Enviroment = .init()
