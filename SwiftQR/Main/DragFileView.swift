//
//  DragFileView.swift
//  SwiftQR
//
//  Created by 马权 on 16/09/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import SnapKit

class DragFileView: NSImageView {

    private var _filePath: String?
    private var _image: NSImage?
    var receiveImageFile: ((_ image: NSImage) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        register(forDraggedTypes: [NSFilenamesPboardType])
        wantsLayer = true
        image = NSImage(named: "scan")
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

