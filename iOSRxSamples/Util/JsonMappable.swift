//
//  JsonMappable.swift
//  iOSRxSamples
//
//  Created by cano on 2020/01/21.
//  Copyright © 2020 cano. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JsonMappable {

    init?(json: Json)
}

extension JsonMappable {

    init?(anyJson: Any?) {
        guard let anyJ = anyJson as? Json else { return nil }
        self.init(json: anyJ)
    }
}

extension JsonMappable {

    static func mapping(_ json: [Json]) -> [Self] {
        return json.compactMap { Self.init(json: $0) }
    }
}
