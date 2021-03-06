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
        if _projects[proj.id] != nil && (proj.wkTime != 0 || !proj.des.isEmpty) {
            _projects[proj.id]?.wkTime = proj.wkTime
            _projects[proj.id]?.des = proj.des
            _projects[proj.id]?.localGitRepo = proj.localGitRepo
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
    var newProjects: Set<Project> = projects
    let key = KeyValueStorageKey.todayProjects
    
    if let savedProjects: Set<Project> = try? Current.keyValueStorage.loadThrows(key: key) {
        
        let _projects = rebind(responsedProjects: projects, savedProjects: savedProjects)
        
        try Current.keyValueStorage.saveThrows(Set(_projects), forKey: KeyValueStorageKey.todayProjects)
        
        newProjects = projects.filter({proj in !savedProjects.contains { $0.id == proj.id }})
    }
    
    
    return newProjects
}

func loadProjectFromStorageToLogSheet() throws -> Set<Project> {
    let cachedProjects: Set<Project> = try Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
    return cachedProjects.filter { $0.wkTime != 0 }
    
}



///TODO: implement parse git commit to get the message

func configureLogTimesheetMessage(projects: Set<Project>) -> Promise<Set<Project>> {
    
    
    let projectsThatHasLocalGit = projects.filter { $0.wkTime != 0 && $0.localGitRepo != nil }.map(identity)
    let projectsThatHasDes = projects.symmetricDifference(projectsThatHasLocalGit)
    let gitlogPromises = projectsThatHasLocalGit.compactMap { $0.localGitRepo.map(getLastestGitLog) }
    return when(fulfilled: gitlogPromises)
        .map { zip($0, projectsThatHasLocalGit) }
        .map { zipped in zipped.map { set(\.des, val: $0.0.subject)($0.1) } }
        .map(Set.init)
        .map { $0.union(projectsThatHasDes) }
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

func configureMessageThenLogTimesheet(projectsProvider: () throws -> Set<Project>) -> Promise<NotificationDetail> {
    do {
        return configureLogTimesheetMessage(projects: try projectsProvider())
                .then { projects in
                Current.service
                    .logTimesheet(for: projects, at: Current.utcDate())
                    .map { NotificationDetail(subtitle: $0.status.rawValue.uppercased(),
                                              infomativeText: $0.message + (projects |> formatLoggedMessage))  }
            }
        
    } catch let err {
        return .init(error: err)
    }
}


func timerLogTimesheet() {
    let date = Current.utcDate()
    print("trigger at \(date)")
    
    
    if Current.calendar.isDateInWeekend(date) {
        return
    }
    
    logInThenSaveCookie()
        .then { Current.service.getProjectStatusAt(date: Current.utcDate()) }
        .map { checkIfAlreadyLoggedTimesheet(projects: $0.items) }
        .map { ($0.0, try saveNewProjectsIfNeeded(projects: $0.1)) }
        .map(second(checkIfAddedNewProject))
        .then {
            $0.0.map(Promise.value) ??
            $0.1.map(Promise.value) ??
            configureMessageThenLogTimesheet(projectsProvider: loadProjectFromStorageToLogSheet)
        }
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
