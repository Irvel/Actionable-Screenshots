//
//  CategoriesTableViewController.swift
//  ActionableScreenshots
//
//  Created by Jorge Gil Cavazos on 11/15/17.
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

class CategoriesTableViewController: UITableViewController {
    
    var tags: Results<Tag>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        let realm = try! Realm()
        tags = realm.objects(Tag.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategorViewCell

        cell.lbCategory.text = tags![indexPath.row].id

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(150)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? CategorViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
}

extension CategoriesTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cnt = tags![collectionView.tag].screenshots.count
        return tags![collectionView.tag].screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! CategoryCollectionViewCell
        let screenshot = tags![collectionView.tag].screenshots[indexPath.row]
        
        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isSynchronous = true
        fetchOptions.resizeMode = .fast
        let currentImg = screenshot.getImage(width: 100, height: 100, contentMode: .aspectFill, fetchOptions: fetchOptions)
        
        cell.ivCatScreenshot.image = currentImg
        cell.layer.cornerRadius = 3.1
        cell.parentTag = collectionView.tag
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let cell = sender as! CategoryCollectionViewCell
        
        let destinationView = segue.destination as! DetailViewController
        
        destinationView.screenshot = tags![cell.parentTag!].screenshots[0]
    }
}
