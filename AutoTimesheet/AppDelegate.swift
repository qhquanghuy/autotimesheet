//
//  AppDelegate.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/21/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

import PromiseKit
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
        
        
        Current = .mock
        Current.service.login(credential: Current.credential)
            .map { $0.response }
            .compactMap(getLastCookie)
            .done(HTTPCookieStorage.shared.setCookie)
            .then { Current.service.getProjectStatusAt(date: Current.date() - 2.days) }
            .then { _ in
                Current.service.logTimesheet(for: ProjectResponse.mock.items, at: Current.date() )
            }
            .map { try $0.validated() }
            .done { res in
                print(res)
            }
            .catch {
                Current.notifcation.localPush(notification: NotifcationDetail(title: Current.appName,
                                                                              subtitle: "Error",
                                                                              infomativeText: $0.localizedDescription,
                                                                              soundName: NSUserNotificationDefaultSoundName))
            }
 
    }
    
    
    
    @objc func onTapQuit() {
        NSApp.terminate(self)
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    


}





func getLastCookie(response: PMKAlamofireDataResponse) -> HTTPCookie? {
    guard
        let header = response.response?.allHeaderFields as? [String: String],
        let url = response.request?.url
        else {
            return nil
    }
    let last = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).last
    return last
}


func headerFormat(cookie: HTTPCookie) -> String {
    func cookieFormat(name: String, value: String) -> String{
        return "\(name)=\(value)"
    }
    return [
        cookieFormat(name: cookie.name, value: cookie.value),
        cookieFormat(name: "path", value: cookie.path),
        cookieFormat(name: "domain", value: cookie.domain),
        cookie.isSecure ? "Secure" : "",
        cookie.isHTTPOnly ? "HttpOnly" : ""
        ].joined(separator: ";")
}
