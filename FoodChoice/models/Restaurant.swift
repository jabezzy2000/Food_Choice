struct Restaurant: Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    let randomFood: String
    var imageURL: String
    let placeID: String
    let directionsURL: String

    init(name: String, latitude: Double, longitude: Double, randomFood: String, imageURL: String, placeID: String, directionsURL: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.randomFood = randomFood
        self.imageURL = imageURL
        self.placeID = placeID
        self.directionsURL = directionsURL
        
    }
    
    // Implement the Equatable protocol
    static func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.placeID == rhs.placeID
    }
    
    // Implement the Hashable protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(placeID)
    }
}
