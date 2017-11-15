//
//  Screenshot.swift
//  ActionableScreenshots
//
//  Created by Jorge Gil Cavazos on 10/22/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class Screenshot:Object {
    @objc dynamic var id: String?
    @objc dynamic var text: String?
    @objc dynamic var creationDate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var processed: Bool = false
    var hasText: Bool {
        get {
            return text != nil
        }
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    func getImage(width: CGFloat, height: CGFloat, contentMode: PHImageContentMode, fetchOptions: PHImageRequestOptions? = nil) -> UIImage? {
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id!], options: nil).firstObject
        var imageResult: UIImage?
        if let targetAsset = asset {
            // TODO: Display an activity indicator while the high-res image is being loaded and make the request asynchronously
            PHImageManager.default().requestImage(for: targetAsset,
                                                  targetSize: CGSize(width: width, height: height),
                                                  contentMode: contentMode,
                                                  options: fetchOptions) {
                                                    (image: UIImage?, info: [AnyHashable: Any]?) -> Void in imageResult = image }
        }
        return imageResult
    }
}
