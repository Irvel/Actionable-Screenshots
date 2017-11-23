//
//  ImageClassifier.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 11/9/17.
//

import Foundation
import Photos

class ImageClassifier {

    /**
     Fetches a 224 X 224 image thumbnail for a given asset as source
     - Parameters:
        - asset: The storage asset identifier to request the image from
     */
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

    /**
     Converts a UIImage to a CVPixelBuffer
     - Parameters:
        - image: The image to be converted
     */
    func toBuffer(from image: UIImage) -> CVPixelBuffer? {
        let size = 224
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, size, size, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        let context = CGContext(data: pixelData, width: size, height: size, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: CGFloat(size), y: CGFloat(size))
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    /**
     Identifies semantic information from a given image
     It uses 2 classifers.
        - Mobilenet: https://arxiv.org/abs/1704.04861 for general identification of objects inside an image.
        - AppCategorizer: A custom classifier used to identify the name of the application inside a screenshot

     - Parameters:
        - image: The asset for the image to be classified
     - Returns:
        - A list of identified Tags for the input image
     */
    func classify(asset: PHAsset) -> [Tag] {
        let objectsModel = MobileNet()
        let appNameModel = AppCategorizer()
        let image = fetchSmallImage(from: asset)
        let pixelBuffer: CVPixelBuffer = toBuffer(from: image!)!
        let minProb = 0.65
        var foundTags: [Tag] = []

        if let prediction = try? objectsModel.prediction(image: pixelBuffer) {
            for (label, probability) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= minProb && !label.lowercased().contains("web site") {
                    var allLabels = label.components(separatedBy: ", ")
                    let newTag = Tag()
                    newTag.type = .detectedObject
                    newTag.id = allLabels[0]
                    foundTags.append(newTag)
                }
            }
        }

        if let prediction = try? appNameModel.prediction(image: pixelBuffer) {
            print(Array(prediction.classLabelProbs).description)
            for (label, probability) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                if probability >= minProb {
                    if label != "other" { // Other is used to capture all apps that we're currently not covering
                        print(probability)
                        let newTag = Tag()
                        newTag.type = .detectedApplication
                        newTag.id = label
                        foundTags.append(newTag)
                    }
                }
            }
        }
        return foundTags
    }
}
