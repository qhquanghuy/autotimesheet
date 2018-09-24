//
//  Services.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/22/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import PromiseKit


protocol ServiceType {
    
    
    func login(credential: Credential) -> Promise<(json: Any, response: PMKAlamofireDataResponse)>
    func getProjectStatusAt(date: Date) -> Promise<ProjectResponse>
    func logTimesheet(for projects: [Project], at date: Date) -> Promise<LogTimesheetResponse>
}


struct TimesheetService: ServiceType {
    
    let header = Alamofire.SessionManager.defaultHTTPHeaders
   
    
    func login(credential: Credential) -> Promise<(json: Any, response: PMKAlamofireDataResponse)> {
        return Alamofire.request("https://timesheet.savvycom.vn/users/loginAction",
                                 method: .post,
                                 parameters: ["email": credential.email,
                                              "password": credential.password],
                                 encoding: URLEncoding.default,
                                 headers: self.header).responseJSON()
    }
    
    func getProjectStatusAt(date: Date = Date()) -> Promise<ProjectResponse> {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy"
        let param: [String: Any] = [
            "date": formatter.string(from: date)
        ]
        return Alamofire.request("https://timesheet.savvycom.vn/users/getTimesheetLoging",
                                 method: .post,
                                 parameters: param,
                                 encoding: JSONEncoding.default,
                                 headers: self.header).responseDecodable()
        
    }
    
    
    func logTimesheet(for projects: [Project], at date: Date) -> Promise<LogTimesheetResponse> {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy"
        
        let param: [String: Any] = [
            "date": formatter.string(from: date),
            "items": projects.map { proj in
                return [
                    "des": proj.des,
                    "id": proj.id,
                    "oTime": proj.oTime,
                    "wkTime": proj.wkTime
                ]
                
            }
        ]
        
        return Alamofire.request("https://timesheet.savvycom.vn/users/timeSheets",
                                 method: .post,
                                 parameters: param,
                                 encoding: JSONEncoding.default,
                                 headers: header)
                        .responseDecodable()
           
        
    }

}

