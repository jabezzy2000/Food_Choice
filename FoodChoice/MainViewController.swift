//
//  MainViewController.swift
//  FoodChoice
//
//  Created by Phinehas Fuachie on 4/22/23.
//

import UIKit


class MainViewController: UIViewController {
    var users: Set<String> = []
    @IBOutlet weak var InvitationTextField: UITextField!
  @IBOutlet weak var GroupSize: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onAddTapped(_ sender: UIButton) {
        guard let username = InvitationTextField.text,
              !username.isEmpty else{showMissingFieldsAlert(); return}
        if let currentGroupSize = GroupSize.text, let groupSizeInt = Int(currentGroupSize) {
            GroupSize.text = "\(groupSizeInt + 1)"
            users.insert(username)
        } else {
            // Handle the error condition here, such as displaying an error message to the user.
            
        }
        
    }
    
    @IBAction func onInviteTapped(_ sender: UIButton) {
    }
    
    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
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
