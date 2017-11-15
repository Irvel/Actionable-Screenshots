//
//  ImageClassifier.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 11/9/17.
//

import Foundation
import Photos

class ImageClassifier {
    
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
    
    func toBuffer(from image: UIImage) -> CVPixelBuffer? {
        let width = 224
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, width, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: width, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: CGFloat(width))
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: width))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func classify(asset: PHAsset) -> [Category] {
        let objectsModel = MobileNet()
        let appNameModel = bigModel()
        let image = fetchSmallImage(from: asset)
        let pixelBuffer: CVPixelBuffer = toBuffer(from: image!)!
        let minProb = 0.8
        var foundCategories: [Category] = []
        
        if let prediction = try? objectsModel.prediction(image: pixelBuffer) {
            for (label, probability) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= minProb {
                    let newCategory = Category()
                    newCategory.type = .object
                    newCategory.label = label
                    foundCategories.append(newCategory)
                }
            }
        }
        
        if let prediction = try? appNameModel.prediction(image: pixelBuffer) {
            for (label, probability) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= minProb {
                    if label != "other" { // Other is used to capture all apps that we're currently not covering
                        let newCategory = Category()
                        newCategory.type = .object
                        newCategory.label = label
                        foundCategories.append(newCategory)
                        
                    }
                }
            }
        }
        return foundCategories
    }
}
