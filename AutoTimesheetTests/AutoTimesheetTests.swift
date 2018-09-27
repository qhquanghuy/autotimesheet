//
//  DecodeProjectReseponseTest.swift
//  DecodeProjectReseponseTest
//
//  Created by Huy Nguyen on 9/22/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import XCTest
import PromiseKit

class AutoTimesheetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Current = .mock
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testTimerLogTimesheet() {
        let expectation = XCTestExpectation(description: "Download apple.com home page")
        let extected1 = NotificationDetail(subtitle: "", infomativeText: Current.errorMessage.alreadyLoggedTimesheet)
        let _ = logInThenSaveCookie()
            .then { Current.service.getProjectStatusAt(date: Current.date()) }
            .map { checkIfAlreadyLoggedTimesheet(projects: $0.items) }
            .map { ($0.0, try saveNewProjectsIfNeeded(projects: $0.1)) }
            .map(second(checkIfAddedNewProject))
            .then { $0.0.map(Promise.value) ?? $0.1.map(Promise.value) ?? configureMessageThenLogTimesheet(projectsProvider: loadProjectFromStorageToLogSheet) }
            .done {
                XCTAssertEqual($0, extected1)
                expectation.fulfill()
        }
        
        
        let expected2 = NotificationDetail(subtitle: "", infomativeText: Current.errorMessage.alreadyLoggedTimesheet)
        
        let newPr = Project.init(id: 100, name: "DonotKnow", wkTime: 8, oTime: 0, des: "", isOtApproved: false, localGitRepo: nil)
        let response = ProjectResponse.init(items: Set([newPr] + ProjectResponse.mock.items))
        logInThenSaveCookie()
            .then { _ in Promise<ProjectResponse>.value(response) }
            .map { checkIfAlreadyLoggedTimesheet(projects: $0.items) }
            .map { ($0.0, try saveNewProjectsIfNeeded(projects: $0.1)) }
            .map(second(checkIfAddedNewProject))
            .then { $0.0.map(Promise.value) ?? $0.1.map(Promise.value) ?? configureMessageThenLogTimesheet(projectsProvider: loadProjectFromStorageToLogSheet) }
            .done {
                XCTAssertEqual($0, expected2)
                expectation.fulfill()
        }
        
        
        
        let expected3 = NotificationDetail(subtitle: "", infomativeText: Current.errorMessage.addedNewProject)
        
        let newPr1 = Project.init(id: 101, name: "DonotKnow", wkTime: 0, oTime: 0, des: "", isOtApproved: false, localGitRepo: nil)
        let response2 = ProjectResponse.init(items: Set([newPr1] + ProjectResponse.mock.items.filter { $0.id != 9 }))
        
        let key = KeyValueStorageKey.todayProjects
        let sortProject: (Set<Project>) -> [Project] = { $0.map(identity).sorted { $0.id < $1.id } }
        logInThenSaveCookie()
            .then { _ in Promise<ProjectResponse>.value(response2) }
            .map { checkIfAlreadyLoggedTimesheet(projects: $0.items) }
            .map { ($0.0, try saveNewProjectsIfNeeded(projects: $0.1)) }
            .map(second(checkIfAddedNewProject))
            .then { $0.0.map(Promise.value) ?? $0.1.map(Promise.value) ?? configureMessageThenLogTimesheet(projectsProvider: loadProjectFromStorageToLogSheet) }
            .done {
                let cached: Set<Project> = try! Current.keyValueStorage.loadThrows(key: key)
                
                XCTAssertEqual($0, expected3)
                XCTAssertEqual(response2.items |> sortProject, cached |> sortProject)
                expectation.fulfill()
        }
        
        
        
    }
    
    
    func testAddNewProjectsIfNeeded() {
        let key = KeyValueStorageKey.todayProjects

        let sortProject: (Set<Project>) -> [Project] = { $0.map(identity).sorted { $0.id < $1.id } }

        let projects = ProjectResponse.mock.items

        try! Current.keyValueStorage.saveThrows(projects, forKey: key)

        let retriveProjects: Set<Project> = try! Current.keyValueStorage.loadThrows(key: key)

        XCTAssertEqual(projects |> sortProject, retriveProjects |> sortProject)

        var incomingProj = ProjectResponse.mock.items.map(identity)
        let otherIdx = incomingProj.firstIndex { $0.id == 9 }
        incomingProj[otherIdx!].des  = "new des"



        let newSaved = try! saveNewProjectsIfNeeded(projects: Set(incomingProj))
        
        XCTAssertTrue(newSaved.isEmpty)
        let newPr = Project.init(id: 100, name: "DonotKnow", wkTime: 8, oTime: 0, des: "", isOtApproved: false, localGitRepo: nil)
        let newPr2 = Project.init(id: 101, name: "DonotKnowwhatisthis", wkTime: 0, oTime: 0, des: "", isOtApproved: false, localGitRepo: nil)
        incomingProj.append(newPr)
        incomingProj.append(newPr2)
        let newSaved2 = try! saveNewProjectsIfNeeded(projects: Set(incomingProj))
        
        XCTAssertEqual(newSaved2 |> sortProject, [newPr, newPr2])
        
        
        do {
            let projToLog = try loadProjectFromStorageToLogSheet()
            XCTAssertEqual(projToLog |> sortProject, [.init(id: 9, name: "Other", wkTime: 4.5, oTime: 0, des: "Reading articles", isOtApproved: false, localGitRepo: nil), newPr])
        } catch let err {
            print(err)
        }
        
        
        
    }
   
    
    func testService() {
        
    }
    
    func testDecode() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let json = """
{\"status\":\"success\",\"items\":{\"9\":{\"name\":\"Other\",\"wkTime\":\"4.5\",\"oTime\":\"0\",\"des\":\"Reading articles\",\"is_ot_approved\":\"0\",\"countdown\":\"0.4s\"},\"224\":{\"name\":\"Training DEV\",\"wkTime\":0,\"oTime\":0,\"des\":\"\",\"is_ot_approved\":0,\"countdown\":\"0.8s\"},\"304\":{\"name\":\"Shopping App v1.2.3\",\"wkTime\":0,\"oTime\":0,\"des\":\"\",\"is_ot_approved\":0,\"countdown\":\"1.2s\"}},\"total\":4.5}
"""
        let data = json.data(using: .utf8)!
        
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(ProjectResponse.self, from: data)
            let sorted = response.items.sorted { $0.id < $1.id }
            
            let expected = ProjectResponse.mock.items.sorted { $0.id < $1.id }
                        
            XCTAssertEqual(sorted, expected)
            
        } catch let err {
            print(err)
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
