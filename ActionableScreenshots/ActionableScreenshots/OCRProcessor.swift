//
//  OCRProcessor.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 10/22/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation
import TesseractOCR

class OCRProcessor {
    // TODO: Avoid attempting to extract-text if the image does not contain text
    func extractText(from image: UIImage) -> String? {
        // TODO: Add image-preprocessing step
        // TODO: Handle additional languages
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            return tesseract.recognizedText
        }
        return nil
    }
}
