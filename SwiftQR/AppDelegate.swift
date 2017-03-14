//
//  AppDelegate.swift
//  SwiftQR
//
//  Created by 马权 on 10/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import Then

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItemManage: StatusItemManange = StatusItemManange()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        statusItemManage.dealloc()
    }
}

