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
        
        let menuItem = NSMenuItem.init(title: "Quit", action: #selector(self.onTapQuit), keyEquivalent: "q")
        statusItem.menu?.addItem(menuItem)
        
        if !LoginServiceKit.isExistLoginItems() {
            LoginServiceKit.addLoginItems()
        } else {
        }
        
//        Current = .mock
        let fireDate = Current.calendar.date(bySettingHour: Current.configuration.fireTime.hour!,
                                             minute: Current.configuration.fireTime.minute!,
                                             second: Current.configuration.fireTime.second!,
                                             of: Current.date())!
        let timer: Timer = Timer.init(fire: fireDate,
                                      interval: Current.configuration.fireInterval.timeInterval,
                                      repeats: true,
                                      block: const(logTimesheet()))
        
      
        RunLoop.main.add(timer, forMode: .default)
        
    }
    
    
    
    @objc func onTapQuit() {
        NSApp.terminate(self)
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    


}
