//
//  ImageGalleryDocument.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 11/8/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var imageGallery: ImageGallery? // Model of this document
    
    // Turn model into data
    override func contents(forType typeName: String) throws -> Any {
        return imageGallery?.json ?? Data()
    }
    
    // Turn a JSON data into model
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            imageGallery = ImageGallery(json: json)
        }
    }

}
