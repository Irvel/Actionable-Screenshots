//
//  ImageClassifier.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 11/9/17.
//

import Foundation
import Photos

class ImageClassifier {
    
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
    
    func classify(image: UIImage) -> String {
        let model = MobileNet()
        let cool_model = NiceModel()
        let pixelBuffer: CVPixelBuffer = toBuffer(from: image)!
        print(image)
        if let prediction = try? model.prediction(image: pixelBuffer) {
            var counter = 0
            print("\n\n")
            for (k,v) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                counter += 1
                if counter >= 10 {
                    break
                }
                print("\(k):\(v)")
            }
        }
        if let prediction = try? cool_model.prediction(image: pixelBuffer) {
            print("\n\n")
            var counter = 0
            for (k,v) in (Array(prediction.classLabelProbs).sorted {$0.1 > $1.1}) {
                counter += 1
                if counter >= 10 {
                    break
                }
                print("\(k):\(v)")
            }
        }
        return "hey"
    }
}
