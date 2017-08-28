//
//  Restaurant.swift
//  iosMap
//
//  Created by YU Kaiwen on 28/08/2017.
//  Copyright © 2017 YU Kaiwen. All rights reserved.
//

import UIKit

class Restaurant {
    var name: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    
    init?(name: String, address: String?, latitude: Double?, longitude: Double?) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func setName(name: String) {
        self.name = name
    }
}
