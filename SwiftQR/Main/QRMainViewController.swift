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
import EFQRCode

private struct Constants {
    static let gap = 5
    static let width = 300
    static let qrCodeKeyValues = "qrCodeKeyValues"
    static let qrCodeKeyValueName = "name"
    static let qrCodeKeyValueCode = "code"
    
    static let TIFF = "public.tiff"
}

class QRMainViewController: NSViewController {
    
    fileprivate lazy var _encodeLable: NSTextField = NSTextField(frame: NSRect.zero)
    fileprivate lazy var _sqrCodeInputTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    fileprivate lazy var _sqrNameTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    fileprivate lazy var _generateButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _saveCacheButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _newCacheButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _cleanCacheButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _sqrImageView: NSImageView = NSImageView(frame: NSRect.zero)

    fileprivate lazy var _decodeLable: NSTextField = NSTextField(frame: NSRect.zero)
    fileprivate lazy var _dragReceiveImageFileView: DragFileView = DragFileView(frame: NSRect.zero)
    fileprivate lazy var _decodePasteBoardQrButton: NSButton = NSButton(frame: NSRect.zero)
    
    fileprivate lazy var _historicalTableView: NSTableView = NSTableView(frame: NSRect.zero)
    
    fileprivate var _cacheQRCodeKeyValues: Array<Dictionary<String, String>>
    fileprivate var _selectedIndex: Int?
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let userDefaultes: UserDefaults = UserDefaults.standard
        if let qrCodeKeyVaules = userDefaultes.object(forKey: Constants.qrCodeKeyValues) as? Array<Dictionary<String, String>> {
            _cacheQRCodeKeyValues = qrCodeKeyVaules
        }
        else {
            _cacheQRCodeKeyValues = Array<Dictionary<String, String>>()
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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        showDecodePasteBoardQrButtonIfNeed();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _encodeLable.with {
            $0.isBordered = false
            $0.isEditable = false
            $0.focusRingType = .none
            $0.stringValue = "Encode"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.width.equalTo(Constants.width)
                }
        }
        
        _sqrCodeInputTextFeild.with {
            $0.focusRingType = .none
            $0.placeholderString = "QR String"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_encodeLable.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(44)
                }
        }
        
        _sqrNameTextFeild.with {
            $0.focusRingType = .none
            $0.placeholderString = "Custom QR Name"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_sqrCodeInputTextFeild.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(24)
                }
        }
        
        _generateButton.with {
            $0.title = "Generate"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(_generateAction)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_sqrNameTextFeild.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.height.equalTo(24)
                }
        }
        
        _saveCacheButton.with {
            $0.title = "Save"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(_saveAction)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_generateButton.snp.top)
                    $0.left.equalTo(_generateButton.snp.right).offset(Constants.gap)
                    $0.width.height.equalTo(_generateButton)
                }
        }
        
        _newCacheButton.with {
            $0.title = "New"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(_newAction)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_saveCacheButton.snp.top)
                    $0.left.equalTo(_saveCacheButton.snp.right).offset(Constants.gap)
                    $0.width.height.equalTo(_saveCacheButton)
                }
        }
        
        _cleanCacheButton.with {
            $0.title = "Clean"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(_cleanAllCacheAction)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_newCacheButton.snp.top)
                    $0.left.equalTo(_newCacheButton.snp.right).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.width.height.equalTo(_newCacheButton)
                }
        }
        
        _sqrImageView.with {
            $0.wantsLayer = true
            $0.layer?.backgroundColor = NSColor.red.cgColor
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_cleanCacheButton.snp.bottom)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(0)
                }
        }
        
        _decodeLable.with {
            $0.isBordered = false
            $0.isEditable = false
            $0.focusRingType = .none
            $0.stringValue = "Decode"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_sqrImageView.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                }
        }

        _dragReceiveImageFileView.with {
            let border = CAShapeLayer()
            border.strokeColor = NSColor(red: 150 / 255.0, green: 150 / 255.0, blue: 150 / 255.0, alpha: 1).cgColor
            border.fillColor = nil
            border.path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: Constants.width, height: 48)).CGPath
            border.frame = NSRect(x: 0, y: 0, width: Constants.width, height: 48)
            border.lineWidth = 1
            border.lineCap = "square"
            border.lineDashPattern = [8, 4]
            $0.layer?.addSublayer(border)
            
            view.addSubview($0)
            $0.receiveImageFile = self.decodeImage
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_decodeLable.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(48)
                }
        }
        
        _decodePasteBoardQrButton.with {
            $0.title = "New QR In Paste Board?";
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(_decodeFromPasteBoard)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_dragReceiveImageFileView.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(24)
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
                    $0.top.equalTo(_decodePasteBoardQrButton.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view)
                    $0.right.equalTo(view)
                    $0.bottom.equalTo(view).offset(-Constants.gap)
                }
        }
    }
    
    fileprivate func storeQRCode(qrCode: String, qrName: String) {
        if let index = _cacheQRCodeKeyValues.index(where: { (keyValue) -> Bool in
            return keyValue[Constants.qrCodeKeyValueCode] == qrCode
        }) {
            _cacheQRCodeKeyValues.remove(at: index)
        }
        _cacheQRCodeKeyValues.insert([Constants.qrCodeKeyValueName : qrName, Constants.qrCodeKeyValueCode : qrCode], at: 0)
        UserDefaults.standard.set(_cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
    }
    
    fileprivate func deleteQRCode(with qrCode: String) {
        if let index = _cacheQRCodeKeyValues.index(where: { (keyValue) -> Bool in
            return keyValue[Constants.qrCodeKeyValueCode] == qrCode
        }) {
            _cacheQRCodeKeyValues.remove(at: index)
        }
        UserDefaults.standard.set(_cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
    }
    
    fileprivate func decodeImage(image: NSImage) {
        if let cgImage = image.toCGImage(),
            let decodeString = EFQRCode.recognize(image: cgImage)?.first as String? {
            //  显示当前
            _sqrCodeInputTextFeild.stringValue = decodeString
            _sqrNameTextFeild.stringValue = ""
            _generateAction()
        }
    }
}

extension QRMainViewController {
    func showDecodePasteBoardQrButtonIfNeed() -> Void {
        if let data = NSPasteboard.general().data(forType: Constants.TIFF),
            let image = NSImage(data: data),
            let cgImage = image.toCGImage(),
            let _ = EFQRCode.recognize(image: cgImage)?.first as String?{
            _decodePasteBoardQrButton.isHidden = false
            _decodePasteBoardQrButton.snp.updateConstraints {
                $0.height.equalTo(24);
                $0.top.equalTo(_dragReceiveImageFileView.snp.bottom).offset(Constants.gap)
            }
        }
        else {
            _decodePasteBoardQrButton.isHidden = true
            _decodePasteBoardQrButton.snp.updateConstraints {
                $0.height.equalTo(0);
                $0.top.equalTo(_dragReceiveImageFileView.snp.bottom)
            }
        }
    }
}

//  Action
private extension QRMainViewController {
    @objc  func _generateAction() {
        let qrCode = _sqrCodeInputTextFeild.stringValue
        if  qrCode.characters.count > 0 {
            if let image = EFQRCode.generate(content: qrCode) {
                //  update ui
                _sqrImageView.image = NSImage(cgImage: image, size: _sqrImageView.frame.size)
                _historicalTableView.reloadData()
                _sqrImageView.snp.updateConstraints {
                    $0.height.equalTo(Constants.width)
                }
            }
        }
        else {
            //  update ui
            _sqrImageView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
        }
    }

    @objc func _saveAction() {
        let qrCode = _sqrCodeInputTextFeild.stringValue
        if  qrCode.characters.count > 0 {
            let qrName = _sqrNameTextFeild.stringValue.characters.count > 0 ? _sqrNameTextFeild.stringValue : qrCode
            //  update data
            _selectedIndex = 0
            storeQRCode(qrCode: qrCode, qrName: qrName)
            //  update ui
            _historicalTableView.reloadData()
        }
    }
    
    @objc func _newAction() {
        //  update data
        _selectedIndex = nil
        //  update ui
        _sqrNameTextFeild.stringValue = ""
        _sqrCodeInputTextFeild.stringValue = ""
        _generateAction()
        _historicalTableView.reloadData()
    }
    
    @objc func _cleanAllCacheAction() {
        
        let alert = NSAlert(error: NSError(domain: "123", code: 0, userInfo: nil))
        alert.messageText = "Warning"
        alert.informativeText = "Confirm clean history?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clean")
        alert.addButton(withTitle: "Cancel")
        let action = alert.runModal()
        if action == NSAlertFirstButtonReturn {
            //  update data
            _selectedIndex = nil
            _cacheQRCodeKeyValues.removeAll()
            UserDefaults.standard.set(_cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
            //  update ui
            _historicalTableView.reloadData()
        }
        
        if action == NSAlertSecondButtonReturn {
            
        }
    }
    
    @objc func _decodeFromPasteBoard() {
        if let data = NSPasteboard.general().data(forType: Constants.TIFF),
            let image = NSImage(data: data) {
            decodeImage(image: image)
        }
    }
}

// Delegate
extension QRMainViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return _cacheQRCodeKeyValues.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.make(withIdentifier: QRHistoricalCell.className(), owner: self) as? QRHistoricalCell {
            if let keyValues = _cacheQRCodeKeyValues[row] as Dictionary<String, String>?,
                let name = keyValues[Constants.qrCodeKeyValueName] as String?,
                let code = keyValues[Constants.qrCodeKeyValueCode] as String? {
                cell.qrTextField?.stringValue = name
                cell.showHandler = { [weak self] button in
                    //  update data
                    self?._selectedIndex = row
                    //  update ui
                    self?._sqrCodeInputTextFeild.stringValue = code
                    self?._sqrNameTextFeild.stringValue = name
                    self?._generateAction()
                    self?._historicalTableView.reloadData()
                }
                cell.deleteHandler = { [weak self] button in
                    //  update data
                    if self?._selectedIndex == row {
                        self?._selectedIndex = nil
                    }
                    self?.deleteQRCode(with: code)
                    //  update ui
                    self?._historicalTableView.reloadData()
                }
            }
            
            if _selectedIndex == row {
                cell.qrTextField.layer?.borderWidth = 3
            }
            else {
                cell.qrTextField.layer?.borderWidth = 0.5
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




