//
//  AppDelegate.swift
//  SwiftQR
//
//  Created by 马权 on 10/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import Then

import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItemManage: StatusItemManange = StatusItemManange()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let launcherAppId = "maquannene.SwiftQRHelper"
        let runningApps = NSWorkspace.shared().runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        SMLoginItemSetEnabled(launcherAppId as CFString, true)
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {

    }
}

