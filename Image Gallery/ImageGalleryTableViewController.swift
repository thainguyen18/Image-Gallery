//
//  ImageGalleryTableViewController.swift
//  Image Gallery
//
//  Created by Thai Nguyen on 10/29/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

typealias ImageGalleryItem = (name: String, images: [ImageProperties])

class ImageGalleryTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Models
    
    // Model is 2D array of 2 elements, each element is a an array of image gallery items
    
    var galleryList:[[ImageGalleryItem]] = [[("Untitled", [])], []]
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return galleryList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return galleryList[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Available Galleries"
        } else if section == 1 {
            return "Recently Deleted"
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Image Gallery Tableview Cell", for: indexPath)
        
        // Configure the cell...
        if let imageGalleryCell = cell as? ImageGalleryTableViewCell {
            imageGalleryCell.currentText = galleryList[indexPath.section][indexPath.row].name
            
            // Add double tap gesture to table view cell
            setUpDoubleTapGesture(for: imageGalleryCell)
            
            // Set self to text field delegate
            imageGalleryCell.textField.delegate = self
        }
        
        return cell
    }
    
    // MARK: - Add more items
    
    @IBAction func addMoreGallery(_ sender: Any) {
        let untitledEntries = galleryList[0].filter({$0.name.contains("Untitled")}).map({$0.name})
        
        let itemsIn1stSection = galleryList[0].count
        
        
        galleryList[0].append(("Untitled".madeUnique(withRespectTo: untitledEntries), []))
        
        tableView.insertRows(at: [IndexPath(row: itemsIn1stSection, section: 0)], with: .automatic)
    }
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    // MARK: - Table View Delegate
    
    private var startUpIndex: IndexPath?
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? indexPath : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If no selection initial then set current image gallery to selected row and update model
        if startUpIndex == nil {
            detailVC?.selectedGalleryIndexPath = indexPath
            detailVC?.navigationItem.title = galleryList[indexPath.section][indexPath.row].name
            //galleryList[indexPath.section][indexPath.row].images = detailVC?.imagesList ?? []
            startUpIndex = indexPath
            return
        }
        
        if indexPath.section == 0 {
            performSegue(withIdentifier: "Display Image Gallery", sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Restore", handler: { [weak self] (action, sourceView, completionHandler) in
            
            tableView.performBatchUpdates({
                let gallery = self?.galleryList[1].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.galleryList[0].insert(gallery ?? ("", []), at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }, completion: nil)
            
            completionHandler(true)
        })
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        return indexPath.section == 1 ? swipeAction : nil
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                
                // Update model and move row to recently deleted
                tableView.performBatchUpdates({
                    let gallery = galleryList[0].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    galleryList[1].append(gallery)
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                    }, completion: nil)
                
            } else if indexPath.section == 1 {
                // Delete the row from the data source
                tableView.performBatchUpdates({
                    galleryList[1].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }, completion: nil)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let igvc = (segue.destination as? UINavigationController)?.visibleViewController as? ImageGalleryViewController {
            if let igtvCell = sender as? ImageGalleryTableViewCell {
                if let indexPath = tableView.indexPath(for: igtvCell) {
                    
                    // Pass the images to collection view, only with selected gallery from section 0
                    
                        igvc.selectedGalleryIndexPath = indexPath
                        //igvc.imagesList = galleryList[indexPath.section][indexPath.row].images
                    
                    
                    igvc.navigationItem.title = galleryList[indexPath.section][indexPath.row].name
                }
            }
        }
    }
    
    
    private var detailVC: ImageGalleryViewController? {
        return (splitViewController?.viewControllers.last as? UINavigationController)?.visibleViewController as? ImageGalleryViewController
    }
    
    
    // MARK: - Double Tap Gesture Recognizer
    
    private func setUpDoubleTapGesture(for tableViewCell: UITableViewCell) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapTableViewCell(by:)))
        gesture.numberOfTapsRequired = 2
        tableViewCell.addGestureRecognizer(gesture)
    }
    
    @objc private func doubleTapTableViewCell(by gesture: UIGestureRecognizer) {
        if let cell = gesture.view as? ImageGalleryTableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                doubleTappedIndexPath = indexPath
                cell.textField.isEnabled = true
                cell.textField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - UITextField Delegate
    
    private var doubleTappedIndexPath: IndexPath?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Update model
        if let indexPath = doubleTappedIndexPath {
            galleryList[indexPath.section][indexPath.row].name = textField.text!
            detailVC?.navigationItem.title = galleryList[indexPath.section][indexPath.row].name
        }
        
        // Release text field from first responder
        textField.isEnabled = false
        textField.resignFirstResponder()
        
        return true
    }

}

