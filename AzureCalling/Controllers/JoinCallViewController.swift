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
    var displayName: String?

    private var joinCallType: JoinCallType = .groupCall

    private var typeTitle: FluentUI.Label!
    private var joinIdTextField: IconTextField!
    private var displayNameField: IconTextField!
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
        var alertMessage = ""
        switch joinCallType {
        case .groupCall:
            alertMessage = "The meeting ID you entered is invalid. Please try again."
        case .teamsMeeting:
            alertMessage = "The meeting link you entered is invalid. Please try again."
        }
        let alert = UIAlertController(title: "Unable to join", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Actions
    private func handleSegmentChanged(action: UIAction) {
        if let callType = JoinCallType(rawValue: callTypeSelector.selectedSegmentIndex) {
            switch callType {
            case .groupCall:
                typeTitle.text = "Group call"
            case .teamsMeeting:
                typeTitle.text = "Teams meeting"
            }
        }
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

        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            // TODO: add validation here
            if textField == displayNameField {
                displayName = updatedString
            } else {
                // TODO: validate the group/meeting ID
                let isValid = UUID(uuidString: updatedString) != nil

            }
        }
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

        let formView = setUpForm()
        let stackView = UIStackView(
            arrangedSubviews: [
                callTypeSelector,
                formView
            ])
        stackView.axis = .vertical
        stackView.spacing = 8
        view.addSubview(stackView)
        stackView.pinToTop()
        stackView.expandHorizontallyInSuperView()

        let buttonContainer = UIView()
        buttonContainer.backgroundColor = ThemeColor.lightSurfacesSecondary

        actionButton = FluentUI.Button.createWith(
            style: .primaryFilled, title: "Next",
            action: { [weak self] _ in self?.handleAction() }
        )
        buttonContainer.addSubview(actionButton)
        actionButton.flexibleTopPin()
        actionButton.pinToBottom()
        actionButton.expandHorizontallyInSuperView(withEqualMargin: 16)
        view.addSubview(buttonContainer)
        buttonContainer.expandHorizontallyInSuperView()
        buttonContainer.pinToBottom()
        NSLayoutConstraint.activate([
            buttonContainer.topAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }

    func setUpForm() -> UIView {
        typeTitle = FluentUI.Label.createWith(style: .footnote,
                                                   colorStyle: .secondary,
                                                   value: "Group Call ID")
        joinIdTextField = IconTextField()
        joinIdTextField.delegate = self
        joinIdTextField.placeholder = groupIdPlaceHolder
        joinIdTextField.padding = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)

        displayNameField = IconTextField()
        displayNameField.delegate = self
        displayNameField.placeholder = "Enter a name"
        displayNameField.text = displayName
        displayNameField.padding = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)

        // Add controls to the stack
        let formStack = UIStackView(arrangedSubviews: [
            PaddingContainer(
                containing: typeTitle,
                padding: UIEdgeInsets(top: 24, left: 16, bottom: 8, right: 16)
            ),
            joinIdTextField,
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
            displayNameField,
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
