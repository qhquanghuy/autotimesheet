//
//  Notification.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation
import Cocoa


protocol NotificationCenterType {
    func localPush(notification: NotifcationDetailType)
    func windowAlert(notification: NotifcationDetailType) -> Bool
}

protocol NotifcationDetailType {
    var title: String { get }
    var subtitle: String { get }
    var soundName: String { get }
    
    var infomativeText: String { get }
    
}

final class NotificationDelegateImpl: NSObject, NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
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
    func windowAlert(notification: NotifcationDetailType) -> Bool {
        let alert = NSAlert()
        alert.messageText = notification.title
        alert.informativeText = notification.infomativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    private let delegateImpl = NotificationDelegateImpl()
    
    func localPush(notification: NotifcationDetailType) {
        
        let userNotificaton = NSUserNotification()
        userNotificaton.soundName = notification.soundName
        userNotificaton.title = notification.title
        userNotificaton.subtitle = notification.subtitle
        userNotificaton.informativeText = notification.infomativeText
        
        NSUserNotificationCenter.default.delegate = self.delegateImpl
        NSUserNotificationCenter.default.deliver(userNotificaton)
    }
    
    
}

struct MockNotificationCenter: NotificationCenterType {
    func windowAlert(notification: NotifcationDetailType) -> Bool {
        dump(notification)
        return false
    }
    
    func localPush(notification: NotifcationDetailType) {
        print(notification)
    }
    
}


extension NSNotification.Name {
    static let screenLocked = NSNotification.Name(rawValue: "com.apple.screenIsLocked")
    static let screenUnlocked = NSNotification.Name(rawValue: "com.apple.screenIsUnlocked")
}
