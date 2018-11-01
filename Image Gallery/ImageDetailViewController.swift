//
//  ImageDetailViewController.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 10/31/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {
    
    // Image to display
    var image = UIImage() {
        didSet {
            imageView.image = image
            imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        }
    }
    
    private var imageView = UIImageView()
    
    @IBOutlet weak var viewHolder: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
            
            let size = image.size
            
            scrollView.zoomScale = 1.0
            scrollView.contentSize = size
        }
    }
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewDidLayoutSubviews() {
        
        let size = image.size
        scrollViewHeight.constant = size.height
        scrollViewWidth.constant = size.width
        
        // Zoom image to optimize space
        scrollView.zoomScale = max(viewHolder.bounds.size.width / image.size.width, viewHolder.bounds.size.height / image.size.height)
    }
}
