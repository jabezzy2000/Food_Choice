import UIKit
import ParseSwift


class MainViewController: UIViewController {
    var users: Set<String> = []
    
    @IBOutlet weak var InvitationTextField: UITextField!
    @IBOutlet weak var GroupSize: UILabel!
    var hasDisplayedInvitations: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !hasDisplayedInvitations {
            fetchGroupSessions()
            hasDisplayedInvitations = true
        }
    }

    @IBAction func onAddTapped(_ sender: UIButton) {
        guard let username = InvitationTextField.text,
              !username.isEmpty else { showMissingFieldsAlert(); return }
        if let currentGroupSize = GroupSize.text, let groupSizeInt = Int(currentGroupSize) {
            GroupSize.text = "\(groupSizeInt + 1)"
            users.insert(username)
        } else {
            // Handle the error condition here, such as displaying an error message to the user.
        }
    }

    @IBAction func onInviteTapped(_ sender: UIButton) {
        sendInvitations()
    }
    

    
    private func sendInvitations() {
        let inviter = User.current?.username // Replace with the actual inviter's username or name

        for recipientUsername in users {
            let query = User.query("username" == recipientUsername)
            do {
                let recipient = try query.first()
                let groupSession = GroupSession(recipient: recipient, inviter: inviter ?? "", message: "You've been invited to join a group by \(String(describing: inviter)).")
                do {
                    try groupSession.save()
                    print("Group session saved successfully.")
                } catch {
                    print("Error saving group session: \(error.localizedDescription)")
                }
            } catch {
                print("Error fetching recipient: \(error.localizedDescription)")
            }
        }
    }
    func showInvitationAlert(groupSession: GroupSession) {
        let alertController = UIAlertController(title: "Invitation", message: groupSession.message, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            // Handle the acceptance of the invitation and update the groupSession object accordingly
        }
        
        let declineAction = UIAlertAction(title: "Decline", style: .destructive) { _ in
            // Handle the declination of the invitation and update the groupSession object accordingly
        }
        
        let laterAction = UIAlertAction(title: "Later", style: .cancel)
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
        alertController.addAction(laterAction)
        
        present(alertController, animated: true)
    }

    func fetchGroupSessions() {
        let query = GroupSession.query("recipient" == User.current?.username)
        query.find { result in
            switch result {
            case .success(let groupSessions):
                // Display the group sessions in the app, e.g., in a table view
                print("Found \(groupSessions.count) group sessions.")
                for groupSession in groupSessions {
                    print("Group Session: \(groupSession)")
                    // Call showInvitationAlert() for each invitation
                    self.showInvitationAlert(groupSession: groupSession)
                }
            case .failure(let error):
                print("Error fetching group sessions: \(error.localizedDescription)")
            }
        }
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
