//
//  SecondViewController.swift
//  ActionableScreenshots
//
//  Created by Jesus Galvan on 10/21/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

// Collection depending on environment
#if (arch(i386) || arch(x86_64)) && os(iOS) // Simulator
    private let collectionTitle = "Camera Roll"
#else   // Device
    private let collectionTitle = "Screenshots"
#endif

class AllScreenshotsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UISearchDisplayDelegate, UIWithCollection {
    
    // MARK: Class variables
    
    private let reuseIdentifier = "Cell"
    private let SPACE_BETWEEN_CELLS: CGFloat = 3
    
    var screenshotsCollection: Results<Screenshot>?
    var filteredScreenshotsQuery: Results<Screenshot>?
    var filteredScreenshots: Array<Screenshot>?
    
    var lastProcessed = Date(timeIntervalSince1970: 0)
    
    var cellSize: CGSize!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lbNoPhotos: UILabel!
    
    // MARK: Class overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        self.tabBarController?.tabBar.layer.shadowOpacity = 0.2
        self.tabBarController?.tabBar.layer.shadowRadius = 5.0
        self.searchBar.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = SPACE_BETWEEN_CELLS
        collectionView!.collectionViewLayout = layout
        
        let realm = try! Realm()
        screenshotsCollection = realm.objects(Screenshot.self)
        filteredScreenshotsQuery = screenshotsCollection?.sorted(byKeyPath: "creationDate", ascending: false)
        filteredScreenshots = Array(filteredScreenshotsQuery!)
        lastProcessed = (screenshotsCollection?.filter(NSPredicate(format: "processed = true")).max(ofProperty: "creationDate")) ?? Date(timeIntervalSince1970: 0)
        initializeScreenshotResults()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    // MARK: Photo retrieval
    
    func initializeScreenshotResults() {
        // TODO: Only load screenshots if they haven't been loaded already
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            loadScreenshotAlbum()
            break
        case .denied, .restricted:
            alertRequestAccess()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({(newStatus) -> Void in
                if newStatus == .authorized {
                    self.loadScreenshotAlbum()
                }
                else {
                    self.alertRequestAccess()
                }
            })
        }
    }
    
    func loadScreenshotAlbum() {
        let realm = try! Realm()
        let nonProcessedScreenshots = getNonProcessedScreenshots()
        
        if nonProcessedScreenshots.count > 0 {
            for index in 0...nonProcessedScreenshots.count - 1 {
                let screenshot = Screenshot()
                screenshot.id = nonProcessedScreenshots[index].localIdentifier
                screenshot.creationDate = nonProcessedScreenshots[index].creationDate!
                try! realm.write {
                    realm.add(screenshot, update: true)
                }
            }
            DispatchQueue.global(qos: .userInitiated).async {
                self.processScreenshots(screenshots: nonProcessedScreenshots)
            }
        }
        DispatchQueue.main.async {
            self.filteredScreenshots = Array(self.filteredScreenshotsQuery!)
            self.collectionView.reloadData()
        }
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
                fetchOptions.predicate = NSPredicate(format: "creationDate > %@", self.lastProcessed as CVarArg)
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
                notProcessed = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            }
        })
        
        return notProcessed
    }
    
    // MARK: Functions for SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // BUG: (Maybe?) Not sure if nil screenshots with no text make this crash
        if searchText == "" {
            filteredScreenshotsQuery = screenshotsCollection?.sorted(byKeyPath: "creationDate", ascending: false)
            filteredScreenshots = Array(filteredScreenshotsQuery!)
        }
        else {
            let predicateQuery = NSPredicate(format: "text CONTAINS[cd] %@", searchText)
            let predicateTag = NSPredicate(format: "ANY tags.id CONTAINS[cd] %@", searchText)
            filteredScreenshotsQuery = screenshotsCollection?.filter(predicateQuery)
            let tagScreenshotsQuery = screenshotsCollection?.filter(predicateTag)
            filteredScreenshots = (Array(tagScreenshotsQuery!) + Array(filteredScreenshotsQuery!)).orderedSet
        }
        
        collectionView.reloadData()
    }
    
    // MARK: Functions for CollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Compute the dimension of a cell for an NxN layout with space S between
        // cells.  Take the collection view's width, subtract (N-1)*S points for
        // the spaces between the cells, and then divide by N to find the final
        // dimension for the cell's width and height.
        let cellsAcross: CGFloat = 3
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * SPACE_BETWEEN_CELLS) / cellsAcross
        cellSize = CGSize(width: dim, height: dim)
        
        return CGSize(width: dim, height: dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lbNoPhotos.isHidden = (filteredScreenshots?.count != 0)
        
        return filteredScreenshots!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        let screenshot = filteredScreenshots![indexPath.row]
        
        // Configure the cell
        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isSynchronous = true
        fetchOptions.resizeMode = .fast
        let currentImg = screenshot.getImage(width: cellSize.width, height: cellSize.height, contentMode: .aspectFill, fetchOptions: fetchOptions)
        
        cell.imgView.image = currentImg
        cell.layer.cornerRadius = 3.1
        
        if screenshot.processed {
            cell.activityIndicator.stopAnimating()
        }
        else {
            cell.activityIndicator.startAnimating()
        }
        
        return cell
    }
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let selectedImageIndex = (collectionView.indexPathsForSelectedItems!.first?.row)!
        return filteredScreenshots![selectedImageIndex].processed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let destinationView = segue.destination as! DetailViewController
        let selectedImageIndex = (collectionView.indexPathsForSelectedItems!.first?.row)!
        destinationView.screenshot = filteredScreenshots![selectedImageIndex]
        destinationView.previousView = self
    }
    
    @IBAction func unwindDetail(segueUnwind: UIStoryboardSegue) {
        
    }
    
    // MARK: Processing
    
    func processScreenshots(screenshots: PHFetchResult<PHAsset>) {
        let ocrProcessor = OCRProcessor()
        for index in 0...screenshots.count - 1 {
            print("Extracting text from image...")
            if let extractedText = ocrProcessor.extractText(from: screenshots[index]) {
                let realm = try! Realm()
                let screenshot = realm.object(ofType: Screenshot.self, forPrimaryKey: screenshots[index].localIdentifier) ?? Screenshot()
                try! realm.write() {
                    if screenshot.id == nil {
                        screenshot.id = screenshots[index].localIdentifier
                        realm.add(screenshot, update: true)
                    }
                    screenshot.text = extractedText
                    screenshot.creationDate = screenshots[index].creationDate!
                    screenshot.processed = true
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func reloadCollection() {
        filteredScreenshots = Array(filteredScreenshotsQuery!)
        collectionView.reloadData()
    }
    
}

extension Array where Element: Hashable {
    var orderedSet: Array  {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

