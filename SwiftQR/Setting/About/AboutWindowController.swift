//
//  AboutWindowController.swift
//  SwiftQR
//
//  Created by 马权 on 2017/12/12.
//  Copyright © 2017年 马权. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    var rootViewController: AboutViewController? {
        get {
            if let controller = contentViewController as? AboutViewController {
                return controller
            }
            return nil
        }
    }
    
    open class func windowController() -> AboutWindowController? {
        if let controller = NSStoryboard(name: "Setting", bundle: nil).instantiateController(withIdentifier: String(describing: AboutWindowController.self)) as? AboutWindowController {
            return controller
        }
        return nil
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
        shouldCascadeWindows = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = Int(CGWindowLevelKey.floatingWindow.rawValue)
        window?.title = "About"
    }

}
