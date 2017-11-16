//
//  CategorViewCell.swift
//  ActionableScreenshots
//
//  Created by Jorge Gil Cavazos on 11/15/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit

class CategorViewCell: UITableViewCell {

    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var cvScreenshots: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        cvScreenshots.delegate = dataSourceDelegate
        cvScreenshots.dataSource = dataSourceDelegate
        cvScreenshots.tag = row
        cvScreenshots.reloadData()
    }
}
