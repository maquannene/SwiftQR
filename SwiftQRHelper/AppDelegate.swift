//
//  AppDelegate.swift
//  SwiftQRHelper
//
//  Created by 马权 on 2017/12/11.
//  Copyright © 2017年 马权. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let mainAppIdentifier = "maquannene.SwiftQR"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty
        
        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self,
                                                                selector: #selector(self.terminate),
                                                                name: .killLauncher,
                                                                object: mainAppIdentifier)
            
            let bundlePath = Bundle.main.bundlePath as NSString
            var pathComponents: [String] = bundlePath.pathComponents
            pathComponents = Array(pathComponents[0..<(pathComponents.count - 4)])
            let path: String = NSString.path(withComponents: pathComponents)
            NSWorkspace.shared.launchApplication(path)
        }
        else {
            self.terminate()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

