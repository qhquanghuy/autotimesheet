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


func rebind(responsedProjects: Set<Project>, savedProjects: Set<Project>) -> Set<Project> {
    var _projects = responsedProjects.reduce(into: [Int: Project]()) { (res: inout [Int: Project], proj) in
        res[proj.id] = proj
    }
    for proj in savedProjects {
        if _projects[proj.id] != nil && proj.wkTime != 0 {
            _projects[proj.id]?.wkTime = proj.wkTime
            _projects[proj.id]?.des = proj.des
        }
    }
    return Set(_projects.values)
}


/// Save new project if local storage does not have that project,
/// update (wkTime, des) responsed project with correspondence project from local storage
/// then save all responsed to local storage (ovver write local storage)
///
/// - Parameter projects: Responsed Project
/// - Returns: new project added to local storage
/// - Throws: re-throw exception from localStorage
func saveNewProjectsIfNeeded(projects: Set<Project>) throws -> Set<Project> {
    var _projects = projects
    let newProjects: Set<Project>
    let savedProjects: Set<Project>? = try? Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
    
    if let savedProjects = savedProjects {
        _projects = rebind(responsedProjects: _projects, savedProjects: savedProjects)
        
    }
    
    newProjects = savedProjects.map { saved in projects.filter({proj in !saved.contains { $0.id == proj.id }}) } ?? projects
    
    try Current.keyValueStorage.saveThrows(Set(_projects), forKey: KeyValueStorageKey.todayProjects)
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

/// Check if responsed projects are logged
///
/// - Parameter projects: responsed projects
/// - Returns: a tupple that left is a optional notifcation for user if projects are logged, right is responsed projects
func checkIfAlreadyLoggedTimesheet(projects: Set<Project>) -> (NotificationDetail?, Set<Project>) {
    if projects.allSatisfy({ $0.wkTime == 0 }) {
        return (nil, projects)
    } else {
        return (NotificationDetail( subtitle: "", infomativeText: Current.errorMessage.alreadyLoggedTimesheet), projects)
    }
}


func checkIfAddedNewProject(projects: Set<Project>) -> NotificationDetail? {
    return projects.isEmpty ? nil : NotificationDetail(subtitle: "", infomativeText: Current.errorMessage.addedNewProject)
}

func formatLoggedMessage(projects: Set<Project>) -> String {
    return "\n" + projects.map { "\($0.name) - \($0.wkTime)h - \($0.des)" }.joined(separator: "\n")
}

func logTimesheet() -> Promise<NotificationDetail> {
    do {
        let configuredProjects = try loadProjectFromStorageToLogSheet() |> configureLogTimesheetMessage
        return Current.service
            .logTimesheet(for: configuredProjects, at: Current.date())
            .map { NotificationDetail(subtitle: $0.status.rawValue.uppercased(),
                                      infomativeText: $0.message + (configuredProjects |> formatLoggedMessage))  }
    } catch let err {
        return .init(error: err)
    }
}


func timerLogTimesheet() {
    logInThenSaveCookie()
        .then { Current.service.getProjectStatusAt(date: Current.date()) }
        .map { checkIfAlreadyLoggedTimesheet(projects: $0.items) }
        .map { ($0.0, try saveNewProjectsIfNeeded(projects: $0.1)) }
        .map(second(checkIfAddedNewProject))
        .then { $0.0.map(Promise.value) ?? $0.1.map(Promise.value) ?? logTimesheet() }
        .done(Current.notifcation.localPush)
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
