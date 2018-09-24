//
//  StatusResponse.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation

struct ResponseError: LocalizedError {
    let errorDescription: String?
}


struct LogTimesheetResponse {
    let status: Status
    let message: String
    
    func validated() throws -> String {
        switch self.status {
        case .success:
            return self.message
        default:
            throw ResponseError(errorDescription: self.message)
        }
    }
}




enum Status: String {
    case success
    case error
}
extension LogTimesheetResponse: Decodable {
    
}
extension LogTimesheetResponse {
    static let mock: LogTimesheetResponse = .init(status: .error, message: "This day you absent")
}

extension Status: Decodable {
    
}
