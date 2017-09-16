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
    
    fileprivate var _statusItem: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    fileprivate var _popver: NSPopover = NSPopover()
    fileprivate var _settingWindowController:HotKeySettingWindowController?
    
    init() {
        _ = HotKeyCenter.shared.regist(observer: self, selector: #selector(self.hotKeyAction(event:)))
        
        _statusItem.do {
            $0.button?.target = self
            $0.button?.action = #selector(self.statusItemAction(button:))
            $0.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
            $0.button?.image = NSImage(named: "StatusBarItemIcon")
        }
        
        _popver.do {
            $0.contentViewController = QRMainViewController()
            $0.behavior = .transient
        }
    }
    
    fileprivate func showLeftClickPopver() {
        if let button = _statusItem.button as NSButton? {
            NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            _popver.show(relativeTo: NSRect.zero, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    fileprivate func showRightClickMenu(on view: NSView) {
        NSMenu(title: "Setting").with {
            let item = NSMenuItem(title: RightMouseMenu.hotkey.rawValue,
                                  action: #selector(showSettingContoller(sender:)),
                                  keyEquivalent: HotKeyCenter.shared.hotKey.keyCodeReadable.lowercased()).with { $0.target = self }
            item.keyEquivalentModifierMask = [.option]
            $0.addItem(item)
            $0.addItem(NSMenuItem.separator())
            $0.addItem(NSMenuItem(title: RightMouseMenu.quit.rawValue,
                                  action: #selector(quitAppAction(sender:)),
                                  keyEquivalent: RightMouseMenu.quit.rawValue).with { $0.target = self })
            }.do {
                _statusItem.popUpMenu($0)
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
        if !_popver.isShown {
            showLeftClickPopver()
        }
        else {
            _popver.close()
        }
    }
    
    @objc func showSettingContoller(sender: NSMenuItem) {
        if let window = _settingWindowController?.window as NSWindow?, window.isVisible {
            return
        }
        NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        _settingWindowController = HotKeySettingWindowController.windowController()
        _settingWindowController?.showWindow(self)
    }
    
    /// quit
    @objc func quitAppAction(sender: Any) {
        NSApp.terminate(self)
    }
}
