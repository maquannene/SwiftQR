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
    static let qrStringsKey = "QRStringsKey"
}

class StatusMainViewController: NSViewController {
    
    lazy var sqrInputTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    lazy var sqrGenerateButton: NSButton = NSButton(frame: NSRect.zero)
    lazy var tableViewContainerView: NSScrollView = NSScrollView(frame: NSRect.zero)
    lazy var historicalTableView: NSTableView = NSTableView(frame: NSRect.zero)
    lazy var sqrImageView: NSImageView = NSImageView(frame: NSRect.zero)
    lazy var alertText: NSText = NSText(frame: NSRect.zero)
    
    var cacheQRStrings: Array<String>
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let userDefaultes: UserDefaults = UserDefaults.standard
        if let qrStrings = userDefaultes.object(forKey: Constants.qrStringsKey) as? Array<String> {
            cacheQRStrings = qrStrings
        }
        else {
            cacheQRStrings = Array<String>()
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sqrInputTextFeild.with {
            $0.focusRingType = .none
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.left.equalTo(view).offset(Constants.gap)
                    $0.right.equalTo(view).offset(-Constants.gap)
                    $0.width.equalTo(200)
                    $0.height.equalTo(40)
                }
        }
        
        sqrGenerateButton.with {
            $0.title = "Generate QR Code"
            $0.target = self
            $0.action = #selector(StatusMainViewController.generateAction(button:))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(sqrInputTextFeild.snp.bottom).offset(Constants.gap);
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.height.equalTo(30)
                }
        }
    
        historicalTableView.with {
            let nib = NSNib(nibNamed: String(describing: QRHistoricalCell.self), bundle: Bundle.main)
            $0.register(nib, forIdentifier: QRHistoricalCell.className())
            $0.delegate = self
            $0.dataSource = self
            $0.focusRingType = .none
            $0.addTableColumn(NSTableColumn(identifier: "First"))
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(sqrGenerateButton.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view)
                    $0.right.equalTo(view)
                }
        }
        
        sqrImageView.with {
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(historicalTableView.snp.bottom).offset(Constants.gap)
                    $0.left.equalTo(view).offset(Constants.gap)
                    $0.right.bottom.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(200)
                }
        }
    }
    
    func generateAction(button: NSButton) {
        let qrString = sqrInputTextFeild.stringValue
        if  qrString.characters.count > 0 {
            let image = NSImage.mdQRCode(for: qrString, size: sqrImageView.frame.size.width)
            sqrImageView.image = image
            storeQRString(qrString: qrString)
            historicalTableView.reloadData()
        }
        else {
            
        }
    }
    
    func storeQRString(qrString: String) {
        if let index = cacheQRStrings.index(of: qrString) as Int? {
            cacheQRStrings.remove(at: index)
        }
        cacheQRStrings.insert(qrString, at: 0)
        if cacheQRStrings.count > 5 {
            cacheQRStrings.removeLast()
        }
        UserDefaults.standard.set(cacheQRStrings, forKey: Constants.qrStringsKey)
    }
    
}

extension StatusMainViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cacheQRStrings.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.make(withIdentifier: QRHistoricalCell.className(), owner: self) as? QRHistoricalCell {
            if let qrString = cacheQRStrings[row] as String? {
                cell.textField?.stringValue = qrString
                    cell.buttonHandler = { [weak self] in
                        self?.sqrInputTextFeild.stringValue = qrString
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






