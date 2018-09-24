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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
            
            let expected = ProjectResponse.mock
                        
            XCTAssertEqual(sorted, expected.items)
            
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
