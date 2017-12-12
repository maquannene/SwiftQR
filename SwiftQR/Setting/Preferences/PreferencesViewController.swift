//
//  PreferencesViewController.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

private struct PreferencesConstants {
    static let kLaunchAtLogIn = "SwiftQR" + ".kLaunchAtLogIn"
    static let kSwiftQRHelperIndentifier = "maquannene.SwiftQRHelper"
}

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var hotKeyButton: NSButton!
    @IBOutlet weak var userDefaultHotKeyButton: NSButton!
    @IBOutlet weak var launchLogInCheckedButton: NSButtonCell!
    fileprivate var _monitor: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        hotKeyButton.title = HotKeyCenter.shared.hotKey.hotKeyStringReadable
        
        if let checked = UserDefaults.standard.object(forKey: PreferencesConstants.kLaunchAtLogIn) as? Bool {
            launchLogInCheckedButton.state = checked == true ? NSOnState : NSOffState
        }
        
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
    
    @IBAction func launchAtLogInAction(_ sender: NSButton) {
        
        let checked = sender.state == NSOnState
        let runningApps = NSWorkspace.shared().runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == PreferencesConstants.kSwiftQRHelperIndentifier }.isEmpty
        
        SMLoginItemSetEnabled(PreferencesConstants.kSwiftQRHelperIndentifier as CFString, checked)
        
        UserDefaults.standard.set(checked, forKey: PreferencesConstants.kLaunchAtLogIn)
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
    }
    
}
