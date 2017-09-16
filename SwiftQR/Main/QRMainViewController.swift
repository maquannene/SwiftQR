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
    static let qrCodeKeyValues = "qrCodeKeyValues"
    static let qrCodeKeyValueName = "name"
    static let qrCodeKeyValueCode = "code"
    
    static let TIFF = "public.tiff"
}

class QRMainViewController: NSViewController {
    
    fileprivate lazy var _sqrCodeInputTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    fileprivate lazy var _sqrNameTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    fileprivate lazy var _generateButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _saveCacheButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _cleanCacheButton: NSButton = NSButton(frame: NSRect.zero)
    fileprivate lazy var _historicalTableView: NSTableView = NSTableView(frame: NSRect.zero)
    fileprivate lazy var _sqrImageView: NSImageView = NSImageView(frame: NSRect.zero)
    
    fileprivate lazy var _dragReceiveImageFileView: DragFileView = DragFileView(frame: NSRect.zero)
    fileprivate lazy var _decodePasteBoardQrButton: NSButton = NSButton(frame: NSRect.zero)
    
    fileprivate var _cacheQRCodeKeyValues: Array<Dictionary<String, String>>
    
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
        
        _sqrCodeInputTextFeild.with {
            $0.focusRingType = .none
            $0.placeholderString = "QR String"
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.width.equalTo(250)
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
                    $0.width.equalTo(250)
                    $0.height.equalTo(24)
                }
        }
        
        _generateButton.with {
            $0.title = "Generate"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(generateAction)
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
            $0.action = #selector(saveCacheAction)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_generateButton.snp.top)
                    $0.left.equalTo(_generateButton.snp.right).offset(Constants.gap)
                    $0.height.equalTo(24)
                }
        }
        
        _cleanCacheButton.with {
            $0.title = "Clean"
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(cleanAllCacheAction(button:))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_saveCacheButton)
                    $0.left.equalTo(_saveCacheButton.snp.right).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(_saveCacheButton)
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
                    $0.top.equalTo(_saveCacheButton.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view)
                    $0.right.equalTo(view)
                }
        }
        
        _sqrImageView.with {
            $0.wantsLayer = true
            $0.layer?.backgroundColor = NSColor.red.cgColor
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_historicalTableView.snp.bottom)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(0)
                }
        }
        
        _dragReceiveImageFileView.with {
            let border = CAShapeLayer()
            border.strokeColor = NSColor(red: 150 / 255.0, green: 150 / 255.0, blue: 150 / 255.0, alpha: 1).cgColor
            border.fillColor = nil
            border.path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 250, height: 48)).CGPath
            border.frame = NSRect(x: 0, y: 0, width: 250, height: 48)
            border.lineWidth = 1
            border.lineCap = "square"
            border.lineDashPattern = [8, 4]
            $0.layer?.addSublayer(border)
            
            view.addSubview($0)
            $0.receiveImageFile = self.decodeImage
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_sqrImageView.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(48)
                }
        }
        
        _decodePasteBoardQrButton.with {
            $0.title = "New QR In Paste Board?";
            $0.bezelStyle = .rounded
            $0.target = self
            $0.action = #selector(decodeFromPasteBoard)
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(_dragReceiveImageFileView.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.bottom.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(24)
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
            generateAction()
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
                $0.bottom.equalTo(view).offset(-Constants.gap);
            }
        }
        else {
            _decodePasteBoardQrButton.isHidden = true
            _decodePasteBoardQrButton.snp.updateConstraints {
                $0.height.equalTo(0);
                $0.bottom.equalTo(view).offset(0);
            }
        }
    }
}

//  Action
private extension QRMainViewController {
    @objc  func generateAction() {
        let qrCode = _sqrCodeInputTextFeild.stringValue
        if  qrCode.characters.count > 0 {
            if let image = EFQRCode.generate(content: qrCode) {
                _sqrImageView.image = NSImage(cgImage: image, size: _sqrImageView.frame.size)
                _historicalTableView.reloadData()
                _sqrImageView.snp.updateConstraints {
                    $0.height.equalTo(250)
                }
            }
        }
        else {
            _sqrImageView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
        }
    }

    @objc func saveCacheAction() {
        let qrCode = _sqrCodeInputTextFeild.stringValue
        if  qrCode.characters.count > 0 {
            let qrName = _sqrNameTextFeild.stringValue.characters.count > 0 ? _sqrNameTextFeild.stringValue : qrCode
            storeQRCode(qrCode: qrCode, qrName: qrName)
            _historicalTableView.reloadData()
        }
    }
    
    @objc func cleanAllCacheAction(button: NSButton) {
        
        let alert = NSAlert(error: NSError(domain: "123", code: 0, userInfo: nil))
        alert.messageText = "Warning"
        alert.informativeText = "Confirm clean history?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clean")
        alert.addButton(withTitle: "Cancel")
        let action = alert.runModal()
        if action == NSAlertFirstButtonReturn {
            _cacheQRCodeKeyValues.removeAll()
            UserDefaults.standard.set(_cacheQRCodeKeyValues, forKey: Constants.qrCodeKeyValues)
            _historicalTableView.reloadData()
        }
        
        if action == NSAlertSecondButtonReturn {
            
        }
    }
    
    @objc func decodeFromPasteBoard() {
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
                cell.editHandler = { [weak self] button in
                    self?._sqrCodeInputTextFeild.stringValue = code
                    self?._sqrNameTextFeild.stringValue = name
                    self?.generateAction()
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




