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

class AllScreenshotsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: Class variables
    
    private let reuseIdentifier = "Cell"
    var screenshotsAlbum: PHFetchResult<PHAsset> = PHFetchResult()
    var screenshotsCollection = [Screenshot]()
    var filteredScreenshots = [Screenshot]()
    
    var lastProcessed = Date(timeIntervalSince1970: 0)
    var nonProcessedScreenshots: PHFetchResult<PHAsset> = PHFetchResult()
    
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
        initializeScreenshotResults()
        self.tabBarController?.tabBar.layer.shadowOpacity = 0.2
        self.tabBarController?.tabBar.layer.shadowRadius = 5.0
        self.searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // MARK: Photo retrieval
    
    func initializeScreenshotResults() {
        // TODO: Only load screenshots if they haven't been loaded already
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            screenshotsAlbum = getScreenshotsAlbum()
            nonProcessedScreenshots = getNonProcessedScreenshots()
            // processScreenshots()
            break
        case .denied:
            alertRequestAccess()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({(newStatus) -> Void in
                if newStatus == .authorized {
                    self.screenshotsAlbum = self.getScreenshotsAlbum()
                    self.nonProcessedScreenshots = self.getNonProcessedScreenshots()
                }
                else {
                    self.alertRequestAccess()
                }
            })
        default:
            break
        }
        
        if screenshotsAlbum.count > 0 {
            for index in 0...screenshotsAlbum.count - 1 {
                let screenshot = Screenshot(id: String(index))
                screenshot.text = dummyText(index: index)
                screenshot.image = screenshotsAlbum[index]
                screenshotsCollection.append(screenshot)
            }
            processScreenshots()
        }
        filteredScreenshots = screenshotsCollection
        collectionView.reloadData()
        
    }
    
    func alertRequestAccess() {
        let alert = UIAlertController(title: "Error", message: "This app is not authorized to access your photos, please give access to continue.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
            DispatchQueue.main.async {
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    // MARK: Functions for SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // BUG: (Maybe?) Not sure if nil screenshots with no text make this crash
        filteredScreenshots = screenshotsCollection.filter{searchText == "" || $0.text!.contains(searchText)}
        collectionView.reloadData()
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
        return filteredScreenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let screenshot = filteredScreenshots[indexPath.row]
        
        // Configure the cell
        let currentImg = getImage(phAsset: screenshot.image!, width: cellSize.width, height: cellSize.height)
        cell.imgView.image = currentImg
        if indexPath.row < nonProcessedScreenshots.count {
            cell.activityIndicator.startAnimating()
        }
        else {
            cell.activityIndicator.stopAnimating()
        }
        
        
        return cell
    }
    
    func getImage(phAsset: PHAsset, width: CGFloat, height: CGFloat) -> UIImage {
        var img: UIImage!
        PHImageManager.default().requestImage(for: (phAsset), targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            img = image
        }
        
        print(CGSize(width: width, height: height))
        
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
        print("Selected image index: \(selectedImageIndex)")

        for screenshot in screenshotsCollection {
            if screenshot.id == String(selectedImageIndex) {
                destinationView.screenshot = screenshot
            }
        }
        destinationView.screenshotId = idForImage
    }
    
    @IBAction func unwindDetail(segueUnwind: UIStoryboardSegue) {
        
    }
    
    // MARK: Processing
    
    func processScreenshots() {
        // Do whatever to process screenshots
        let ocrProcessor = OCRProcessor()
        let startTime = CFAbsoluteTimeGetCurrent()
        for image in screenshotsCollection {
            if let extractedText = ocrProcessor.extractText(from: image.image) {
                image.text = extractedText
            }
        }
        let ocrElapsed = Double(CFAbsoluteTimeGetCurrent() - startTime)
        print("Tesseract took \(ocrElapsed) seconds to process \(screenshotsCollection.count) screenshots")

        // Reset nonprocessed
        self.lastProcessed = Date()
        UserDefaults.standard.setValue(lastProcessed, forKey: "lastProcessedDate")
        nonProcessedScreenshots = PHFetchResult()
        
        // Reload collectionview
        collectionView.reloadData()
    }
    
    func dummyText(index: Int) -> String {
        if (index == 1) {
            return "Primera"
        } else if (index == 2) {
            return "Segunda"
        } else if (index == 3) {
            return "Tercera"
        } else {
            return "Otras"
        }
    }
    
}

