//
//  SecondViewController.swift
//  ActionableScreenshots
//
//  Created by Chuy Galvan on 10/21/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos

// Collection depending on environment
#if (arch(i386) || arch(x86_64)) && os(iOS) // Simulator
    private let collectionTitle = "Camera Roll"
#else   // Device
    private let collectionTitle = "Screenshots"
#endif

class AllScreenshotsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Class variables
    
    private let reuseIdentifier = "Cell"
    var screenshotsAlbum: PHFetchResult<PHAsset>!
    
    var lastProcessed = Date(timeIntervalSince1970: 0)
    var nonProcessedScreenshots: PHFetchResult<PHAsset>!
    
    var cellSize: CGSize!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Class overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let last = UserDefaults.standard.value(forKey: "lastProcessedDate") as? Date
        if last != nil {
            lastProcessed = last!
        }
        
        screenshotsAlbum = getScreenshotsAlbum()
        nonProcessedScreenshots = getNonProcessedScreenshots()
        // processScreenshots()
        
        self.tabBarController?.tabBar.layer.shadowOpacity = 0.2
        self.tabBarController?.tabBar.layer.shadowRadius = 5.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Photo retrieval
    
    func getScreenshotsAlbum() -> PHFetchResult<PHAsset> {
        let smartAlbums:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        var screenshotsAlbum: PHFetchResult<PHAsset>!
        
        smartAlbums.enumerateObjects({(collection, index, object) in
            if collection.localizedTitle == collectionTitle {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                screenshotsAlbum = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            }
        })
        
        return screenshotsAlbum
    }
    
    func getNonProcessedScreenshots() -> PHFetchResult<PHAsset> {
        var notProcessed: PHFetchResult<PHAsset>!
        let smartAlbums:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        smartAlbums.enumerateObjects({(collection, index, object) in
            if collection.localizedTitle == collectionTitle {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "creationDate >= %@", self.lastProcessed as CVarArg)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
                notProcessed = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            }
        })
        
        return notProcessed
    }
    
    // MARK: Functions for CollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Compute the dimension of a cell for an NxN layout with space S between
        // cells.  Take the collection view's width, subtract (N-1)*S points for
        // the spaces between the cells, and then divide by N to find the final
        // dimension for the cell's width and height.
        
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 7
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        cellSize = CGSize(width: dim, height: dim)
        
        return CGSize(width: dim, height: dim)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshotsAlbum.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        // Configure the cell
        let currentImg = getImage(forIndex: indexPath.row, width: cellSize.width, height: cellSize.height)
        cell.imgView.image = currentImg
        if indexPath.row < nonProcessedScreenshots.count {
            cell.activityIndicator.startAnimating()
        }
        else {
            cell.activityIndicator.stopAnimating()
        }
        
        
        return cell
    }
    
    func getImage(forIndex: Int, width: CGFloat, height: CGFloat) -> UIImage {
        var img: UIImage!
        PHImageManager.default().requestImage(for: (screenshotsAlbum?[forIndex])!, targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            img = image
        }
        
        return img!
    }
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let selectedImageIndex = (collectionView.indexPathsForSelectedItems!.first?.row)!
        
        if selectedImageIndex < nonProcessedScreenshots.count {
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let destinationView = segue.destination as! DetailViewController
        let selectedImageIndex = (collectionView.indexPathsForSelectedItems!.first?.row)!
        let idForImage = screenshotsAlbum[selectedImageIndex].localIdentifier
        
        destinationView.idForImage = idForImage
    }
    
    @IBAction func unwindDetail(segueUnwind: UIStoryboardSegue) {
        
    }
    
    // MARK: Processing
    
    func processScreenshots() {
        // Do whatever to process screenshots
        
        // Reset nonprocessed
        self.lastProcessed = Date()
        UserDefaults.standard.setValue(lastProcessed, forKey: "lastProcessedDate")
        nonProcessedScreenshots = PHFetchResult()
        
        // Reload collectionview
        collectionView.reloadData()
    }
    
}

