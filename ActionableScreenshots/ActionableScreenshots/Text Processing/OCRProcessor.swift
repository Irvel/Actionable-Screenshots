//
//  OCRProcessor.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 10/22/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation
import Photos
import TesseractOCR
import Vision
import CoreML



class OCRProcessor {
    
    private let tesseract: G8Tesseract
    
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: nil)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
    
    init() {
        // TODO: Set the language dynamically based on the system's language
        tesseract = G8Tesseract(language: "eng")!
        tesseract.setVariableValue("0123456789abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ!¡¿?$:;,.()[]*{}-_<>\\/",
                                   forKey: "tessedit_char_whitelist")

    }
    
    func fetchImage (from asset: PHAsset?) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image: UIImage?
        option.isSynchronous = true
        manager.requestImage(for: asset!, targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result
        })
        return image
    }
    
    func fetchSmallImage (from asset: PHAsset?) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image: UIImage?
        option.isSynchronous = true
        manager.requestImage(for: asset!, targetSize: CGSize(width: 224, height: 224), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result
        })
        return image
    }
    
    func detectText (dectect_image:UIImage) -> Bool {
        let handler:VNImageRequestHandler = VNImageRequestHandler.init(cgImage: (dectect_image.cgImage)!)
        var detectedText = false
        
        let request:VNDetectTextRectanglesRequest = VNDetectTextRectanglesRequest.init(completionHandler: { (request, error) in
            if( (error) == nil) {
                if let result = request.results {
                    if result.count > 0 {
                        detectedText = true
                    }
                }
            }
        })
        request.reportCharacterBoxes = true
        try! handler.perform([request])
        
        return detectedText
    }
    
    // TODO: Avoid attempting to extract-text if the image does not contain text
    func extractText(from asset: PHAsset?) -> String? {
        // TODO: Add image-preprocessing step
        // TODO: Handle additional languages
        if let image = fetchImage(from: asset) {
            //let classifier = ImageClassifier()
            // let imageClass = classifier.classify(image: fetchSmallImage(from: asset)!)
            // tesseract.rect
            if detectText(dectect_image: image) {
                print("Characters detected, extracting text from image...")
                tesseract.image = image.g8_blackAndWhite()
                tesseract.recognize()
                G8Tesseract.clearCache()
                return tesseract.recognizedText
            }
        }
        return nil
    }
}
