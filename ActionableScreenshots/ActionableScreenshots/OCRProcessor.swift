//
//  OCRProcessor.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 10/22/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation
import TesseractOCR
import Photos

class OCRProcessor {
    
    func fetchImage (from asset: PHAsset?) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image: UIImage?
        option.isSynchronous = true
        manager.requestImage(for: asset!, targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result
        })
        return image
    }
    
    // TODO: Avoid attempting to extract-text if the image does not contain text
    func extractText(from asset: PHAsset?) -> String? {
        // TODO: Add image-preprocessing step
        // TODO: Handle additional languages
        if let image = fetchImage(from: asset) {
            if let tesseract = G8Tesseract(language: "eng") {
                tesseract.image = image.g8_blackAndWhite()
                tesseract.recognize()
                return tesseract.recognizedText
            }
        }
        return nil
    }
}
