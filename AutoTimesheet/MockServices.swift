//
//  MockServices.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/22/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import PromiseKit
import Alamofire

struct MockService: ServiceType {

    
    
    func login(credential: Credential) -> Promise<(json: Any, response: PMKAlamofireDataResponse)> {
        let json = """
        
{
"status":"success",
"token":"vbVlWV16MriA72LJb6MR3l2F5uqXtlqZxmktimA4NSEUUpE6wqYzL0fRvGPZ2gYzDi3VFDZswEnr41yAsw9exp625V28c0HPjKLYoLrUpPmuRU4jqexXED0Jz3RM3zCnknmJ8OEyD02uU7OllljZZkJznBlraXOvlbetZS2CT57OcV9xhtxhNgRbRcD2aryvDMZCF1fy",
"role":"member"
}
"""
        let request = try! URLRequest(url: "https://timesheet.savvycom.vn/users/loginAction", method: .post)
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: ["set-cookie": "SMS2014=h1qpgtc0u6g597k96pf0ia4383; path=/; domain=.timesheet.savvycom.vn; Secure; HttpOnly; Expires=Tue, 19 Jan 2038 03:14:07 GMT;"])
        
        let dataResponse = DataResponse<String>.init(request: request,
                                                     response: response,
                                                     data: json.data(using: .utf8),
                                                     result: .success(json))
        let pmkResponse = PMKAlamofireDataResponse.init(dataResponse)
        
        return Promise.value((json: json as Any, response: pmkResponse))
    }
    
    func getProjectStatusAt(date: Date = Date()) -> Promise<ProjectResponse> {
        
        return Promise.value(.mock)
    }
    
    
    func logTimesheet(for projects: Set<Project>, at date: Date) -> Promise<LogTimesheetResponse> {
        
        return Promise.value(LogTimesheetResponse.mock)
        
    }

    
}

