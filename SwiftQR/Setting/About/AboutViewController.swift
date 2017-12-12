//
//  AboutViewController.swift
//  SwiftQR
//
//  Created by 马权 on 2017/12/12.
//  Copyright © 2017年 马权. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    @IBOutlet weak var _versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoDic = Bundle.main.infoDictionary
    
        if let appVersion = infoDic?["CFBundleShortVersionString"] as? String, let appBuildVersion = infoDic?["CFBundleVersion"] as? String {
            _versionLabel.stringValue = "Version " + appVersion + "(" + appBuildVersion + ")"
        }
    }
    
}
