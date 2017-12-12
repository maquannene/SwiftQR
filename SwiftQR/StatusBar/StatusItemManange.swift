//
//  StatusItemManange.swift
//  SwiftQR
//
//  Created by 马权 on 2017/3/14.
//  Copyright © 2017年 马权. All rights reserved.
//

import Foundation

enum RightMouseMenu: String {
    case cleanHistory = "Clean History"
    case hotkey = "Hot Key"
    case about = "About"
    case quit = "Quit"
}

class StatusItemManange {
    
    fileprivate var _statusItem: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    fileprivate var _popver: NSPopover = NSPopover()
    fileprivate var _mainViewController = QRMainViewController()
    fileprivate var _settingWindowController: HotKeySettingWindowController?
    fileprivate var _aboutWindowController: AboutWindowController?
    
    init() {
        _ = HotKeyCenter.shared.regist(observer: self, selector: #selector(self.hotKeyAction(event:)))
        
        _statusItem.do {
            $0.button?.target = self
            $0.button?.action = #selector(self.statusItemAction(button:))
            $0.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
            $0.button?.image = NSImage(named: "StatusBarItemIcon")
        }
        
        _popver.do {
            $0.contentViewController = _mainViewController
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
            let cleanHistoryItem = NSMenuItem(title: RightMouseMenu.cleanHistory.rawValue,
                                              action: #selector(cleanHistorAction(sender:)),
                                              keyEquivalent: "").with {
                                                $0.target = self
            }
            let shortCutSettingItem = NSMenuItem(title: RightMouseMenu.hotkey.rawValue,
                                                 action: #selector(showHotKeySettingContoller(sender:)),
                                                 keyEquivalent: HotKeyCenter.shared.hotKey.keyCodeReadable.lowercased()).with {
                                                    $0.target = self
                                                    $0.keyEquivalentModifierMask = [HotKeyCenter.shared.hotKey.modifierFlags]
            }
            let aboutItem = NSMenuItem(title: RightMouseMenu.about.rawValue,
                                       action: #selector(showAboutController),
                                       keyEquivalent: "").with {
                                        $0.target = self
            }
            let quitItem = NSMenuItem(title: RightMouseMenu.quit.rawValue,
                                      action: #selector(quitAppAction(sender:)),
                                      keyEquivalent: "q").with {
                                        $0.target = self
                                        $0.keyEquivalentModifierMask = [.command]
            }
            $0.addItem(cleanHistoryItem)
            $0.addItem(shortCutSettingItem)
            $0.addItem(NSMenuItem.separator())
            $0.addItem(aboutItem)
            $0.addItem(NSMenuItem.separator())
            $0.addItem(quitItem)
            }.do {
                _statusItem.popUpMenu($0)
        }
    }
}

// MARK: - Private
extension StatusItemManange {
    
}

// MARK: - Public
extension StatusItemManange {
    
}

// MARK: - Action
private extension StatusItemManange {
    
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
    
    /// clean History setting
    @objc func cleanHistorAction(sender: Any) {
        _statusItem.button?.highlight(false)
        _mainViewController.cleanHistory()
    }
    
    /// about
    @objc func showAboutController() {
        _statusItem.button?.highlight(false)
        if let window = _aboutWindowController?.window as NSWindow?, window.isVisible {
            return
        }
        NSRunningApplication.current().activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        _aboutWindowController = AboutWindowController.windowController()
        _aboutWindowController?.showWindow(self)
    }
    
    /// shortCut setting
    @objc func showHotKeySettingContoller(sender: NSMenuItem) {
        _statusItem.button?.highlight(false)
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
