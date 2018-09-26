//
//  ProjectCollectionItemView.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/26/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

class ProjectCollectionItemView: NSView {
    
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "CollectionViewHeader")
    
    var project: (Project, Int)?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    private let lblProjectName: NSTextField = {
        let lbl = NSTextField()
        lbl.isEditable = false
        lbl.isBordered = false
        return lbl
    }()
    
    private let lblDes: NSTextField = {
        let lbl = NSTextField()
        lbl.isEditable = true
        return lbl
    }()
    
    
    private let lblHours: NSTextField = {
        let lbl = NSTextField()
        lbl.isEditable = true
        return lbl
    }()
    
    
    private let lblLocalGit: NSTextField = {
        let lbl = NSTextField()
        lbl.isEditable = true
        return lbl
    }()
    
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self.lblProjectName, constraints: [
            equal(\.leadingAnchor, constant: 8),
            equal(\.centerYAnchor)
            ])
        
        
        
        self.addSubview(self.lblDes, constraints: [
            equal(\.centerYAnchor)
            ])
        
        equal(\.leadingAnchor, \.trailingAnchor)(self.lblDes, self.lblProjectName).isActive = true
        
        
        self.addSubview(self.lblHours, constraints: [
            equal(\.centerYAnchor)
            ])
        
        equal(\.leadingAnchor, \.trailingAnchor)(self.lblHours, self.lblDes).isActive = true
        
        
        self.addSubview(self.lblLocalGit, constraints: [
            equal(\.trailingAnchor, constant: -8),
            equal(\.centerYAnchor)
            ])
        equal(\.trailingAnchor, \.leadingAnchor)(self.lblHours, self.lblLocalGit).isActive = true
        self.lblProjectName.widthAnchor.constraint(equalToConstant: 112).isActive = true
        self.lblHours.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.lblLocalGit.widthAnchor.constraint(equalToConstant: 320).isActive = true
        
        self.lblProjectName.preferredMaxLayoutWidth = 0
        self.lblDes.preferredMaxLayoutWidth = 0
        self.lblHours.preferredMaxLayoutWidth = 0
        self.lblLocalGit.preferredMaxLayoutWidth = 0
        
        
        self.lblProjectName.delegate = self
        self.lblDes.delegate = self
        self.lblHours.delegate = self
        self.lblLocalGit.delegate = self
            
    }
    
   
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func bind(project: Project, index: Int) {
        self.project = (project, index)
        
        self.lblProjectName.stringValue = project.name
        self.lblDes.stringValue = project.des
        self.lblHours.stringValue = String(project.wkTime)
        self.lblLocalGit.stringValue = project.localGitRepo?.absoluteString ?? ""
    }

    
    func headerStyle() {
        
        self.lblDes |> labelStyle
        self.lblHours |> labelStyle
        self.lblLocalGit |> labelStyle
        
        
        self.lblProjectName.stringValue = "Project name"
        self.lblDes.stringValue = "Description"
        self.lblHours.stringValue = "Working time"
        self.lblLocalGit.stringValue = "Local git repo"
        
    }
}
func labelStyle(for textF: NSTextField) {
    textF.isEditable = false
    textF.isBordered = false
}
extension ProjectCollectionItemView : NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textF = obj.object as? NSTextField else { return }
        
        if textF == self.lblDes {
            self.project?.0.des = textF.stringValue
        } else if textF == self.lblHours {
            self.project?.0.wkTime = Double(textF.stringValue)!
        } else if textF == self.lblLocalGit {
            self.project?.0.localGitRepo = textF.stringValue |> URL.init
        } else {
            
        }
    }
}
