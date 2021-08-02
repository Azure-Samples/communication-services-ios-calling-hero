//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class JoinCallViewController: UIViewController, UITextFieldDelegate {

    // MARK: Constants

    private let groupIdPlaceHolder: String = "ex. 4fe34380-81e5-11eb-a16e-6161a3176f61"

    // MARK: Properties

    var callingContext: CallingContext!

    var meetingLinkFromUniversalLink: String?

    private var joinCallType: JoinCallType = .groupCall

    // MARK: IBOutlets

    @IBOutlet weak var joinCallButton: UIRoundedButton!
    @IBOutlet weak var joinIdTextField: UITextField!

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()

        setupJoinIdTextField()
        updateJoinCallButton(forInput: meetingLinkFromUniversalLink)

        // Dismiss keyboard if tapping outside
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        if meetingLinkFromUniversalLink != nil {
            self.performSegue(withIdentifier: "JoinCallToLobby", sender: self)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        meetingLinkFromUniversalLink = nil
        setupJoinIdTextField()
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        updateJoinCallButton(forInput: updatedString)
        return true
    }

    // MARK: Private Functions

    private func setupJoinIdTextField() {
        joinIdTextField.delegate = self
        let placeHolderColor = ThemeColor.gray300
        joinIdTextField.attributedPlaceholder = NSAttributedString(string: groupIdPlaceHolder,
                                                                   attributes: [.foregroundColor: placeHolderColor])
        joinIdTextField.text = meetingLinkFromUniversalLink ?? ""
    }

    private func updateJoinCallButton(forInput string: String?) {
        let isEmpty = string?.isEmpty ?? true
        joinCallButton.isEnabled = !isEmpty
    }

    // MARK: Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let joinId = joinIdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard UUID(uuidString: joinId) != nil || joinId.starts(with: "https://") else {
            promptInvalidJoinIdInput()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case "JoinCallToLobby":
            prepareSetupCall(destination: segue.destination)
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }

    private func prepareSetupCall(destination: UIViewController) {
        guard let lobbyViewController = destination as? LobbyViewController else {
            fatalError("Unexpected destination: \(destination)")
        }

        lobbyViewController.callingContext = callingContext
        lobbyViewController.joinInput = meetingLinkFromUniversalLink ?? joinIdTextField.text!
        lobbyViewController.joinCallType = joinCallType
    }

      private func promptInvalidJoinIdInput() {
        let alertMessgae = "The meeting ID you entered is invalid. Please try again."
        let alert = UIAlertController(title: "Unable to join", message: alertMessgae, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
