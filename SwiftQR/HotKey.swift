//
//  HotKey.swift
//  SwiftQR
//
//  Created by 马权 on 17/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Foundation

struct HotKey {
    
    var keyCode: UInt16
    var modifierFlags: NSEventModifierFlags
    var charactersIgnoringModifiers: String?
    
    init(keyCode: UInt16, modifierFlags: NSEventModifierFlags, charactersIgnoringModifiers: String?) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
    }
    
}
