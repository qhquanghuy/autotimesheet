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
            .then { Current.service.getProjectStatusAt(date: Current.utcDate()) }
            .map { $0.items }
            .map { (responsedProjects: Set<Project>) -> (Set<Project>) in
                let savedProjects: Set<Project>? = try? Current.keyValueStorage.loadThrows(key: KeyValueStorageKey.todayProjects)
                guard let _saved = savedProjects else { return responsedProjects }
                return rebind(responsedProjects: responsedProjects, savedProjects: _saved)
                
            }
            .then(configureLogTimesheetMessage)
            .done { self.projects = $0.map(identity).sorted { $0.id < $1.id } }
            .done { self.collectionView.reloadData() }
        
        
    }
    private func configureLayout() {
        let layout = self.collectionView.collectionViewLayout as! NSCollectionViewFlowLayout
        let size = CGSize(width: self.collectionView.frame.size.width, height: 48)
        
        layout.itemSize = size
        layout.headerReferenceSize = size
        
        
        self.collectionView.register(ProjectCollectionViewItem.self, forItemWithIdentifier: ProjectCollectionViewItem.identifier)
        
        self.collectionView.register(ProjectCollectionItemView.self, forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, withIdentifier: ProjectCollectionItemView.identifier)
        
        
        self.btnLognSave.action = #selector(onClickBtnLognSave)
        
        
    }
    
    
    
    
    @objc func onClickBtnLognSave() {
        
        _ = self.updateAndSaveProjects()
            .bimap(left: showAlert, right: { $0.filter { $0.wkTime != 0 } })
            .map { projs in
                logInThenSaveCookie()
                    .then { _ in Current.service.logTimesheet(for: projs, at: Current.utcDate()) }
                    .map {
                        NotificationDetail(subtitle: $0.status.rawValue.uppercased(),
                                              infomativeText: $0.message + (projs |> formatLoggedMessage)) }
                    .done(Current.notifcation.localPush)
                    .done { NSApp.setActivationPolicy(.accessory) }
                    .catch { print("--------------------Error: \($0.localizedDescription)--------------------") }
        }
        
        
    }
    
    
    /// get projects that filled working time
    ///
    /// - Parameter projects: [Project]
    /// - Returns: message if all is not filled or all filled projects
    func validateIfFilledWkTime(projects: [Project]) -> Either<String, [Project]> {
        let filledWkProjects = projects.filter { $0.wkTime != 0 }
        return filledWkProjects.isEmpty ? .left("Working time's must not empty") : .right(projects)
    }
    
    func validateWkTimeInRange(projects: [Project]) -> Either<String, [Project]> {
        let totalWk = projects.reduce(0) { $0 + $1.wkTime }
        return !(0...8.5).contains(totalWk) ?
            .left("Total Working time's must not higher than 8 or lower than 0") :
            .right(projects)
    }
    
    func validateEitherDesOrLocalGitRepoFilled(projects: [Project]) -> Either<String, [Project]> {
        return !projects.filter { $0.des.isEmpty && $0.localGitRepo == nil && $0.wkTime != 0 }.isEmpty ?
            .left("One of Des and Local git Repo is must not empty") :
            .right(projects)
    }
    
    ///TODO: implement validate total working times <= 8
    private func updateAndSaveProjects() -> Either<String, Set<Project>>{
        let projectsFromItems = (0..<self.projects.count)
                                        .map { IndexPath(item: $0, section: 0) }
                                        .compactMap(self.collectionView.item)
                                        .compactMap { $0 as? ProjectCollectionViewItem }
                                        .compactMap { $0.mainView.project }
        
        let validated = projectsFromItems |>
                            validateIfFilledWkTime
                        >=> validateWkTimeInRange
                        >=> validateEitherDesOrLocalGitRepoFilled
        
        return validated
            .map(Set.init)
            .flatMap {
                Current.keyValueStorage
                    .save($0, forKey: KeyValueStorageKey.todayProjects)
                    .bimap(left: { $0.localizedDescription }, right: const($0))
        }
    }
    
    
}
extension ProjectVC: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ProjectCollectionViewItem.identifier, for: indexPath) as! ProjectCollectionViewItem
        
        
        let idx = indexPath[1]
        item.mainView.bind(project: self.projects[idx])
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
        return self.updateAndSaveProjects()
            .bimap(left: { str -> Bool in
                showAlert(message: str)
                return false
            }, right: const(true)).value
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

    }
    
    
}
func showAlert(message: String) {
    let detail = NotificationDetail.init(subtitle: "", infomativeText: message)
    _ = Current.notifcation.windowAlert(notification: detail)
}
