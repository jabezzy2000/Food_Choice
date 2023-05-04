//
//  Resturants.swift
//  FoodChoice
//
//  Created by Phinehas Fuachie on 5/4/23.
//

import Foundation
import ParseSwift



struct ParseRestaurant: ParseObject {
    var originalData: Data?
    
  
    
    var ACL: ParseSwift.ParseACL?
    
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var name: String?
    var latitude: Double
    var longitude: Double
    var imageURL: String?
    var randomFood: String?
    var placeID: String?
    var voteCount: Int?
    var directionsURL: String?
    
    init(name: String, latitude: Double, longitude: Double, imageURL: String, randomFood: String? = nil, placeID: String? = nil, voteCount: Int? = nil, directionsURL: String? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
        self.randomFood = randomFood
        self.placeID = placeID
        self.voteCount = voteCount
        self.directionsURL = directionsURL
    }
    
    init() {
        self.name = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.imageURL = ""
        self.randomFood = ""
        self.placeID = ""
        self.voteCount = 0
        self.directionsURL = ""
    }
    
    func toRestaurant() -> Restaurant {
        return Restaurant(name: name ?? "",
                          latitude: latitude,
                          longitude: longitude,
                          randomFood: randomFood ?? "",
                          imageURL: imageURL ?? "",
                          placeID: placeID ?? "",
                          directionsURL: directionsURL ?? "")
    }
}



