//
//  ImageGalleryItem.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 11/8/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import Foundation
import UIKit

// Model of Image Gallery Document

struct ImageGallery: Codable {
    
    var name: String
    var images = [ImageProperties]()
    
    struct ImageProperties: Codable {
        
        var url: URL
        var widthHeightRatio: CGFloat
    }
    
    var json: Data? // return this image gallery as a JSON data
    {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) // Take a JSON data and turn it into an image gallery
    {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    init(name: String, images: [ImageProperties]) {
        self.name = name
        self.images = images
    }
    
}
