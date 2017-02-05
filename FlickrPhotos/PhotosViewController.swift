//
//  PhotosViewController.swift
//  FlickrPhotos
//
//  Created by Seab on 2/2/17.
//  Copyright © 2017 Seab Jackson. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photoDataSource
        
        store.fetchInterestingPhotos { (photosResult) in
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos")
                self.photoDataSource.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            }
            let indexSet = IndexSet(integer: 0)
            self.collectionView.reloadSections(indexSet)
        }
    }
    
}
















































