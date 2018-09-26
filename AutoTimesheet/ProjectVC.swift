//
//  ProjectVC.swift
//  AutoTimesheet
//
//  Created by Huy Nguyen on 9/23/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

final class ProjectVC: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var btnLognSave: NSButtonCell!
    
    private var projects: [Project] = []
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.configureLayout()
        _ = logInThenSaveCookie()
            .then { Current.service.getProjectStatusAt(date: Current.date()) }
            .map { $0.items }
            .map { (responsedProjects: Set<Project>) -> (Set<Project>) in
                let savedProjects: Set<Project>? = try? Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
                guard let _saved = savedProjects else { return responsedProjects }
                return rebind(responsedProjects: responsedProjects, savedProjects: _saved)
                
            }
            .done { self.projects = $0.map(identity) }
            .done { self.collectionView.reloadData() }
        
        
    }
    private func configureLayout() {
        let layout = self.collectionView.collectionViewLayout as! NSCollectionViewFlowLayout
        let size = CGSize(width: self.collectionView.frame.size.width, height: 40)
        
        layout.itemSize = size
        layout.headerReferenceSize = size
        
        
        self.collectionView.register(ProjectCollectionViewItem.self, forItemWithIdentifier: ProjectCollectionViewItem.identifier)
        
        self.collectionView.register(ProjectCollectionItemView.self, forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, withIdentifier: ProjectCollectionItemView.identifier)
        
        
        self.btnLognSave.action = #selector(onClickBtnLognSave)
        
        
    }
    
    
    @objc func onClickBtnLognSave() {
        self.updateAndSaveProjects()
        let projs = Set(self.projects).filter { $0.wkTime != 0 }
        _ = logInThenSaveCookie()
            .then { _ in AutoTimesheet.configureMessageThenLogTimesheet(projectsProvider: { projs }) }
            .done(Current.notifcation.localPush)
            .done { NSApp.setActivationPolicy(.accessory) }
            .catch { print("--------------------Error: \($0.localizedDescription)--------------------") }
        
        
    }
    
    ///TODO: implement validate total working times <= 8
    private func updateAndSaveProjects() {
        for idx in 0..<self.projects.count {
            self.collectionView.item(at: IndexPath(item: idx, section: 0))
                .flatMap { $0 as? ProjectCollectionViewItem }
                .flatMap { $0.mainView.project }
                .map { self.projects[$0.1] = $0.0 }
        }
        _ = Current.keyValueStorage
            .save(Set(self.projects), forKey: KeyValueStorageKey.todayProjects)
            .bimap(left: { print("----------Error: \($0.localizedDescription)--------------") }, right: identity)
    }
    
    
}
extension ProjectVC: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ProjectCollectionViewItem.identifier, for: indexPath) as! ProjectCollectionViewItem
        
        
        let idx = indexPath[1]
        item.mainView.bind(project: self.projects[idx], index: idx)
        return item
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: ProjectCollectionItemView.identifier, for: indexPath) as! ProjectCollectionItemView
            header.headerStyle()
            
            
            return header
            
        } else {
            return NSView()
        }
        
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
}


extension ProjectVC: NSCollectionViewDelegateFlowLayout {
}
extension ProjectVC: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        self.updateAndSaveProjects()
    }
    
    
}
