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
    @IBOutlet weak var button: NSButton!
    var buttonHandler: ((_ button: NSButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        qrTextField.lineBreakMode = .byTruncatingMiddle
    }
    
    @IBAction func buttonAction(_ sender: NSButton) {
        buttonHandler?(sender)
    }
}
