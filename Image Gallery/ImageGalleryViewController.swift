//
//  ImageGalleryViewController.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 10/29/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

typealias ImageProperties = (url: URL, widthHeightratio: CGFloat)

class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
    
    // Model
    var imageList: [ImageProperties] = []
    
    
    
    // MARK: - Outlets

    @IBOutlet weak var imageGalleryCollectionView: UICollectionView! {
        
        didSet {
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.delegate = self
            imageGalleryCollectionView.dragDelegate = self
            imageGalleryCollectionView.dropDelegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Collection View Datasource Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGalleryCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageGalleryCollectionViewCell", for: indexPath)
        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            let url = imageList[indexPath.item].url
            imageCell.url = url
        }
        return cell
    }
    
    // MARK: - Collection View Flowlayout Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio = imageList[indexPath.item].widthHeightratio
        
        return CGSize(width: 100.0, height: 100.0 / ratio) // Default cell width is 80.0
    }
    
    // MARK: - Collection View Drag Delegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = imageGalleryCollectionView
        return dragsItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragsItem(at: indexPath)
    }
    
    private func dragsItem(at indexPath: IndexPath) -> [UIDragItem] {
        if let url = (imageGalleryCollectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.url {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: url as NSURL))
            dragItem.localObject = url
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: - Collection View Drop Delegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if let _ = session.localDragSession { // If draging from local app
            return session.canLoadObjects(ofClass: NSURL.self)
        } else { // Or drag from other resources
            return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == imageGalleryCollectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath { // Local drop an item
                
                imageGalleryCollectionView.performBatchUpdates({
                    let removedItem = imageList.remove(at: sourceIndexPath.item)
                    imageList.insert(removedItem, at: destinationIndexPath.item)
                    imageGalleryCollectionView.deleteItems(at: [sourceIndexPath])
                    imageGalleryCollectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                
            } else { // Drop from other resources
                
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceHolderCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = provider as? NSURL {
                        let session = URLSession(configuration: .default)
                        let imageURL = (url as URL).imageURL
                        let downloadTask = session.dataTask(with: imageURL) { (data, response, error) in
                            if error != nil {
                                return
                            } else {
                                if let imageData = data {
                                    if let image = UIImage(data: imageData) {
                                        let ratio = image.size.width / image.size.height
                                        DispatchQueue.main.async {
                                            placeHolderContext.commitInsertion(dataSourceUpdates: { insertIndexPath in
                                                self.imageList.insert((imageURL, ratio), at: insertIndexPath.item)
                                            })
                                        }
                                    }
                                } else {
                                    placeHolderContext.deletePlaceholder()
                                }
                            }
                        }
                        downloadTask.resume()
                    }
                }
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
