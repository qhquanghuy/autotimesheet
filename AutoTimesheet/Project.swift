//
//  Project.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/22/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation


struct ProjectResponse: Decodable, Equatable {
    let items: Set<Project>
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    
}
extension ProjectResponse {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let _items = try values.decode([String: Project].self, forKey: .items)
        self.items = Set.init(_items.values)
    }
    static let mock = ProjectResponse(items: [
        .mock,
        Project(id: 224, name: "Training DEV", wkTime: 0, oTime: 0, des: "", isOtApproved: false, localGitRepo: nil),
        Project(id: 304, name: "Shopping App v1.2.3", wkTime: 0, oTime: 0, des: "", isOtApproved: false, localGitRepo: nil)
    ])
}


public struct Project {
    let id: Int
    let name: String
    var wkTime: Double
    var oTime: Double
    var des: String
    let isOtApproved: Bool
    
    var localGitRepo: URL? = nil
   
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case wkTime
        case oTime
        case des
        case isOtApproved = "is_ot_approved"
        case localGitRepo
    }
    
}

extension Project: Codable {
        
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let _id = try? values.decode(Int.self, forKey: .id)
        if let id = _id {
            self.id = id
        } else {
            self.id = try optionalThrows(decoder.codingPath.first { $0.intValue != nil }?.intValue)
        }
        self.name = try values.decode(String.self, forKey: .name)
        self.des = try values.decode(String.self, forKey: .des)
        
        let _wkTime = try values.decode(Either<String, Double>.self, forKey: .wkTime)
        let _oTime = try values.decode(Either<String, Double>.self, forKey: .oTime)
        let _isOtApproved = try values.decode(Either<String, Int>.self, forKey: .isOtApproved)
        
        self.wkTime = try optionalThrows(_wkTime.bimap(left: { Double($0) }, right: identity).value)
        self.oTime = try optionalThrows(_oTime.bimap(left: { Double($0) }, right: identity).value)
        
        let int2bool = { $0 == 0 ? false : true }
        self.isOtApproved = try optionalThrows(_isOtApproved.bimap(left: { Int($0).map(int2bool) }, right: int2bool).value)
        
        self.localGitRepo = try values.decodeIfPresent(URL.self, forKey: .localGitRepo)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.wkTime, forKey: .wkTime)
        try container.encode(self.oTime, forKey: .oTime)
        try container.encode(self.des, forKey: .des)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.isOtApproved ? 1 : 0, forKey: .isOtApproved)
        try container.encodeIfPresent(self.localGitRepo, forKey: .localGitRepo)
    }
    
}

extension Project: Hashable {
   
}

extension Project {
    static let mock = Project(id: 9,
                              name: "Other",
                              wkTime: Current.configuration.defaultWkTime,
                              oTime: 0,
                              des: Current.configuration.defaultWkDes,
                              isOtApproved: false,
                              localGitRepo: URL.init(string: "/Users/macmini/Desktop/autotimesheet"))
}
