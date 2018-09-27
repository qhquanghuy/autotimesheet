//
//  TextFiledWithTitle.swift
//  AutoTimesheet
//
//  Created by HuyNguyen on 9/27/18.
//  Copyright © 2018 Savvycom JSC. All rights reserved.
//

import Cocoa

final class TextFiledWithTitle: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    private let lblTitle: NSTextField = {
        let lbl = NSTextField()
        lbl.isEditable = false
        lbl.isBordered = false
        return lbl
    }()
    
    let textField: NSTextField = {
        let lbl = NSTextField()
        lbl.isEditable = true
        return lbl
    }()
    
    var stringValue: String {
        get {
            return self.textField.stringValue
        }
        
        set {
            self.textField.stringValue = newValue
        }
    }
    
    var delegate: NSTextFieldDelegate? {
        get {
            return self.textField.delegate
        }
        set {
            self.textField.delegate = newValue
        }
    }
    
    var title: String {
        get {
            return self.lblTitle.stringValue
        }
        
        set {
            self.lblTitle.stringValue = newValue
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.lblTitle.preferredMaxLayoutWidth = 0
        self.textField.preferredMaxLayoutWidth = 0
        let stackView = NSStackView.init(views: [self.lblTitle, self.textField])
        
        stackView.distribution = .fill
        stackView.alignment = .left
        stackView.orientation = .vertical
        
        self.addSubview(stackView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
            ])
        
        
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

