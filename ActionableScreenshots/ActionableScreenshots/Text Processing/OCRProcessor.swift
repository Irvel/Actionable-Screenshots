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


/**
 A class that converts image characters into text
 */
class OCRProcessor {
    
    private let tesseract: G8Tesseract
    
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
    
    /**
     Identify whether a an image contains text or not
     - Parameters:
        - image: The image that potentially contains text or not

     - Result
        - True if the image contained text
     */
    func detectText (in image: UIImage) -> Bool {
        let minCharThres = 3
        let handler:VNImageRequestHandler = VNImageRequestHandler.init(cgImage: (image.cgImage)!)
        var detectedText = false
        
        let request:VNDetectTextRectanglesRequest = VNDetectTextRectanglesRequest.init(completionHandler: { (request, error) in
            if( (error) == nil) {
                if let result = request.results {
                    if result.count > minCharThres {
                        detectedText = true
                    }
                }
            }
        })
        request.reportCharacterBoxes = true
        try! handler.perform([request])
        
        return detectedText
    }
    
    /**
     Extract text from an image with Tesseract OCR
     Only extracts characters when it is able to detect text in the image.
     - Parameters:
     - image: The image to extract text from

     - Result
        - The extracted text as a String
     */
    func extractText(from asset: PHAsset?) -> String? {
        // TODO: Add image-preprocessing step
        if let image = fetchImage(from: asset) {
            if detectText(in: image) {
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
