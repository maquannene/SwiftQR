//
//  KeyCodeParse.swift
//  SwiftQR
//
//  Created by 马权 on 16/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

struct KeyCodeParse {
    static let REPLACE_MAP: Dictionary<String, String> = [
        "\r"   : "↵",
        "\u{1B}"   : "⎋",
        "\t"   : "⇥",
        "\u{19}" : "⇤",
        " "    : "␣",
        "\u{7f}" : "⌫",
        "\u{03}" : "⌤",
        "\u{10}" : "⏏",
        "\u{F728}" : "⌦",
        "\u{F739}" : "⌧",
        "\u{F704}" : "[F1]",
        "\u{F705}" : "[F2]",
        "\u{F706}" : "[F3]",
        "\u{F707}" : "[F4]",
        "\u{F708}" : "[F5]",
        "\u{F709}" : "[F6]",
        "\u{F70A}" : "[F7]",
        "\u{F70B}" : "[F8]",
        "\u{F70C}" : "[F9]",
        "\u{F70D}" : "[F10]",
        "\u{F70E}" : "[F11]",
        "\u{F70F}" : "[F12]",
        
        "\u{F700}" : "↑",
        "\u{F701}" : "↓",
        "\u{F702}" : "←",
        "\u{F703}" : "→",
        "\u{F72C}" : "⇞",
        "\u{F72D}" : "⇟",
        "\u{F729}" : "↖",
        "\u{F72B}" : "↘",
        ]
    
    static func keyStringFrom(keyCode:UInt16, modifierFlags: NSEventModifierFlags)->(String) {
        let strings: (String, String) = self.keyStringFrom(keyCode: keyCode, modifierFlags: modifierFlags)
        return strings.0 + strings.1
    }
    
    static func keyStringFrom(keyCode:UInt16, modifierFlags: NSEventModifierFlags)->(String, String) {
        var mod = ""
        if modifierFlags.rawValue & NSEventModifierFlags.control.rawValue != 0 {
            mod += "⌃"
        }
        if modifierFlags.rawValue & NSEventModifierFlags.option.rawValue != 0 {
            mod += "⌥"
        }
        if modifierFlags.rawValue & NSEventModifierFlags.shift.rawValue != 0 {
            mod += "⇧"
        }
        if modifierFlags.rawValue & NSEventModifierFlags.command.rawValue != 0 {
            mod += "⌘"
        }
        
        let char = keyToReadable(string: keyName(scanCode: keyCode)?.uppercased() ?? "")
        
        return (mod, char)
    }
    
    static func keyToReadable(string: String)-> String {
        var str = string
        for (k, v) in REPLACE_MAP {
            str = str.replacingOccurrences(of: k, with: v)
        }
        return str
    }
    
    static func keyName(scanCode: UInt16) -> String? {
        let maxNameLength = 4
        var nameBuffer = [UniChar](repeating: 0, count : maxNameLength)
        var nameLength = 0
        
        let modifierKeys = UInt32(alphaLock >> 8) & 0xFF // Caps Lock
        var deadKeys: UInt32 = 0
        let keyboardType = UInt32(LMGetKbdType())
        
        let source = TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue()
        guard let ptr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            NSLog("Could not get keyboard layout data")
            return nil
        }
        let layoutData = Unmanaged<CFData>.fromOpaque(ptr).takeUnretainedValue() as Data
        let osStatus = layoutData.withUnsafeBytes {
            UCKeyTranslate($0, scanCode, UInt16(kUCKeyActionDown),
                           modifierKeys, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask),
                           &deadKeys, maxNameLength, &nameLength, &nameBuffer)
        }
        guard osStatus == noErr else {
            NSLog("Code: 0x%04X  Status: %+i", scanCode, osStatus);
            return nil
        }
        
        return  String(utf16CodeUnits: nameBuffer, count: nameLength)
    }
}
