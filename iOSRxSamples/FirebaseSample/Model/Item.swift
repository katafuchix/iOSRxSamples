//
//  Item.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/21.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class Item: Mappable  {

    var id: Int         = 0
    var name: String    = ""
    var type: String    = ""
    var date: String    = ""
    var point: Int      = 0
    
    init(json: JSON) {
         self.id                  = json["id"].int ?? 0
         self.name                = json["name"].string ?? ""
         self.type                = json["type"].string ?? ""
         self.date                = json["date"].string ?? ""
         self.point               = json["point"].int ?? 0
    }

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        type        <- map["type"]
        date        <- map["date"]
        point       <- map["point"]
    }
}
