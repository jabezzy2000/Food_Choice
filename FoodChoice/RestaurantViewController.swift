//
//  RestaurantViewController.swift
//  FoodChoice
//
//  Created by Jabez Agyemang-Prempeh on 02/05/2023.
//

import UIKit
import CoreLocation
import MapKit

class RestaurantViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    var limitedRestaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        
        requestUserLocation()
    }
    
    func fetchRandomFood() -> String {
        let randomFoods = ["Pizza", "Burger", "Sushi", "Pasta", "Tacos"]
        return randomFoods.randomElement()!
    }
    
    func fetchNearbyRestaurants(latitude: Double, longitude: Double) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 16093 * 2, longitudinalMeters: 16093 * 2)
        
        let search = MKLocalSearch(request: request)
        search.start { [self] response, error in
            if let error = error {
                print("Error fetching nearby restaurants: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("No data received")
                return
            }
            
            let group = DispatchGroup()
            
            let restaurants = response.mapItems.compactMap { item -> Restaurant? in
                guard let name = item.name, let location = item.placemark.location, let placeID = item.placemark.name else {
                    return nil
                }
                
                let randomFood = self.fetchRandomFood()
                var restaurant = Restaurant(name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, randomFood: randomFood, imageURL: "", placeID: placeID)

                group.enter()
                fetchPhotoURL(for: placeID) { url in
                    restaurant.imageURL = url ?? ""
                    group.leave()
                }

                return restaurant
            }
            
            group.notify(queue: .main) {
                let limitedRestaurants = Array(restaurants.prefix(20))
                
                print("Nearby restaurants (limited to 20): \(limitedRestaurants)")
                // Do something with the 'limitedRestaurants' array
                self.startSwipe(with: limitedRestaurants)
            }
        }
    }


//    ends here
    
    func requestUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request authorization to access user's location
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating location
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Stop updating location to save battery
            locationManager.stopUpdatingLocation()
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // Call your fetchNearbyRestaurants function
            fetchNearbyRestaurants(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
    
    func startSwipe(with restaurants: [Restaurant]) {
        limitedRestaurants = restaurants
        updateUIWithRandomRestaurant()
    }
    
    func updateUIWithRandomRestaurant() {
        if let randomRestaurant = limitedRestaurants.randomElement(),
           let index = limitedRestaurants.firstIndex(where: { $0.name == randomRestaurant.name }) {
            limitedRestaurants.remove(at: index)
            restaurantNameLabel.text = randomRestaurant.name
            
            // Calculate the distance between the user's location and the restaurant
            if let userLocation = locationManager.location {
                let restaurantLocation = CLLocation(latitude: randomRestaurant.latitude, longitude: randomRestaurant.longitude)
                let distanceInMeters = userLocation.distance(from: restaurantLocation)
                let distanceInMetersRounded = round(distanceInMeters)
                restaurantDistanceLabel.text = "\(distanceInMetersRounded) meters"
            }
            
            // Load the restaurant image from the URL asynchronously
            // Note: You need to add an imageURL property to your Restaurant model
            // and update the fetchNearbyRestaurants function to set the imageURL value
            if let imageURL = URL(string: randomRestaurant.imageURL) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: imageURL) {
                        DispatchQueue.main.async {
                            self.restaurantImageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }

    @objc func handleButtonClick() {
        updateUIWithRandomRestaurant()
    }
    
    func fetchPhotoURL(for placeID: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=photo&key=\(APIKey.googlePlaces)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching photo URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let result = jsonObject?["result"] as? [String: Any],
                      let photos = result["photos"] as? [[String: Any]],
                      let photo = photos.first,
                      let photoReference = photo["photo_reference"] as? String else {
                    completion(nil)
                    return
                }
                
                let photoURLString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(APIKey.googlePlaces)"
                completion(photoURLString)
                
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }

    


}
   
