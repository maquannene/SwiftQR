//
//  HotKeySettingViewController.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

class HotKeySettingViewController: NSViewController {
    
    @IBOutlet weak var hotKeyButton: NSButton!
    @IBOutlet weak var userDefaultHotKeyButton: NSButton!
    fileprivate var _monitor: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
        _monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] (event) -> NSEvent? in
            if let window = self?.view.window as NSWindow?, window.isKeyWindow,
                self?.view.window?.firstResponder == self?.hotKeyButton {
                HotKeyCenter.shared.regist(keyCode: event.keyCode,
                                           modifierFlags: event.modifierFlags)
                self?.hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
            }
            return event
        }
    }
    
    func close() {
        if let monitor = _monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    @IBAction func setHotKeyAction(_ sender: Any) {
        if view.window?.firstResponder == hotKeyButton {
            self.view.window?.makeFirstResponder(nil)
        }
        else {
            view.window?.makeFirstResponder(hotKeyButton)
        }
    }
    
    @IBAction func userDefaultHotKeyAction(_ sender: Any) {
        self.view.window?.makeFirstResponder(nil)
        HotKeyCenter.shared.registDefault()
        hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
    }
    
}
