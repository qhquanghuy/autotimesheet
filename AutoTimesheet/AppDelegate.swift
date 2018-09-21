//
//  AppDelegate.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/21/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa
import Alamofire
import PromiseKit



func const<A, B>(_ x: A) -> (B) -> A {
    return { _ in x }
}

func curry<A, B, C> (_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a,b) } }
}


func curry<A, B, C, D> (_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}


func flip<A, B, C> (_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in {a in f(a)(b) } }
}


func plus(_ x: Any ..., y: Int, z: Int) {
    
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.title = "A"
            button.action = #selector(printQuote(_:))
        }
        
        
    }
    
    
    
    
    func getToken() -> Promise<(json: Any, response: PMKAlamofireDataResponse)> {
        return Alamofire.request("https://timesheet.savvycom.vn/users/loginAction",
                          method: .post,
                          parameters: ["email": "quanghuy.nguyen@savvycomsoftware.com", "password": "123456789"],
                          encoding: URLEncoding.default,
                          headers: Alamofire.SessionManager.defaultHTTPHeaders).responseJSON()
    }
    
    func getHistory(cookie: String) -> Promise<(json: Any, response: PMKAlamofireDataResponse)> {
        let header = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:62.0) Gecko/20100101 Firefox/62.0",
            "Accept": "application/json, text/plain, */*",
            "Content-Type": "application/json;charset=utf-8",
            "Cookie": cookie
        ]
        
        
//
//        curl 'https://timesheet.savvycom.vn/users/getTimesheetLoging' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:62.0) Gecko/20100101 Firefox/62.0' -H 'Accept: application/json, text/plain, */*' -H 'Content-Type: application/json;charset=utf-8' -H 'Cookie: G_ENABLED_IDPS=google; __zlcmid=hngdcYfSWZGRIq; SMS2014=e8f5u750ijejj0m7fh4qgt41e3' --data '{"date":"21-09-2018"}'
        return Alamofire.request("https://timesheet.savvycom.vn/users/getTimesheetLoging",
                                 method: .get,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: header).responseJSON()
    }
    
    
    func getCookie(response: PMKAlamofireDataResponse) -> String {
        response.response?.allHeaderFields
    }
    
    
    @objc func printQuote(_ sender: Any?) {
//        getHistory().done {
//            print($0.json)
//        }
        
//        Cookie: G_ENABLED_IDPS=google; __zlcmid=hngdcYfSWZGRIq; SMS2014=e8f5u750ijejj0m7fh4qgt41e3
        getToken()
            .map { $0.response }
            .map { res in res.request?.url.map { ($0, res.response?.allHeaderFields as? [String: String]) } }
            .map { opt in opt.flatMap { tuple in tuple.1.flatMap { HTTPCookie.cookies(withResponseHeaderFields: $0, for: tuple.0) } } }
            .map { $0?.last }
            .map { cookie in cookie.map { $0.name + "=" + $0.value }  }
//            .then(getHistory)
//            .done { print($0.json) }
    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

