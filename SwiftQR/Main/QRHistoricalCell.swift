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
    var editHandler: ((_ button: NSButton) -> Void)?
    var deleteHandler: ((_ button: NSButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        qrTextField.lineBreakMode = .byTruncatingMiddle
    }
    
    @IBAction func buttonAction(_ sender: NSButton) {
        editHandler?(sender)
    }
    
    @IBAction func deleteButtonAction(_ sender: NSButton) {
        deleteHandler?(sender)
    }
    
}
