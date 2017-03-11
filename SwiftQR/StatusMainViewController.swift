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
}

class StatusMainViewController: NSViewController {
    
    lazy var sqrInputTextFeild: NSTextField = NSTextField(frame: NSRect.zero)
    lazy var sqrGenerateButton: NSButton = NSButton(frame: NSRect.zero)
    lazy var sqrImageView: NSImageView = NSImageView(frame: NSRect.zero)
    lazy var alertText: NSText = NSText(frame: NSRect.zero)

    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sqrInputTextFeild.with {
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
            $0.title = "生成二维码"
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
        
        sqrImageView.with {
            view.addSubview($0)
            }.do {
                $0.snp.makeConstraints {
                    $0.top.equalTo(sqrGenerateButton.snp.bottom).offset(Constants.gap)
                    $0.left.right.equalTo(view)
                    $0.bottom.equalTo(view).offset(-Constants.gap)
                    $0.height.equalTo(200)
                }
        }
    }
    
    func generateAction(button: NSButton) {
        let image = NSImage.mdQRCode(for: sqrInputTextFeild.stringValue, size: sqrImageView.frame.size.width)
        sqrImageView.image = image
    }
    
}
