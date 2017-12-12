//
//  HotKeySettingWindowController.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

class HotKeySettingWindowController: NSWindowController {
    
    var hotKeyViewController: HotKeySettingViewController? {
        get {
            if let controller = contentViewController as? HotKeySettingViewController {
                return controller
            }
            return nil
        }
    }
    
    open class func windowController() -> HotKeySettingWindowController? {
        if let controller = NSStoryboard(name: "Setting", bundle: nil).instantiateController(withIdentifier: String(describing: HotKeySettingWindowController.self)) as? HotKeySettingWindowController {
            return controller
        }
        return nil
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        window?.level = Int(CGWindowLevelKey.floatingWindow.rawValue)
        window?.title = "Hot Key"
    }
    
}

extension HotKeySettingWindowController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        hotKeyViewController?.close()
    }
    
}
