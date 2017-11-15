//
//  File.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 11/14/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation

class Category : CustomStringConvertible{
    enum categoryType {
        case application
        case object
        case userInput
    }
    
    var label: String?
    var type: categoryType?
    
    var description: String {
        return label ?? ""
    }
}
