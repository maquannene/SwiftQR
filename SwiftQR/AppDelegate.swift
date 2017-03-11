//
//  AppDelegate.swift
//  SwiftQR
//
//  Created by 马权 on 10/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var popver: NSPopover!
    var statusMainViewController: StatusMainViewController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(AppDelegate.statusItemAction(button:))
        statusItem.button?.image = NSImage(named: "QQ20170310-0")
        
        statusMainViewController = StatusMainViewController()
        popver = NSPopover()
        popver.contentViewController = statusMainViewController
        popver.behavior = .transient
    }

    func statusItemAction(button: NSButton) {
        popver.show(relativeTo: NSRect.zero, of: button, preferredEdge: NSRectEdge.minY)
        NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

