//
//  StatusItemManange.swift
//  SwiftQR
//
//  Created by 马权 on 2017/3/14.
//  Copyright © 2017年 马权. All rights reserved.
//

import Foundation

enum RightMouseMenu: String {
    case hotkey = "Hot Key"
    case quit = "Quit"
}

class StatusItemManange {
    
    var statusItem: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var popver: NSPopover = NSPopover()
    var statusMainViewController: StatusMainViewController = StatusMainViewController()
    var settingWindowController:SettingWindowController?
    
    init() {
        _ = HotKeyCenter.shared.regist(observer: self, selector: #selector(self.hotKeyAction(event:)))
        
        statusItem.do {
            $0.button?.target = self
            $0.button?.action = #selector(self.statusItemAction(button:))
            $0.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
            $0.button?.image = NSImage(named: "StatusBarItemIcon")
        }
        
        popver.do {
            $0.contentViewController = statusMainViewController
            $0.behavior = .transient
        }
    }
    
    func showLeftClickPopver() {
        if let button = statusItem.button as NSButton? {
            popver.show(relativeTo: NSRect.zero, of: button, preferredEdge: NSRectEdge.minY)
            NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        }
    }
    
    func showRightClickMenu(on view: NSView) {
        NSMenu(title: "Setting").with {
            let item = NSMenuItem(title: RightMouseMenu.hotkey.rawValue,
                                  action: #selector(self.showSettingContoller(sender:)),
                                  keyEquivalent: HotKeyCenter.shared.hotKey.keyCodeReadable.lowercased()).with { $0.target = self }
            item.keyEquivalentModifierMask = [.option]
            $0.addItem(item)
            $0.addItem(NSMenuItem.separator())
            $0.addItem(NSMenuItem(title: RightMouseMenu.quit.rawValue,
                                  action: #selector(self.quitAppAction(sender:)),
                                  keyEquivalent: RightMouseMenu.quit.rawValue).with { $0.target = self })
            }.do {
                statusItem.popUpMenu($0)
        }
    }
}

// MARK: - Public
extension StatusItemManange {
}

// MARK: - Action
extension StatusItemManange {
    
    /// statusItemClick
    @objc func statusItemAction(button: NSButton) {
        guard let event: NSEvent = NSApp.currentEvent else { return }
        if event.type == NSEventType.leftMouseDown {
            showLeftClickPopver()
        }
        else {
            showRightClickMenu(on: button)
        }
    }
    
    /// shortCut
    @objc func hotKeyAction(event: NSEvent) {
        if !popver.isShown {
            showLeftClickPopver()
        }
        else {
            popver.close()
        }
    }
    
    @objc func showSettingContoller(sender: Any) {
        NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        settingWindowController = SettingWindowController.windowController()
        settingWindowController?.showWindow(self)
    }
    
    /// quit`
    @objc func quitAppAction(sender: Any) {
        NSApp.terminate(self)
    }
}
