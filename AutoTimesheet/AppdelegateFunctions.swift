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


/// Save new project if local storage does not have that project,
/// update (wkTime, des) responsed project with correspondence project from local storage
/// then save all responsed to local storage (ovver write local storage)
///
/// - Parameter projects: Responsed Project
/// - Returns: new project added to local storage
/// - Throws: re-throw exception from localStorage
func saveNewProjectsIfNeeded(projects: Set<Project>) throws -> Set<Project> {
    var _projects = projects.reduce(into: [Int: Project]()) { (res: inout [Int: Project], proj) in
        res[proj.id] = proj
    }
    
    let newProjects: Set<Project>
    
    if let savedPrjects: Set<Project> = try? Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects) {
        for proj in savedPrjects {
            if _projects[proj.id] != nil && proj.wkTime != 0 {
                _projects[proj.id]?.wkTime = proj.wkTime
                _projects[proj.id]?.des = proj.des
            }
        }
        
        newProjects = projects.filter({proj in !savedPrjects.contains { $0.id == proj.id }})
    } else {
        newProjects = projects
    }
    
    try Current.keyValueStorage.saveThrows(Set(_projects.values), forKey: KeyValueStorageKey.todayProjects)
    return newProjects
}

func loadProjectFromStorageToLogSheet() throws -> Set<Project> {
    let cachedProjects: Set<Project> = try Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
    let logged = cachedProjects.filter { $0.wkTime != 0 }
    
    // if user has no configuration for timesheet
    // then check if user has `Other` project
    // if user has `Other` proj just return the mock
    // otherwise return the first in the cache with default message
    if logged.isEmpty {
        
        if !cachedProjects.filter({ $0.id == 9 }).isEmpty {
            return Set([.mock])
        } else {
            let firstChoice = cachedProjects.first!
            return Set([firstChoice])
        }
    } else {
        return logged
    }
    
    
}


///TODO: implement parse git commit to get the message

func configureLogTimesheetMessage(projects: Set<Project>) -> Set<Project> {
    return projects
}

func logInThenSaveCookie() -> Promise<()> {
    return Current.service.login(credential: Current.credential)
                        .map { $0.response }
                        .compactMap(getLastCookie)
                        .done(HTTPCookieStorage.shared.setCookie)
}

func timerLogTimesheet() {
    logInThenSaveCookie()
        .then { Current.service.getProjectStatusAt(date: Current.date()) }
        .map { try saveNewProjectsIfNeeded(projects: $0.items) }
        .map { _ in try loadProjectFromStorageToLogSheet() }
        .map(configureLogTimesheetMessage)
        .then {
            Current.service.logTimesheet(for: $0, at: Current.date())
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
