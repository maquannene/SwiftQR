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
    
    init() {
        statusItem.do {
            $0.button?.target = self
            $0.button?.action = #selector(StatusItemManange.statusItemAction(button:))
            $0.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
            $0.button?.image = NSImage(named: "StatusBarItemIcon")
        }
        
        popver.do {
            $0.contentViewController = statusMainViewController
            $0.behavior = .transient
        }
        
        // 快捷键
        DDHotKeyCenter.shared().do {
            $0.registerHotKey(withKeyCode: UInt16(Int(0x09)),
                              modifierFlags: NSEventModifierFlags.control.rawValue,
                              target: self,
                              action: #selector(StatusItemManange.shortCut(event:)),
                              object: nil)
        }
        
        //
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            let _ = HotKey(keyCode: event.keyCode,
                           modifierFlags: event.modifierFlags,
                           charactersIgnoringModifiers: event.charactersIgnoringModifiers)
            return event
        }
    }
}

// MARK: - Public
extension StatusItemManange {
    func dealloc() {
        DDHotKeyCenter.shared().do {
            $0.unregisterHotKey(withKeyCode: UInt16(Int(0x09)),
                                modifierFlags: NSEventModifierFlags.control.rawValue)
        }
    }
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
    
    func showLeftClickPopver() {
        if let button = statusItem.button as NSButton? {
            popver.show(relativeTo: NSRect.zero, of: button, preferredEdge: NSRectEdge.minY)
            NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        }
    }
    
    func showRightClickMenu(on view: NSView) {
        NSMenu(title: "Setting").with {
            let keyCodeReadable = KeyCodeParse.keyStringFrom(characters: "V", modifierFlags: .option)
            $0.addItem(NSMenuItem(title: RightMouseMenu.hotkey.rawValue + "   " + keyCodeReadable.0 + " " + keyCodeReadable.1,
                                  action: nil,
                                  keyEquivalent: RightMouseMenu.hotkey.rawValue))
            $0.addItem(NSMenuItem.separator())
            $0.addItem(NSMenuItem(title: RightMouseMenu.quit.rawValue,
                                  action: #selector(StatusItemManange.quitAppAction(sender:)),
                                  keyEquivalent: RightMouseMenu.quit.rawValue).with { $0.target = self })
            }.do {
                statusItem.popUpMenu($0)
        }
    }
    
    /// shortCut
    @objc func shortCut(event: NSEvent) {
        if !popver.isShown {
            showLeftClickPopver()
        }
        else {
            popver.close()
        }
    }
    
    /// quit`
    @objc func quitAppAction(sender: Any) {
        NSApp.terminate(self)
    }
}
