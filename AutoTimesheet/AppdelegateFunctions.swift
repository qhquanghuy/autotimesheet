//
//  AppdelegateFunctions.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/24/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftDate


func saveNewProjectsIfNeeded(projects: Set<Project>) throws -> Set<Project> {
    var newProjects = projects.map(identity)
    
    if let savedPrjects: Set<Project> = try? Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects) {
        let loggedPrjects = savedPrjects.filter { $0.wkTime != 0 }.map(identity)
        
        for (idx, proj) in newProjects.enumerated() {
            if let loggedIdx = loggedPrjects.firstIndex(where: { $0.id == proj.id }) {
                newProjects[idx].wkTime = loggedPrjects[loggedIdx].wkTime
                newProjects[idx].des = loggedPrjects[loggedIdx].des
            }
        }
    }
    try Current.keyValueStorage.saveThrows(newProjects, forKey: KeyValueStorageKey.todayProjects)
    return Set(newProjects)
}

func loadProjectFromStorageToLogSheet() throws -> Set<Project> {
    let cachedProjects: Set<Project> = try Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
    let logged = cachedProjects.filter { $0.wkTime != 0 }
    
    if logged.isEmpty {
        
        if !cachedProjects.filter({ $0.id == 9 }).isEmpty {
            return Set([.mock])
        } else {
            var firstChoice = cachedProjects.first!
            firstChoice.des = Current.configuration.defaultWkDes
            return Set([firstChoice])
        }
    } else {
        return logged
    }
    
    
}


func logTimesheet() {
    Current.service.login(credential: Current.credential)
        .map { $0.response }
        .compactMap(getLastCookie)
        .done(HTTPCookieStorage.shared.setCookie)
        .then { Current.service.getProjectStatusAt(date: Current.date()) }
        .map { try saveNewProjectsIfNeeded(projects: $0.items) }
        .map { _ in try loadProjectFromStorageToLogSheet() }
        .then { _ in
            Current.service.logTimesheet(for: ProjectResponse.mock.items, at: Current.date())
        }
        .done { res in
            Current.notifcation.localPush(notification: NotifcationDetail(title: Current.appName,
                                                                          subtitle: res.status.rawValue,
                                                                          infomativeText: res.message,
                                                                          soundName: NSUserNotificationDefaultSoundName))
        }
        .catch { print("--------------------Error: \($0.localizedDescription)--------------------") }
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
