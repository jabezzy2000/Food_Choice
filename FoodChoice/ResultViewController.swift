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
    
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var name2: UILabel!
    
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var name3: UILabel!
    
    @IBAction func endSession(_ sender: UIButton) {
        let query = ParseRestaurant.query()
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
                            if let imageURL = URL(string: firstRestaurant.imageURL!),
                               let imageData = try? Data(contentsOf: imageURL) {
                                self.image1.image = UIImage(data: imageData)
                            }
                        }

                        if restaurants.count >= 2 {
                            self.name2.text = restaurants[1].name
                            if let imageURL = URL(string: restaurants[1].imageURL!),
                               let imageData = try? Data(contentsOf: imageURL) {
                                self.image2.image = UIImage(data: imageData)
                            }
                        }

                        if restaurants.count >= 3 {
                            self.name3.text = restaurants[2].name
                            if let imageURL = URL(string: restaurants[2].imageURL!),
                               let imageData = try? Data(contentsOf: imageURL) {
                                self.image3.image = UIImage(data: imageData)
                            }
                        }
                    case .failure(let error):
                        print("Error fetching restaurants: \(error.localizedDescription)")
                    }
                }
            }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
