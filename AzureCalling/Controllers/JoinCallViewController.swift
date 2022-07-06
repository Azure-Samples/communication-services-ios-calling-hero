//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class JoinCallViewController: UIViewController {

    // MARK: Constants
    private let groupIdPlaceHolder: String = "ex. 4fe34380-81e5-11eb-a16e-6161a3176f61"
    private let teamsLinkPlaceHolder: String = "ex. https://teams.microsoft.com/..."

    // MARK: Properties
    var createCallingContextFunction: (() -> CallingContext)?

    private var joinCallType: JoinCallType = .groupCall

    private var typeTitle: FluentUI.Label!
    private var joinIdTextField: UITextField!
    private var displayNameField: UITextField!
    private var callTypeSelector: FluentUI.SegmentedControl!
    private var actionButton: FluentUI.Button!

    // MARK: UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Join"

        setupUI()

        updateJoinCallButton(forInput: nil)

        // Dismiss keyboard if tapping outside
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    deinit {
        displayNameField?.delegate = nil
        joinIdTextField?.delegate = nil
    }

    // MARK: Private Functions
    private func updateJoinCallButton(forInput string: String?) {

    }

    // MARK: Navigation
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        let joinId = joinIdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        switch joinCallType {
//        case .groupCall:
//            guard UUID(uuidString: joinId) != nil else {
//                promptInvalidJoinIdInput()
//                return false
//            }
//        case .teamsMeeting:
//            guard URL(string: joinId) != nil else {
//                promptInvalidJoinIdInput()
//                return false
//            }
//        }
//        return true
//    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        switch segue.identifier {
//        case "JoinCallToLobby":
//            prepareSetupCall(destination: segue.destination)
//        default:
//            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
//        }
//    }
//
//    private func prepareSetupCall(destination: UIViewController) {
//        guard let lobbyViewController = destination as? LobbyViewController else {
//            fatalError("Unexpected destination: \(destination)")
//        }
//
//        lobbyViewController.callingContext = createCallingContextFunction()
//        lobbyViewController.joinInput = joinIdTextField.text!
//        lobbyViewController.joinCallType = joinCallType
//    }

    private func promptInvalidJoinIdInput() {
        var alertMessgae = ""
        switch joinCallType {
        case .groupCall:
            alertMessgae = "The meeting ID you entered is invalid. Please try again."
        case .teamsMeeting:
            alertMessgae = "The meeting link you entered is invalid. Please try again."
        }
        let alert = UIAlertController(title: "Unable to join", message: alertMessgae, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Actions
    private func handleSegmentChanged(action: UIAction) {
        if let callType = JoinCallType(rawValue: callTypeSelector.selectedSegmentIndex) {

        }

        print(action)
    }

    // Action button
    private func handleAction() {

    }
}

extension JoinCallViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        updateJoinCallButton(forInput: updatedString)
        return true
    }
}

// MARK: - UI Layout
private extension JoinCallViewController {
    func setupUI() {

        callTypeSelector = FluentUI.SegmentedControl(items: [
            SegmentItem(title: "Group call"),
            SegmentItem(title: "Teams meeting")
        ])
        callTypeSelector.backgroundColor = .white
        callTypeSelector.addAction(UIAction(handler: handleSegmentChanged), for: .valueChanged)
        view.addSubview(callTypeSelector)
        callTypeSelector.expandHorizontallyInSuperView()
        callTypeSelector.pinToTop()

        let scroller = UIScrollView()
        let formView = setUpForm()

        actionButton = FluentUI.Button.createWith(
            style: .primaryFilled, title: "Next",
            action: { [weak self] _ in self?.handleAction() }
        )
        view.addSubview(scroller)
        actionButton.pinToBottom()
        actionButton.expandHorizontallyInSuperView(withEqualMargin: 16)
    }

    func setUpForm() -> UIView {
        typeTitle = FluentUI.Label.createWith(style: .footnote,
                                                   colorStyle: .secondary,
                                                   value: "Group Call ID")
        joinIdTextField = UITextField()
        joinIdTextField.delegate = self
        joinIdTextField.attributedPlaceholder = NSAttributedString(
            string: groupIdPlaceHolder,
            attributes: [.foregroundColor: ThemeColor.gray300]
        )

        let paddedTextField = PaddingContainer(
            containing: joinIdTextField,
            padding: UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        )
        paddedTextField.backgroundColor = .white

        displayNameField = UITextField()
        displayNameField.delegate = self
        displayNameField.attributedPlaceholder = NSAttributedString(
            string: "Enter a name",
            attributes: [.foregroundColor: ThemeColor.gray300]
        )

        let paddedNameField = PaddingContainer(
            containing: displayNameField,
            padding: UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        )
        paddedNameField.backgroundColor = .white

        // Add controls to the stack
        let formStack = UIStackView(arrangedSubviews: [
            PaddingContainer(
                containing: typeTitle,
                padding: UIEdgeInsets(top: 24, left: 16, bottom: 8, right: 16)
            ),
            paddedTextField,
            PaddingContainer(
                containing:
                    FluentUI.Label.createWith(
                        style: .caption1,
                        colorStyle: .secondary,
                        value: "Start a call to get a call ID."
                    ),
                padding: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            ),
            PaddingContainer(
                containing: FluentUI.Label.createWith(
                    style: .footnote,
                    colorStyle: .secondary,
                    value: "Your display name"
                ),
                padding: UIEdgeInsets(top: 24, left: 16, bottom: 8, right: 16)
            ),
            paddedNameField,
            PaddingContainer(
                containing:
                    FluentUI.Label.createWith(
                        style: .caption1,
                        colorStyle: .secondary,
                        value: "Name shown the others on the call."
                    ),
                padding: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            )
        ])
        formStack.axis = .vertical
        formStack.backgroundColor = ThemeColor.lightSurfacesSecondary

        return formStack
    }

    func setupNavBar() {
    }
}
