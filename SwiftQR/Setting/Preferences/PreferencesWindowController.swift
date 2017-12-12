//
//  PreferencesWindowController.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    
    var hotKeyViewController: PreferencesViewController? {
        get {
            if let controller = contentViewController as? PreferencesViewController {
                return controller
            }
            return nil
        }
    }
    
    open class func windowController() -> PreferencesWindowController? {
        if let controller = NSStoryboard(name: "Setting", bundle: nil).instantiateController(withIdentifier: String(describing: PreferencesWindowController.self)) as? PreferencesWindowController {
            return controller
        }
        return nil
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        window?.level = Int(CGWindowLevelKey.floatingWindow.rawValue)
        window?.title = "Preferences"
    }
    
}

extension PreferencesWindowController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        hotKeyViewController?.close()
    }
    
}
