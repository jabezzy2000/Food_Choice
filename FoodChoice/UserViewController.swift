//
//  UserViewController.swift
//  FoodChoice
//
//  Created by Jabez Agyemang-Prempeh on 4/24/23.
//

import UIKit
protocol UserViewControllerDelegate: AnyObject {
    func didLogout()
}
class UserViewController: UIViewController {

    weak var delegate: UserViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func onSignOutTapped(_ sender: UIButton) {
//        showConfirmLogoutAlert()
        User.logout { [weak self] result in
                guard let self = self else { return }
                showConfirmLogoutAlert()
                switch result {
                case .success:
                    // Call the delegate method to notify the SceneDelegate that the user has logged out.
                    delegate?.didLogout()
                    
                case .failure(let error):
                    print("❌ Log out error: \(error)")
                }
            }
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

