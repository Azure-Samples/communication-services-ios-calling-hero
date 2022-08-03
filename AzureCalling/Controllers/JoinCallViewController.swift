//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class JoinCallViewController: UIViewController {

    // MARK: Constants
    private let kGroupIdPlaceHolder: String = "Enter call ID"
    private let kTeamsLinkPlaceHolder: String = "Enter invite link"
    private let kMaxDisplayNameSize: Int = 256
    private let kToastTimeout: TimeInterval = 5

    // MARK: Properties
    var callingContext: CallingContext!
    var displayName: String?

    private var joinCallType: JoinCallType = .groupCall

    private var typeTitle: FluentUI.Label!
    private var joinIdTextField: IconTextField!
    private var displayNameField: IconTextField!
    private var callTypeSelector: FluentUI.SegmentedControl!
    private var actionButton: FluentUI.Button!
    private var contentView: UIView!

    // Handle keyboard scrolling the content
    private var bottomConstraint: NSLayoutConstraint!
    private var keyboardObserver: NSObjectProtocol!

    // MARK: UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Join"
        view.backgroundColor = .white

        contentView = setupUI()

        keyboardObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil, queue: .main,
            using: handleKeyboardNotification(notification:)
        )
        // Dismiss keyboard if tapping outside
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    deinit {
        displayNameField?.delegate = nil
        joinIdTextField?.delegate = nil
        NotificationCenter.default.removeObserver(keyboardObserver as Any)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Set up any developer overrides from the AppConfig.xcconfig file
        let appSettings = AppSettings()
        if displayNameField.text?.isEmpty ?? true,
            !appSettings.displayName.isEmpty {
            displayNameField.text = appSettings.displayName
        }
        if let teamsUrl = appSettings.teamsUrl,
            isValidTeamsUrl(url: teamsUrl) {
            callTypeSelector.selectedSegmentIndex = JoinCallType.teamsMeeting.rawValue
            joinIdTextField.text = teamsUrl.absoluteString
        } else if let groupCallUuid = appSettings.groupCallUuid {
            callTypeSelector.selectedSegmentIndex = JoinCallType.groupCall.rawValue
            joinIdTextField.text = groupCallUuid.uuidString
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if joinIdTextField.text?.isEmpty ?? true {
            joinIdTextField.becomeFirstResponder()
        }
    }

    // MARK: Private Functions
    private func handleKeyboardNotification(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let timing = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
              let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let window = view.window else {
            return
        }

        let endRect = frameEnd.cgRectValue
        let options = UIView.AnimationOptions(rawValue: curve.uintValue << 16)
        let duration = timing.doubleValue

        // Get keyboard height.
        let keyboardFrame = view.convert(endRect, from: window)
        let intersection = view.bounds.intersection(keyboardFrame)
        let keyboardHeight = intersection.isNull ? 0 : intersection.size.height

        UIView.animate(withDuration: duration, delay: 0, options: options) { [weak self] in
            if keyboardHeight > 0,
                let bottomInsets = self?.view.safeAreaInsets.bottom,
                bottomInsets > 0 {
                self?.bottomConstraint?.constant = -keyboardHeight + bottomInsets
            } else {
                self?.bottomConstraint?.constant = -keyboardHeight
            }
            self?.view.layoutIfNeeded()
        }
    }

    private func validateMeetingLink() -> Bool {
        guard let fieldValue = joinIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }

        switch joinCallType {
        case .groupCall:
            guard UUID(uuidString: fieldValue) != nil else {
                promptInvalidJoinIdInput(value: fieldValue)
                return false
            }
        case .teamsMeeting:
            guard isValidTeamsUrl(url: URL(string: fieldValue)) else {
                promptInvalidJoinIdInput(value: fieldValue)
                return false
            }
        }
        return true
    }

    private func isValidTeamsUrl(url: URL?) -> Bool {
        guard let url = url,
              url.scheme == "https",
              let host = url.host,
              host.count > 5 else {
            return false

        }
        return true
    }

    private func handleFormState() {
        guard validateMeetingLink() else {
            joinIdTextField.becomeFirstResponder()
            typeTitle.colorStyle = .error
            return
        }
        typeTitle.colorStyle = .secondary

        if !(displayNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false) {
            // Have a valid display name
            navigateToCall()
        } else {
            let notification = FluentUI.NotificationView()
            notification.setup(style: .dangerToast, message: "Display name is missing")
            notification.show(in: contentView)
            notification.hide(after: kToastTimeout, animated: true, completion: nil)
        }
    }

    private func promptInvalidJoinIdInput(value: String) {
        var alertMessage = ""
        switch joinCallType {
        case .groupCall:
            alertMessage = value.isEmpty ? "Group call ID required" : "We can't find that call\nCheck the call ID and try again"
        case .teamsMeeting:
            alertMessage = value.isEmpty ? "Teams link required" : "We can't find that meeting\nCheck the link and try again"
        }
        let notification = FluentUI.NotificationView()
        notification.setup(style: .dangerToast, message: alertMessage)
        notification.show(in: contentView)
        notification.hide(after: kToastTimeout, animated: true, completion: nil)
    }

    // MARK: Navigation
    func navigateToCall() {
        guard let joinId = joinIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        let callConfig = JoinCallConfig(joinId: joinId, displayName: displayName ?? "", callType: joinCallType)
        callingContext.startCallComposite(callConfig)
    }

    // MARK: User interaction handling
    private func handleSegmentChanged(action: UIAction) {
        if let callType = JoinCallType(rawValue: callTypeSelector.selectedSegmentIndex) {
            joinCallType = callType
            switch callType {
            case .groupCall:
                typeTitle.text = "Group call"
                joinIdTextField.placeholder = kGroupIdPlaceHolder
                joinIdTextField.image = nil
            case .teamsMeeting:
                typeTitle.text = "Teams meeting"
                joinIdTextField.placeholder = kTeamsLinkPlaceHolder
                joinIdTextField.image = UIImage(named: "linkIcon")
            }
        }
    }

    // Action button
    private func handleAction() {
        handleFormState()
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

        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string),
           textField == displayNameField {
            // Display name is not allowed to be too long
            if updatedString.lengthOfBytes(using: .utf8) > kMaxDisplayNameSize {
                return false
            }
            displayName = updatedString
        }
        return true
    }
}

// MARK: - UI Layout
private extension JoinCallViewController {
    func setupUI() -> UIView {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false

        // Add type selector
        createCallTypeSelector()

        let stackView = UIStackView(
            arrangedSubviews: [
                callTypeSelector,
                setUpForm()
            ])
        stackView.axis = .vertical
        stackView.spacing = 8
        content.addSubview(stackView)
        stackView.pinToTop()
        stackView.expandHorizontallyInSuperView()

        // Add the next button
        let buttonContainer = createNextButton()
        content.addSubview(buttonContainer)
        buttonContainer.expandHorizontallyInSuperView()
        buttonContainer.pinToBottom(withMargin: 16)
        NSLayoutConstraint.activate([
            buttonContainer.topAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])

        // Add content to a scrollview
        let scroller = content.wrapInScrollview()
        view.addSubview(scroller)
        scroller.translatesAutoresizingMaskIntoConstraints = false

        bottomConstraint = scroller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bottomConstraint,
            scroller.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scroller.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])

        return content
    }

    func createCallTypeSelector() {
        callTypeSelector = FluentUI.SegmentedControl(items: [
            SegmentItem(title: "Group call"),
            SegmentItem(title: "Teams meeting")
        ])
        callTypeSelector.backgroundColor = .white
        callTypeSelector.addAction(UIAction(handler: handleSegmentChanged), for: .valueChanged)
    }

    func createNextButton() -> UIView {
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = ThemeColor.lightSurfacesSecondary

        actionButton = FluentUI.Button.createWith(
            style: .primaryFilled, title: "Next",
            action: { [weak self] _ in self?.handleAction() }
        )
        buttonContainer.addSubview(actionButton)
        actionButton.flexibleTopPin(withMargin: 16)
        actionButton.pinToBottom(withMargin: 0)
        actionButton.expandHorizontallyInSuperView(withEqualMargin: 16)

        return buttonContainer
    }

    func setUpForm() -> UIView {
        typeTitle = FluentUI.Label.createWith(style: .footnote,
                                                   colorStyle: .secondary,
                                                   value: "Group Call ID")
        joinIdTextField = IconTextField()
        joinIdTextField.delegate = self
        joinIdTextField.placeholder = kGroupIdPlaceHolder
        joinIdTextField.padding = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        joinIdTextField.keyboardType = .asciiCapable
        joinIdTextField.autocorrectionType = .no
        joinIdTextField.autocapitalizationType = .none

        displayNameField = IconTextField()
        displayNameField.image = UIImage(named: "avatarIcon")
        displayNameField.delegate = self
        displayNameField.placeholder = "Enter a name"
        displayNameField.text = displayName
        displayNameField.padding = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        displayNameField.keyboardType = .asciiCapable
        displayNameField.autocorrectionType = .no

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
}
