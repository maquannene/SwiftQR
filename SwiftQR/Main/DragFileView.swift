//
//  DragFileView.swift
//  SwiftQR
//
//  Created by 马权 on 16/09/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import SnapKit

class DragFileView: NSView {

    private var _filePath: String?
    private var _image: NSImage?
    lazy private var _titleTextField: NSTextField = NSTextField(frame: NSRect.zero)
    var receiveImageFile: ((_ image: NSImage) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        register(forDraggedTypes: [NSFilenamesPboardType])
        wantsLayer = true
        _titleTextField.with {
            $0.alignment = NSTextAlignment.center
            $0.isBordered = false
            $0.isEditable = false
            $0.textColor = NSColor(red: 150 / 255.0, green: 150 / 255.0, blue: 150 / 255.0, alpha: 1)
            $0.stringValue = "Drag Image To Decode"
            addSubview(_titleTextField)
            }.do {
                $0.snp.makeConstraints {
                    $0.center.equalTo(self)
                    $0.width.equalTo(self).offset(-10)
                }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let pasteboard = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let filePath = pasteboard[0] as? String,
            let image = NSImage(contentsOfFile: filePath) {
            _filePath = filePath
            _image = image
            return .copy
        }
        return NSDragOperation()
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        sender.draggingPasteboard().clearContents()
        if let image = _image {
            receiveImageFile?(image)
        }
        return true
    }
}

