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

    func classify(asset: PHAsset) -> [Tag] {
        let objectsModel = MobileNet()
        let appNameModel = bigModel()
        let placesModel = GoogLeNetPlaces()
        let image = fetchSmallImage(from: asset)
        let pixelBuffer: CVPixelBuffer = toBuffer(from: image!)!
        let minProb = 0.55
        var foundTags: [Tag] = []

        if let prediction = try? objectsModel.prediction(image: pixelBuffer) {
            for (label, probability) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= minProb {
                    let newTag = Tag()
                    newTag.type = .detectedObject
                    newTag.id = label
                    foundTags.append(newTag)
                }
            }
        }

        if let prediction = try? appNameModel.prediction(image: pixelBuffer) {
            for (label, probability) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= 0.3{
                    if label != "other" && label != "meme" { // Other is used to capture all apps that we're currently not covering
                        let newTag = Tag()
                        newTag.type = .detectedApplication
                        newTag.id = label
                        foundTags.append(newTag)
                    }
                }
            }
        }
        
        if let prediction = try? placesModel.prediction(sceneImage: pixelBuffer) {
            for (label, probability) in (Array(prediction.sceneLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= minProb {
                    if label != "other" {
                        let newTag = Tag()
                        newTag.type = .detectedObject
                        newTag.id = label
                        foundTags.append(newTag)
                    }
                }
            }
        }
        return foundTags
    }
}
