//
//  Screenshot.swift
//  ActionableScreenshots
//
//  Created by Jesus Galvan on 10/14/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation
import RealmSwift

enum TagType: String {
    case detectedApplication
    case detectedObject
    case userInput
}

/**
 Store a semantic classification or Tag
 */
class Tag:Object {
    private var _type: TagType?
    var type: TagType? {
        get {
            if let resolTypeRaw = typeRaw  {
                _type = TagType(rawValue: resolTypeRaw)
                return _type
            }
            return .userInput
        }
        set {
            typeRaw = newValue?.rawValue
            _type = newValue
        }
    }
    
    @objc dynamic var id: String?
    @objc dynamic var typeRaw: String?
    let screenshots = LinkingObjects(fromType: Screenshot.self, property: "tags")

    override static func primaryKey() -> String {
        return "id"
    }
}

