//
//  ResultViewController.swift
//  FoodChoice
//
//  Created by Phinehas Fuachie on 5/3/23.
//

import UIKit
import ParseSwift

class ResultViewController: UIViewController {
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var name1: UILabel!
    
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var name2: UILabel!
    
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var name3: UILabel!
    
    var firstRestaurantLatitude: Double?
    var firstRestaurantLongitude: Double?

     
    @IBAction func endSession(_ sender: UIButton) {
        let dispatchGroup = DispatchGroup()
        
        // Delete all restaurants
        let query = ParseRestaurant.query()
        dispatchGroup.enter()
        query.find { result in
            switch result {
            case .success(let restaurants):
                for restaurant in restaurants {
                    restaurant.delete { result in
                        switch result {
                        case .success:
                            print("Restaurant deleted successfully")
                        case .failure(let error):
                            print("Error deleting restaurant: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching restaurants: \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }
        
        // Delete all group sessions
        let query1 = GroupSession.query()
        dispatchGroup.enter()
        query1.find { result in
            switch result {
            case .success(let groupSessions):
                for groupSession in groupSessions {
                    groupSession.delete { result in
                        switch result {
                        case .success:
                            print("GroupSession deleted successfully")
                        case .failure(let error):
                            print("Error deleting GroupSession: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching GroupSessions: \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // All deletions are complete, perform segue to next screen
            self.performSegue(withIdentifier: "NextScreenSegue", sender: self)
        }
    }

    
    @IBAction func mapsButtonTapped(_ sender: UIButton) {
        if let latitude = firstRestaurantLatitude, let longitude = firstRestaurantLongitude {
                    openDirectionsInSafari(latitude: latitude, longitude: longitude)
                }
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Create a query to fetch the 3 Parse restaurants with the most vote counts
                let query = ParseRestaurant.query()
                query.order(.descending("voteCount"))
                .limit(3).find { result in
                    switch result {
                    case .success(let restaurants):
                        // Update the UI with the resulting restaurants
                        if let firstRestaurant = restaurants.first {
                            self.name1.text = firstRestaurant.name
                            self.firstRestaurantLatitude = firstRestaurant.latitude
                            self.firstRestaurantLongitude = firstRestaurant.longitude
                            if let imageURL = URL(string: firstRestaurant.imageURL!),
                               let imageData = try? Data(contentsOf: imageURL) {
                                self.image1.image = UIImage(data: imageData)
                            }
                        }

                        if restaurants.count >= 2 {
//                            self.name2.text = restaurants[1].name
//                            if let imageURL = URL(string: restaurants[1].imageURL!),
//                               let imageData = try? Data(contentsOf: imageURL) {
//                                self.image2.image = UIImage(data: imageData)
//                            }
                        }

                        if restaurants.count >= 3 {
//                            self.name3.text = restaurants[2].name
//                            if let imageURL = URL(string: restaurants[2].imageURL!),
//                               let imageData = try? Data(contentsOf: imageURL) {
//                                self.image3.image = UIImage(data: imageData)
//                            }
                        }
                    case .failure(let error):
                        print("Error fetching restaurants: \(error.localizedDescription)")
                    }
                }
            }
    
    
    func openDirectionsInSafari(latitude: Double, longitude: Double) {
        let directionsURL = "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)"

        if let url = URL(string: directionsURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
