//
//  Notification.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation



protocol NotificationCenterType {
    func localPush(notification: NotifcationDetailType)
}

protocol NotifcationDetailType {
    var title: String { get }
    var subtitle: String { get }
    var soundName: String { get }
    
    var infomativeText: String { get }
    
    
}


struct NotificationDetail: NotifcationDetailType {
    
    let title: String = Current.appName
    let subtitle: String
    let infomativeText: String
    let soundName: String = NSUserNotificationDefaultSoundName
}

extension NotificationDetail: Equatable {
    
}


struct NotificationCenter: NotificationCenterType {
    func localPush(notification: NotifcationDetailType) {
        let userNotificaton = NSUserNotification()
        userNotificaton.soundName = notification.soundName
        userNotificaton.title = notification.title
        userNotificaton.subtitle = notification.subtitle
        userNotificaton.informativeText = notification.infomativeText
        NSUserNotificationCenter.default.deliver(userNotificaton)
    }
    
    
}

struct MockNotificationCenter: NotificationCenterType {
    func localPush(notification: NotifcationDetailType) {
        print(notification)
    }
    
}


extension NSNotification.Name {
    static let screenLocked = NSNotification.Name(rawValue: "com.apple.screenIsLocked")
    static let screenUnlocked = NSNotification.Name(rawValue: "com.apple.screenIsUnlocked")
}
