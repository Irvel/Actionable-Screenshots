//
//  CategoriesTableViewController.swift
//  ActionableScreenshots
//
//  Created by Jorge Gil Cavazos on 11/15/17.
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

class CategoriesTableViewController: UITableViewController {

    var categories = [String]()
    
    var screenshotsAlbum: PHFetchResult<PHAsset> = PHFetchResult()
    var screenshotsCollection = [Screenshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories.append("Perros")
        categories.append("Gato")
        categories.append("Montaña")
        categories.append("Mexico")
        categories.append("Tec")
        categories.append("Facebook")
        categories.append("Noche")
        
        self.tableView.separatorStyle = .none
        
        loadScreenshotAlbum()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategorViewCell

        cell.lbCategory.text = categories[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? CategorViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
}

extension CategoriesTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshotsCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! CategoryCollectionViewCell
        let screenshot = screenshotsCollection[indexPath.row]
        
        let currentImg = getImage(phAsset: screenshot.image!,width: 100, height: 100)
        
        cell.ivCatScreenshot.image = currentImg
        cell.layer.cornerRadius = 3.1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
    
    func loadScreenshotAlbum() {
        screenshotsAlbum = getScreenshotsAlbum()
        
        if screenshotsAlbum.count > 0 {
            for index in 0...screenshotsAlbum.count - 1 {
                let screenshot = Screenshot(id: String(index))
                screenshot.image = screenshotsAlbum[index]
                screenshotsCollection.append(screenshot)
            }
        }
    }
    
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
    
    func getImage(phAsset: PHAsset, width: CGFloat, height: CGFloat) -> UIImage {
        var img: UIImage!
        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isSynchronous = true
        fetchOptions.resizeMode = .fast
        
        PHImageManager.default().requestImage(for: phAsset,
                                              targetSize: CGSize(width: width, height: height),
                                              contentMode: .aspectFill,
                                              options: fetchOptions) {
                                                (image: UIImage?, info: [AnyHashable: Any]?) -> Void in img = image }
        
        return img!
    }
}
