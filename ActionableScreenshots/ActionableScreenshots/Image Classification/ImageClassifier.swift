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
     Fetches an image thumbnail for a given asset as source with the exact specified dimensions
     - Parameters:
        - asset: The storage asset identifier to request the image from
        - width: The target width for the image to obtain
        - height: The target height for the image to obtain
     */
    func fetchImage (from asset: PHAsset?, width: Int, height: Int) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image: UIImage?
        option.isSynchronous = true
        option.resizeMode = .exact
        manager.requestImage(for: asset!, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            image = result
        })
        return image
    }
    
    /**
     Converts a UIImage to a CVPixelBuffer
     - Parameters:
     - image: The image to be converted
     */
    func toPixelBuffer (forImage image:CGImage) -> CVPixelBuffer? {
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)

        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
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
        let image1 = fetchImage(from: asset, width: 260, height: 424)
        let image2 = fetchImage(from: asset, width: 224, height: 224)
        let pixelBuffer1: CVPixelBuffer = toPixelBuffer(forImage: image1!.cgImage!)!
        let pixelBuffer2: CVPixelBuffer = toPixelBuffer(forImage: image2!.cgImage!)!
        let minProb = 0.65
        var foundTags: [Tag] = []

        if let prediction = try? objectsModel.prediction(image: pixelBuffer2) {
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

        if let prediction = try? appNameModel.prediction(image: pixelBuffer1) {
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
