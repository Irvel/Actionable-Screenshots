//
//  Screenshot.swift
//  ActionableScreenshots
//
//  Created by Jorge Gil Cavazos on 10/22/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos

class Screenshot {
    var id: String
    var text: String?
    var image: PHAsset?
    var hasText: Bool {
        get {
            return text != nil
        }
    }
    
    init(id: String) {
        self.id = id
    }
}
