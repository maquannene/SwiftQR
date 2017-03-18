//
//  SettingWindowController.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

class SettingWindowController: NSWindowController {
    
    open class func windowController() -> SettingWindowController? {
        if let controller = NSStoryboard(name: "Setting", bundle: nil).instantiateInitialController() as? SettingWindowController {
            return controller
        }
        return nil
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = window {
            window.level = Int(CGWindowLevelKey.floatingWindow.rawValue)
        }
    }

}
