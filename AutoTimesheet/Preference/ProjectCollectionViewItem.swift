//
//  ProjectCollectionViewItem.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/26/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

final class ProjectCollectionViewItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem")
    
    
    var mainView: ProjectCollectionItemView { return self.view as! ProjectCollectionItemView }
    
    override func loadView() {
        self.view = ProjectCollectionItemView()
        self.view.wantsLayer = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
}
