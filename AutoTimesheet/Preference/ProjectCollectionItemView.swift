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
    
    var project: Project?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    private let lblProjectName = TextFiledWithTitle()
    
    private let lblDes = TextFiledWithTitle()
    
    private let lblHours = TextFiledWithTitle()
    
    
    private let lblLocalGit = TextFiledWithTitle()
    
    
    
    
    
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
        
//        self.lblProjectName.preferredMaxLayoutWidth = 0
//        self.lblDes.preferredMaxLayoutWidth = 0
//        self.lblHours.preferredMaxLayoutWidth = 0
//        self.lblLocalGit.preferredMaxLayoutWidth = 0
        
        
        self.lblProjectName.delegate = self
        self.lblDes.delegate = self
        self.lblHours.delegate = self
        self.lblLocalGit.delegate = self
            
    }
    
   
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func bind(project: Project) {
       
        self.project = project
        
        self.lblProjectName.stringValue = project.name
        self.lblDes.stringValue = project.des
        self.lblHours.stringValue = String(project.wkTime)
        self.lblLocalGit.stringValue = project.localGitRepo ?? ""
    }

    
    func headerStyle() {
        
        self.lblProjectName.textField |> labelStyle
        self.lblDes.textField |> labelStyle
        self.lblHours.textField |> labelStyle
        self.lblLocalGit.textField |> labelStyle
        
        
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

func isGitDirectory(urlStr: String) -> Bool {
    let isValid = try? Current.fileManager.contentsOfDirectory(atPath: urlStr)
    return isValid.map { $0.contains(".git") } ?? false
    
}

extension ProjectCollectionItemView : NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textF = obj.object as? NSTextField else { return }
        
        if textF == self.lblDes.textField {
            self.project?.des = textF.stringValue
            
        } else if textF == self.lblHours.textField {
            
            let characterSet = CharacterSet(charactersIn: "0123456789.").inverted
            self.lblHours.stringValue = self.lblHours
                                                .stringValue
                                                .components(separatedBy: characterSet)
                                                .joined(separator: "")
            
            if let doubleVal = Double(self.lblHours.stringValue) {
                self.project?.wkTime = doubleVal
            }
            
        } else if textF == self.lblLocalGit.textField {
            
            if isGitDirectory(urlStr: textF.stringValue) {
                self.project?.localGitRepo = textF.stringValue
                _ = getLastestGitLog(validUrl: textF.stringValue).done(on: DispatchQueue.main) { [weak self] log in
                    self?.lblDes.stringValue = log.subject
                    self?.project?.des = log.subject
                    self?.lblLocalGit.title = ""
                }
            } else {
                self.lblLocalGit.title = "INVALID URL"
                self.project?.localGitRepo = nil
            }
        } else {
            
        }
    }
}
