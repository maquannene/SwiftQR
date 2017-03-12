//
//  AppDelegate.swift
//  SwiftQR
//
//  Created by 马权 on 10/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import Then

enum RightMouseMenu: String {
    case quit = "Quit"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var popver: NSPopover!
    var statusMainViewController: StatusMainViewController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength).with {
            $0.button?.target = self
            $0.button?.action = #selector(AppDelegate.statusItemAction(button:))
            $0.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
            $0.button?.image = NSImage(named: "StatusBarItemIcon")
        }
        
        statusMainViewController = StatusMainViewController()
        popver = NSPopover().with {
            $0.contentViewController = statusMainViewController
            $0.behavior = .transient
        }
    }

    func statusItemAction(button: NSButton) {
        guard let event: NSEvent = NSApp.currentEvent else { return }
        if event.type == NSEventType.rightMouseDown {
            NSMenu(title: "Setting").with {
                $0.addItem(NSMenuItem(title: RightMouseMenu.quit.rawValue,
                                      action: #selector(AppDelegate.quitAppAction),
                                      keyEquivalent: RightMouseMenu.quit.rawValue))
                }.do {
                    statusItem.popUpMenu($0)
            }
        }
        else {
            popver.show(relativeTo: NSRect.zero, of: button, preferredEdge: NSRectEdge.minY)
            NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

extension AppDelegate {
    func quitAppAction(sender: Any) {
        NSApp.terminate(self)
    }
}

