//
//  RestaurantViewController.swift
//  FoodChoice
//
//  Created by Jabez Agyemang-Prempeh on 02/05/2023.
//

import UIKit
import CoreLocation
import MapKit

import UIKit
import CoreLocation
import MapKit

class RestaurantViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        requestUserLocation()
    }
    
    func fetchRandomFood() -> String {
        let randomFoods = ["Pizza", "Burger", "Sushi", "Pasta", "Tacos"]
        return randomFoods.randomElement()!
    }
    
    func fetchNearbyRestaurants(latitude: Double, longitude: Double) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error fetching nearby restaurants: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("No data received")
                return
            }
            
            let restaurants = response.mapItems.compactMap { item -> Restaurant? in
                guard let name = item.name, let location = item.placemark.location else {
                    return nil
                }
                
                let randomFood = self.fetchRandomFood()
                return Restaurant(name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, randomFood: randomFood)
            }
            
            let limitedRestaurants = Array(restaurants.prefix(20))
            
            print("Nearby restaurants (limited to 20): \(limitedRestaurants)")
            // Do something with the 'limitedRestaurants' array
        }
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
}
