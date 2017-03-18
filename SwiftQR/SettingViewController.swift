//
//  SettingViewController.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {
    
    @IBOutlet weak var hotKeyButton: NSButton!
    @IBOutlet weak var userDefaultHotKeyButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        self.hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            HotKeyCenter.shared.regist(keyCode: event.keyCode, modifierFlags: event.modifierFlags)
            self.hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
            return event
        }
    }
    
    @IBAction func setHotKeyAction(_ sender: Any) {
        
    }
    
    @IBAction func userDefaultHotKeyAction(_ sender: Any) {
        HotKeyCenter.shared.regist(keyCode: HotKeyCenter.defaultKeyCode, modifierFlags: HotKeyCenter.defaultModifierFlags)
        self.hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
    }
}
