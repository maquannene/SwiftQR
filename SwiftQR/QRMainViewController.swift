//
//  StatusMainViewController.swift
//  SwiftQR
//
//  Created by 马权 on 10/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa
import Then
import SnapKit

private struct Constants {
    static let gap = 5
    static let qrCodeKeyValues = "qrCodeKeyValues"
    static let qrCodeKeyValueName = "name"
    static let qrCodeKeyValueCode = "code"
}

class QRMainViewController: NSViewController {
    
    lazy var sqrCodeInputTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    lazy var sqrNameTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    lazy var generateButton: NSButton = NSButton(frame: NSRect.zero)
    lazy var saveCacheButton: NSButton = NSButton(frame: NSRect.zero)
    lazy var cleanCacheButton: NSButton = NSButton(frame: NSRect.zero)
    lazy var _historicalTableView: NSTableView = NSTableView(frame: NSRect.zero)
    lazy var _sqrImageView: NSImageView = NSImageView(frame: NSRect.zero)
    
    var cacheQRCodeKeyValues: Array<Dictionary<String, String>>
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let userDefaultes: UserDefaults = UserDefaults.standard
        if let qrCodeKeyVaules = userDefaultes.object(forKey: Constants.qrCodeKeyValues) as? Array<Dictionary<String, String>> {
            cacheQRCodeKeyValues = qrCodeKeyVaules
        }
        else {
            cacheQRCodeKeyValues = Array<Dictionary<String, String>>()
        }
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sqrCodeInputTextFeild.with {
            $0.focusRingType = .none
            $0.placeholderString = "QR String"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.width.equalTo(250)
                    $0.height.equalTo(40)
                }
        }
        
        sqrNameTextFeild.with {
            $0.focusRingType = .none
            $0.placeholderString = "Custom QR Name"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(sqrCodeInputTextFeild.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.width.equalTo(250)
                    $0.height.equalTo(24)
                }
        }
        
        generateButton.with {
            $0.title = "Generate"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(self.generateAction(button:))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(sqrNameTextFeild.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.height.equalTo(24)
                }
        }
        
        saveCacheButton.with {
            $0.title = "Save"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(self.saveCacheAction(button:))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(generateButton.snp.top)
                    $0.left.equalTo(generateButton.snp.right).offset(Constants.gap)
                    $0.height.equalTo(24)
                }
        }
        
        cleanCacheButton.with {
            $0.title = "Clean"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(self.cleanAllCacheAction(button:))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(saveCacheButton)
                    $0.left.equalTo(saveCacheButton.snp.right).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(saveCacheButton)
                }
        }
    
        _historicalTableView.with {
            let nib = NSNib(nibNamed: String(describing: QRHistoricalCell.self), bundle: Bundle.main)
            $0.register(nib, forIdentifier: QRHistoricalCell.className())
            $0.delegate = self
            $0.dataSource = self
            $0.focusRingType = .none
            $0.addTableColumn(NSTableColumn(identifier: "First"))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(saveCacheButton.snp.bottom).offset(3)
                    $0.left.equalTo(view)
                    $0.right.equalTo(view)
                }
        }
        
        _sqrImageView.with {
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_historicalTableView.snp.bottom)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.bottom.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(0)
                }
        }
    }
    
    fileprivate func storeQRCode(qrCode: String, qrName: String) {
        if let index = cacheQRCodeKeyValues.index(where: { (keyValue) -> Bool in
            return keyValue[Constants.qrCodeKeyValueCode] == qrCode
        }) {
            cacheQRCodeKeyValues.remove(at: index)
        }
        cacheQRCodeKeyValues.insert([Constants.qrCodeKeyValueName : qrName, Constants.qrCodeKeyValueCode : qrCode], at: 0);
        if cacheQRCodeKeyValues.count > 5 {
            cacheQRCodeKeyValues.removeLast()
        }
        UserDefaults.standard.set(cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
    }
    
    fileprivate func deleteQRCode(with qrCode: String) {
        if let index = cacheQRCodeKeyValues.index(where: { (keyValue) -> Bool in
            return keyValue[Constants.qrCodeKeyValueCode] == qrCode
        }) {
            cacheQRCodeKeyValues.remove(at: index)
        }
        UserDefaults.standard.set(cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
    }
    
}

//  Action
extension QRMainViewController {
    func generateAction(button: NSButton) {
        let qrCode = sqrCodeInputTextFeild.stringValue
        if  qrCode.characters.count > 0 {
            let image = NSImage.mdQRCode(for: qrCode, size: _sqrImageView.frame.size.width)
            _sqrImageView.image = image
            _historicalTableView.reloadData()
            _sqrImageView.snp.updateConstraints {
                $0.top.equalTo(_historicalTableView.snp.bottom).offset(Constants.gap)
                $0.height.equalTo(250)
            }
        }
        else {
            _sqrImageView.snp.updateConstraints {
                $0.top.equalTo(_historicalTableView.snp.bottom)
                $0.height.equalTo(0)
            }
        }
    }
    
    func saveCacheAction(button: NSButton) {
        let qrCode = sqrCodeInputTextFeild.stringValue
        if  qrCode.characters.count > 0 {
            let qrName = sqrNameTextFeild.stringValue.characters.count > 0 ? sqrNameTextFeild.stringValue : qrCode
            storeQRCode(qrCode: qrCode, qrName: qrName)
            _historicalTableView.reloadData()
        }
    }
    
    func cleanAllCacheAction(button: NSButton) {
        
        let alert = NSAlert(error: NSError(domain: "123", code: 0, userInfo: nil))
        alert.messageText = "Warning"
        alert.informativeText = "Confirm clean history?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clean")
        alert.addButton(withTitle: "Cancel")
        let action = alert.runModal()
        if action == NSAlertFirstButtonReturn {
            cacheQRCodeKeyValues.removeAll()
            UserDefaults.standard.set(cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
            _historicalTableView.reloadData()
        }
        
        if action == NSAlertSecondButtonReturn {

        }
    }
}

// Delegate
extension QRMainViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cacheQRCodeKeyValues.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.make(withIdentifier: QRHistoricalCell.className(), owner: self) as? QRHistoricalCell {
            if let keyValues = cacheQRCodeKeyValues[row] as Dictionary<String, String>?,
                let name = keyValues[Constants.qrCodeKeyValueName] as String?,
                let code = keyValues[Constants.qrCodeKeyValueCode] as String? {
                cell.qrTextField?.stringValue = name
                cell.editHandler = { [weak self] in
                    self?.sqrCodeInputTextFeild.stringValue = code
                    self?.sqrNameTextFeild.stringValue = name
                    self?.generateAction(button: $0)
                }
                cell.deleteHandler = { [weak self] button in
                    self?.deleteQRCode(with: code)
                    self?._historicalTableView.reloadData()
                }
            }
            
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}






