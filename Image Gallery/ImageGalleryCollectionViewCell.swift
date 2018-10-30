//
//  ImageGalleryCollectionViewCell.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 10/29/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var imageView: UIImageView!
    
    var url = URL(string: "") {
        didSet {
            DispatchQueue.global().async {
                let imageData = try? Data(contentsOf: self.url!)
                    DispatchQueue.main.async {
                        self.imageView?.image = UIImage(data: imageData!)
                    }
                }
            }
        }
}

