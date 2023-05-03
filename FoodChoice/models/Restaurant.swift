struct Restaurant {
    let name: String
    let latitude: Double
    let longitude: Double
    let randomFood: String
    var imageURL: String
    let placeID: String

    init(name: String, latitude: Double, longitude: Double, randomFood: String, imageURL: String, placeID: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.randomFood = randomFood
        self.imageURL = imageURL
        self.placeID = placeID
    }
}
