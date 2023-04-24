//
//  UserViewController.swift
//  FoodChoice
//
//  Created by Jabez Agyemang-Prempeh on 4/24/23.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!

    @IBAction func onLogOutTapped(_ sender: UIBarButtonItem) {
        showConfirmLogoutAlert()
    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

