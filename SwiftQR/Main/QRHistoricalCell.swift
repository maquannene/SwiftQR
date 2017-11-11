//
//  QRHistoricalCell.swift
//  SwiftQR
//
//  Created by 马权 on 11/03/2017.
//  Copyright © 2017 马权. All rights reserved.
//

import Cocoa

class QRHistoricalCell: NSTableCellView {
    
    @IBOutlet weak var qrTextField: NSTextField!
    var showHandler: ((_ button: NSButton) -> Void)?
    var deleteHandler: ((_ button: NSButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        qrTextField.lineBreakMode = .byTruncatingMiddle
        qrTextField.wantsLayer = true
        qrTextField.layer?.borderColor =  NSColor(red: 150 / 255.0, green: 150 / 255.0, blue: 150 / 255.0, alpha: 1).cgColor
        qrTextField.layer?.borderWidth = 0.5
    }
    
    @IBAction func buttonAction(_ sender: NSButton) {
        showHandler?(sender)
    }
    
    @IBAction func deleteButtonAction(_ sender: NSButton) {
        deleteHandler?(sender)
    }
    
}
