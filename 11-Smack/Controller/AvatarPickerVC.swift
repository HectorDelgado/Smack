//
//  AvatarPickerVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/8/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class AvatarPickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Variables
    var avatarType = AvatarType.dark
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /**
     Dismisses the current view controller.
     */
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Updates the TableView to display dark or light avatars.
     */
    @IBAction func segmentControlChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            avatarType = AvatarType.dark
        default:
            avatarType = AvatarType.light
        }
        
        collectionView.reloadData()
    }
    
    /**
     Sets the cell in the TableView to be of type AvatarCell.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "avatarCell", for: indexPath) as? AvatarCell {
            cell.configureCell(index: indexPath.item, type: avatarType)
            return cell
        }
        return UICollectionViewCell()
    }
    
    /**
     Sets the number of sections in the Tableview
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     Sets the number of items in the section (hardcoded to 28 because we have exactly 28 avatar images to choose from)
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    /**
     Sets the TableView to display 3 or 4 columns based on the size of the display.
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numOfColumns: CGFloat = 3
        
        // Smallest iPhone
        if UIScreen.main.bounds.width > 320 {
            numOfColumns = 4
        }
        
        let spaceBetweenCells: CGFloat = 10
        let padding: CGFloat = 40
        let cellDimension = (((collectionView.bounds.width - padding) - (numOfColumns - 1) * spaceBetweenCells) / numOfColumns) 
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    /**
     Stores the name of the avatar the user selected and dismisses the current view controller.
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if avatarType == .dark {
            UserDataService.instance.setAvatarName(avatarName: "dark\(indexPath.item)")
        } else {
            UserDataService.instance.setAvatarName(avatarName: "light\(indexPath.item)")
        }

        dismiss(animated: true, completion: nil)
    }
    
    
    

}
