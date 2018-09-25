//
//  ProjectVC.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

final class ProjectVC: NSViewController {
    

    private var projects: [Project] = [] {
        didSet {
            print(self.projects)
            
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        _ = logInThenSaveCookie()
            .then {
                Current.service.getProjectStatusAt(date: Current.date()) }
            .map { $0.items }
            .map { (responsedProjects: Set<Project>) -> (Set<Project>) in
                let savedProjects: Set<Project>? = try? Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
                guard let _saved = savedProjects else { return responsedProjects }
                return rebind(responsedProjects: responsedProjects, savedProjects: _saved)
                
            }
            .done {
                self.projects = $0.map(identity) }
        
        
    }
    
}
extension ProjectVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
}

extension ProjectVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return 4
    }
    
}
