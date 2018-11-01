//
//  ImageGalleryTableViewCell.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 10/29/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.isEnabled = false
        }
    }
    
    var currentText = "" {
        didSet {
            textField?.text = currentText
        }
    }
}
