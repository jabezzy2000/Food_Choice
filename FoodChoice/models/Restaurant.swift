//
//  Restaurant.swift
//  FoodChoice
//
//  Created by Jabez Agyemang-Prempeh on 02/05/2023.
//

import Foundation

struct Restaurant: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let randomFood: String

    enum CodingKeys: String, CodingKey {
        case name
        case geometry
        case location
        case latitude = "lat"
        case longitude = "lng"
    }

    init(name: String, latitude: Double, longitude: Double, randomFood: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.randomFood = randomFood
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)

        let geometry = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .geometry)
        let location = try geometry.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        latitude = try location.decode(Double.self, forKey: .latitude)
        longitude = try location.decode(Double.self, forKey: .longitude)

        let randomFoods = ["Pizza", "Burger", "Sushi", "Pasta", "Tacos"]
        randomFood = randomFoods.randomElement()!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)

        var geometry = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .geometry)
        var location = geometry.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        try location.encode(latitude, forKey: .latitude)
        try location.encode(longitude, forKey: .longitude)
    }
}
