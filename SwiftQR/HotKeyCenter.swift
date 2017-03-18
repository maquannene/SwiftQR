//
//  HotKeyCenter.swift
//  SwiftQR
//
//  Created by 马权 on 18/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

class HotKey: NSObject, NSCoding {
    
    var keyCode: UInt16
    var modifierFlags: NSEventModifierFlags
    
    var hotKeyStringReadable: String {
        get {
            let string: String = KeyCodeParse.keyStringFrom(keyCode: keyCode, modifierFlags: modifierFlags)
            return string
        }
    }
    
    var keyCodeReadable: String {
        get {
            return KeyCodeParse.keyStringFrom(keyCode: keyCode, modifierFlags: modifierFlags).1
        }
    }
    
    var modifierFlagsReadable: String {
        get {
            return KeyCodeParse.keyStringFrom(keyCode: keyCode, modifierFlags: modifierFlags).0
        }
    }

    init(keyCode: UInt16, modifierFlags: NSEventModifierFlags) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(Int32(keyCode), forKey: "keyCode")
        aCoder.encode(Int32(modifierFlags.rawValue), forKey: "modifierFlags")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {        
        let keyCode = UInt16(aDecoder.decodeInteger(forKey: "keyCode"))
        let modifierFlags = NSEventModifierFlags(rawValue: UInt(aDecoder.decodeInteger(forKey: "modifierFlags")))
        self.init(keyCode: keyCode,
                  modifierFlags: modifierFlags)
    }
}

final class HotKeyCenter {
 
    static let shared: HotKeyCenter = HotKeyCenter()
    static let defaultKeyCode = UInt16(0x09)
    static let defaultModifierFlags = NSEventModifierFlags.control
    static let hotKeyIndenfierKey: String = "hotKeyIndenfierKey.HotKeyCenter"
    
    private weak var _observer: AnyObject?
    private var _selector: Selector?
    var _hotKey: HotKey
    open var hotKey: HotKey {
        get {
            return _hotKey
        }
    }
    
    private init() {
        if let hotKeyData = UserDefaults.standard.object(forKey: HotKeyCenter.hotKeyIndenfierKey) as? Data,
           let hotKey = NSKeyedUnarchiver.unarchiveObject(with: hotKeyData) as? HotKey {
            _hotKey = hotKey
        }
        else {
            _hotKey = HotKey(keyCode: HotKeyCenter.defaultKeyCode,
                             modifierFlags: HotKeyCenter.defaultModifierFlags)
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: _hotKey),
                                      forKey: HotKeyCenter.hotKeyIndenfierKey)
        }
    }
    
    public var hotKeyCore: DDHotKeyCenter = DDHotKeyCenter.shared()
    
    public func regist(observer: AnyObject, selector: Selector) {
        _observer = observer
        _selector = selector
        if let hotKey = _hotKey as HotKey? {
            DDHotKeyCenter.shared().do {
                $0.unregisterAllHotKeys()
                $0.registerHotKey(withKeyCode: hotKey.keyCode,
                                  modifierFlags: hotKey.modifierFlags.rawValue,
                                  target: _observer,
                                  action: _selector,
                                  object: nil)
            }
        }
    }
    
    public func regist(keyCode: UInt16, modifierFlags: NSEventModifierFlags) {
        if modifierFlags.rawValue & NSEventModifierFlags.control.rawValue == 0 &&
            modifierFlags.rawValue & NSEventModifierFlags.option.rawValue == 0 &&
            modifierFlags.rawValue & NSEventModifierFlags.shift.rawValue == 0 &&
            modifierFlags.rawValue & NSEventModifierFlags.command.rawValue == 0 {
            return
        }
        _hotKey = HotKey(keyCode: keyCode,
                         modifierFlags: modifierFlags)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: _hotKey),
                                  forKey: HotKeyCenter.hotKeyIndenfierKey)
        if let hotKey = _hotKey as HotKey? {
            DDHotKeyCenter.shared().do {
                $0.unregisterAllHotKeys()
                $0.registerHotKey(withKeyCode: hotKey.keyCode,
                                  modifierFlags: hotKey.modifierFlags.rawValue,
                                  target: _observer,
                                  action: _selector,
                                  object: nil)
            }
        }
        
    }
}
