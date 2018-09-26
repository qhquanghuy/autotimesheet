//
//  Credentials&Configurations.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/26/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation


struct Credential {
    let email: String = "quanghuy.nguyen@savvycomsoftware.com"
    let password: String = "123456789"
}

struct Configuration {
    var fireTime: DateComponents = {
        var _fireTime = 17.hours
        _fireTime.minute = 30
        _fireTime.second = 0
        return _fireTime
    }()
    
    var fireInterval = 1.days
    
    var defaultWkTime = 4.5
    var defaultWkDes = "Reading articles"
    
    static let mock = Configuration(fireTime: {
        return Calendar.current.dateComponents([.hour, .minute, .second], from: Date().addingTimeInterval(10))
    }(), fireInterval: 1.minutes, defaultWkTime: 4.5, defaultWkDes: "Reading articles")
}
