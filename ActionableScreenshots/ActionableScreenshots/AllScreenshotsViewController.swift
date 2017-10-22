//
//  SecondViewController.swift
//  ActionableScreenshots
//
//  Created by Chuy Galvan on 10/21/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos

class AllScreenshotsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "Cell"
    var screenshotsAlbum: PHFetchResult<PHAsset>!
    var cellSize: CGSize!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //screenshotsAlbum = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        screenshotsAlbum = getScreenshotsAlbum()
        
        self.tabBarController?.tabBar.layer.shadowOpacity = 0.2
        self.tabBarController?.tabBar.layer.shadowRadius = 5.0
        
        self.navigationController?.hidesBarsOnSwipe = true
        self.tabBarController?.hidesBottomBarWhenPushed = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getScreenshotsAlbum() -> PHFetchResult<PHAsset> {
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        var screenshotsAlbum: PHFetchResult<PHAsset>!
        albumsPhoto.enumerateObjects({(collection, index, object) in
            if collection.localizedTitle == "Camera Roll" { // "Screenshots" {
                screenshotsAlbum = PHAsset.fetchAssets(in: collection, options: nil)
            }
        })
        
        return screenshotsAlbum
    }
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        let currentImg = getImage(forIndex: indexPath.row, width: cellSize.width, height: cellSize.height)
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height))
        
        myImageView.image = currentImg
        
        cell.contentView.addSubview(myImageView)
        
        return cell
    }
    
    func getImage(forIndex: Int, width: CGFloat, height: CGFloat) -> UIImage {
        var img: UIImage!
        PHImageManager.default().requestImage(for: (screenshotsAlbum?[forIndex])!, targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            img = image
        }
        
        return img!
    }
    
    @IBAction func unwindDetail(segueUnwind: UIStoryboardSegue) {
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let destinationView = segue.destination as! DetailViewController
        let selectedImageIndex = (collectionView.indexPathsForSelectedItems!.first?.row)!
        let idForImage = screenshotsAlbum[selectedImageIndex].localIdentifier
        destinationView.idForImage = idForImage
    }
    
}

