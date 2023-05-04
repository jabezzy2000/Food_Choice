//
//  RestaurantViewController.swift
//  FoodChoice
//
//  Created by Jabez Agyemang-Prempeh on 02/05/2023.
//

import UIKit
import CoreLocation
import MapKit
import ParseSwift

class RestaurantViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var voteCount: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    
   static var limitedRestaurants: [Restaurant] = []
    var votedRestaurants: [Restaurant: Int] = [:]


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
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=5000&type=restaurant&key=\(APIKey.googlePlaces)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching nearby restaurants: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let results = jsonObject?["results"] as? [[String: Any]] else {
                    return
                }
                
                let restaurants = results.compactMap { result -> Restaurant? in
                    guard let name = result["name"] as? String,
                          let geometry = result["geometry"] as? [String: Any],
                          let location = geometry["location"] as? [String: Any],
                          let latitude = location["lat"] as? Double,
                          let longitude = location["lng"] as? Double,
                          let photos = result["photos"] as? [[String: Any]],
                          let photo = photos.first,
                          let photoReference = photo["photo_reference"] as? String else {
                        return nil
                    }
                    
                    let placeID = result["place_id"] as? String ?? ""
                    let randomFood = self.fetchRandomFood()
                    let photoURLString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(APIKey.googlePlaces)"
                    return Restaurant(name: name, latitude: latitude, longitude: longitude, randomFood: randomFood, imageURL: photoURLString, placeID: placeID)
                }
                
                DispatchQueue.main.async {
                    if let userLocation = self.locationManager.location {
                        let sortedRestaurants = restaurants.sorted {
                            let location1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                            let location2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                            let distance1 = userLocation.distance(from: location1)
                            let distance2 = userLocation.distance(from: location2)
                            return distance1 < distance2
                        }
                        
                        let limitedRestaurants = Array(sortedRestaurants.prefix(5))
                        
                        print("Nearby restaurants (sorted by distance and limited to 5): \(limitedRestaurants)")
                        // Do something with the 'limitedRestaurants' array
                
                                        self.startSwipe(with: limitedRestaurants)
                                    }
                                }
                            } catch {
                                print("Error parsing JSON: \(error.localizedDescription)")
                            }
                        }.resume()
                    }

//    ends here
    func startSwipe(with limitedRestaurants: [Restaurant]) {
        // Create an array to store the limited restaurants with vote count
        var limitedRestaurantsWithVoteCount: [ParseRestaurant] = []
        
        // Loop through each restaurant and create a new ParseRestaurant object with the voteCount field set to 0
        for restaurant in limitedRestaurants {
            var newRestaurant = ParseRestaurant()
            newRestaurant.name = restaurant.name
            newRestaurant.latitude = restaurant.latitude
            newRestaurant.longitude = restaurant.longitude
            newRestaurant.imageURL = restaurant.imageURL
            newRestaurant.voteCount = 0
            newRestaurant.placeID = restaurant.placeID
            limitedRestaurantsWithVoteCount.append(newRestaurant)
        }
        
        // Save each new ParseRestaurant object to the Back4App server using the save method
        for restaurant in limitedRestaurantsWithVoteCount {
            restaurant.save { result in
                switch result {
                case .success:
                    print("Restaurant saved successfully")
                case .failure(let error):
                    print("Error saving restaurant: \(error.localizedDescription)")
                }
            }
        }
        
        // Populate the RestaurantViewController.limitedRestaurants array with the original Restaurant objects
        RestaurantViewController.limitedRestaurants = limitedRestaurants
        
        // Update the UI with a random restaurant
        updateUIWithRandomRestaurant()
    }



    
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
    
  
    
    func updateUIWithRandomRestaurant() {
        if let randomRestaurant = RestaurantViewController.limitedRestaurants.randomElement() {
            restaurantNameLabel.text = randomRestaurant.name
            
            // Calculate the distance between the user's location and the restaurant
            if let userLocation = locationManager.location {
                let restaurantLocation = CLLocation(latitude: randomRestaurant.latitude, longitude: randomRestaurant.longitude)
                let distanceInMeters = userLocation.distance(from: restaurantLocation)
                let distanceInMetersRounded = round(distanceInMeters)
                restaurantDistanceLabel.text = "\(distanceInMetersRounded) meters"
            }
            
            // Load the restaurant image from the URL asynchronously
            let imageURL = URL(string: randomRestaurant.imageURL)
            DispatchQueue.global().async {
                if let url = imageURL,
                   let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.restaurantImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }



    @objc func handleButtonClick(_ sender: UIButton) {
        if Int((voteCount.text ?? ""))! > 0 {
            voteCount.text = String(Int(voteCount.text ?? "")! - 1)
        } else {
            // Do something when the vote count is 0 and voting ends for the user
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
                    self.navigationController?.pushViewController(resultVC, animated: true)
        }
        
        guard let currentRestaurantName = restaurantNameLabel.text,
              let currentRestaurant = RestaurantViewController.limitedRestaurants.first(where: { $0.name == currentRestaurantName })
               else { return }
        
        let query = ParseRestaurant.query("name" == currentRestaurant.name)
        query.first { result in
            switch result {
            case .success(var parseObject):
                if sender == self.yesButton {
                    if let currentVotes = parseObject.voteCount {
                        parseObject.voteCount = currentVotes + 1
                    } else {
                        parseObject.voteCount = 1
                    }

                    // Save the updated vote count to the ParseRestaurant class in Back4App
                    do {
                        try parseObject.save()
                        print("Restaurant saved successfully")
                    } catch {
                        print("Error saving restaurant: \(error.localizedDescription)")
                    }
                }

                if let index = RestaurantViewController.limitedRestaurants.firstIndex(where: { $0.placeID == currentRestaurant.placeID }) {
                    RestaurantViewController.limitedRestaurants.remove(at: index)
                }
                
                self.updateUIWithRandomRestaurant()
            case .failure(let error):
                print("Error fetching restaurant: \(error.localizedDescription)")
                
                // The restaurant was not found, so we need to create a new ParseRestaurant object
                var newRestaurant = ParseRestaurant()
                newRestaurant.name = currentRestaurant.name
                newRestaurant.latitude = currentRestaurant.latitude
                newRestaurant.longitude = currentRestaurant.longitude
                newRestaurant.imageURL = currentRestaurant.imageURL
                newRestaurant.voteCount = 1
                newRestaurant.placeID = currentRestaurant.placeID
                
                newRestaurant.save { result in
                    switch result {
                    case .success:
                        print("Restaurant saved successfully")
                        if let index = RestaurantViewController.limitedRestaurants.firstIndex(where: { $0.placeID == currentRestaurant.placeID }) {
                            RestaurantViewController.limitedRestaurants.remove(at: index)
                        }
                        
                        self.updateUIWithRandomRestaurant()
                    case .failure(let error):
                        print("Error saving restaurant: \(error.localizedDescription)")
                    }
                }
            }
        }
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
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let status = jsonObject?["status"] as? String, status != "OK" {
                    print("Google Places API error: \(status)")
                    if let errorMessage = jsonObject?["error_message"] as? String {
                        print("Error message: \(errorMessage)")
                    }
                }
                
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
   
