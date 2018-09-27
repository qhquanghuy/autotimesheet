//
//  GitLog.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/27/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Foundation
import PromiseKit

struct GitLog: Decodable {
    let subject: String
    let authorName: String
    let authorEmail: String
    let date: Date
    
    static let jsonFormat = """
--pretty=format:{%n    "subject": "%s",%n    "authorName": "%aN",%n    "authorEmail": "%aE",%n    "date": "%aI"%n  },
"""
}


func shell(launchPath: String, arguments: [String]) -> String {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
        //remove newline character.
        let lastIndex = output.index(before: output.endIndex)
        return String(output[output.startIndex ..< lastIndex])
    }
    return output
}

func bash(command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
}





func getLastestGitLog(validUrl: String) -> Promise<GitLog> {
    let author = Current.credential.email
    let date = Current.utcDate()
    let beforeDateStr = Current.dateFormater.string(from: date)
    let afterDateStr = Current.dateFormater.string(from: date - 1.days.timeInterval)
    
    let promise = Promise<String> { resolver in
        DispatchQueue.global(qos: .userInteractive).async {
            let logStr = bash(command: "git", arguments: ["-C", validUrl,
                                                          "log", GitLog.jsonFormat,
                                                          "--after", "\(afterDateStr) 00:00",
                                                        "--before", "\(beforeDateStr) 00:00"])
            let arrLog = "[\(logStr)]"
            print(arrLog)
            resolver.fulfill(arrLog)
        }
    }
    
    
    
    return promise
            .map { arrLog -> [GitLog] in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([GitLog].self, from: arrLog.data(using: .utf8)!)
            }
            .map { gitLogs in gitLogs.filter { $0.authorEmail == author }.sorted { $0.date > $1.date } }
            .firstValue
    
    
}
