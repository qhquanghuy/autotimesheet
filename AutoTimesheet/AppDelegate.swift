//
//  AppDelegate.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/21/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

import SwiftDate
import LoginServiceKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem: NSStatusItem = {
       let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "A"
        }
        statusItem.menu = NSMenu()
        
        return statusItem
    }()
    
    
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        precondition(Current.credential.email != "", Current.errorMessage.unprovideCredentials)
        precondition(Current.credential.password != "", Current.errorMessage.unprovideCredentials)
        
        let quitItem = NSMenuItem.init(title: "Quit", action: #selector(self.onTapQuit), keyEquivalent: "q")
        
        let preferenceItem = NSMenuItem.init(title: "Preference", action: #selector(self.ontapPreference), keyEquivalent: "P")
        statusItem.menu?.addItem(preferenceItem)
        statusItem.menu?.addItem(quitItem)
        
        if !LoginServiceKit.isExistLoginItems() {
            LoginServiceKit.addLoginItems()
        } else {
        
        }
        
        Current = .mock

        let saved: Either<Error, Set<Project>> = Current.keyValueStorage
                                                        .load(key: KeyValueStorageKey.todayProjects)

        _ = saved.bimap(left: const(openPreference()), right: const(()))



        let fireDate = Current.calendar.date(bySettingHour: Current.configuration.fireTime.hour!,
                                             minute: Current.configuration.fireTime.minute!,
                                             second: Current.configuration.fireTime.second!,
                                             of: Current.date())!



        let timer: Timer = Timer.init(fire: fireDate,
                                      interval: Current.configuration.fireInterval.timeInterval,
                                      repeats: true,
                                      block: { _ in timerLogTimesheet() })



        RunLoop.main.add(timer, forMode: .default)
        
    }
    
    @objc func ontapPreference() {
        openPreference()
    }
    
    @objc func onTapQuit() {
        NSApp.terminate(self)
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    


}

func openPreference() {
    let storyboard = NSStoryboard.init(name: "Main", bundle: nil)
    let wc = storyboard.instantiateController(withIdentifier: "MainWC") as! NSWindowController
    NSApp.activate(ignoringOtherApps: true)
    NSApp.setActivationPolicy(.regular)
    wc.showWindow(nil)
}
