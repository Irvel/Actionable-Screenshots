//
//  Screenshot.swift
//  ActionableScreenshots
//
//  Created by Jesus Galvan on 10/14/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation
import RealmSwift

class Tag:Object {
    @objc dynamic var id: String?
    let screenshots = LinkingObjects(fromType: Screenshot.self, property: "tags")
    
    override static func primaryKey() -> String {
        return "id"
    }
}

