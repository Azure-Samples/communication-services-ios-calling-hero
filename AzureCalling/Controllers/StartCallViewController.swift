//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI

class StartCallViewController: UIViewController {

    // MARK: Constants
    private let maxDisplayNameSize: Int = 256

    // MARK: Properties
    private var contentView: UIView!
    private var displayNameStackView: UIStackView!
    private var displayNameLabel: FluentUI.Label!
    private var captionLabel: FluentUI.Label!
    private var displayNameTextField: IconTextField!
    private var nextButton: FluentUI.Button!

    // Handle keyboard scrolling the content
    private var bottomConstraint: NSLayoutConstraint!
    private var keyboardObserver: NSObjectProtocol!

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.lightSurfacesPrimary
        title = "Start call"

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayNameTextField.becomeFirstResponder()
    }

    deinit {
        displayNameTextField?.delegate = nil
        NotificationCenter.default.removeObserver(keyboardObserver as Any)
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
            let bottomInset = keyboardHeight > 0 ? keyboardHeight : self?.view.safeAreaInsets.bottom
            self?.bottomConstraint?.constant = -(bottomInset ?? 0)
            self?.view.layoutIfNeeded()
        }
    }

    // MARK: Action Handling
    private func onNextButtonTapped() {
        let inviteVc = UIViewController()
        navigationController?.pushViewController(inviteVc, animated: true)
    }
}

extension StartCallViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            // Display name is not allowed to be too long
            if updatedString.lengthOfBytes(using: .utf8) > maxDisplayNameSize {
                return false
            }
        }
        return true
    }
}

// MARK: - UI Layout
private extension StartCallViewController {
    func setupUI() -> UIView {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false

        setupLabels()
        setupDisplayNameTextField()
        setupNextButton()

        let formStackContainer = setupForm()
        content.addSubview(formStackContainer)
        formStackContainer.expandHorizontallyInSuperView()
        formStackContainer.pinToTop()

        content.addSubview(nextButton)
        nextButton.expandHorizontallyInSuperView(withEqualMargin: 16)
        nextButton.pinToBottom(withMargin: 16)

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

    func setupLabels() {
        displayNameLabel = FluentUI.Label.createWith(style: .footnote,
                                                      colorStyle: .secondary,
                                                      value: "Display name")

        captionLabel = FluentUI.Label.createWith(style: .caption1,
                                                 colorStyle: .secondary,
                                                 value: "Name shown the others on the call.")
    }

    func setupDisplayNameTextField() {
        displayNameTextField = IconTextField()
        displayNameTextField.placeholder = "Enter a name"
        displayNameTextField.image = UIImage(named: "ic_fluent_person_20_regular")
        displayNameTextField.imageSize = CGSize(width: 16, height: 20)
        displayNameTextField.keyboardType = .asciiCapable
        displayNameTextField.autocorrectionType = .no
        displayNameTextField.delegate = self
    }

    func setupNextButton() {
        nextButton = FluentUI.Button.createWith(
            style: .primaryFilled,
            title: "Next",
            action: { [weak self] _ in self?.onNextButtonTapped() }
        )
    }

    func setupForm() -> UIStackView {
        let formStack = UIStackView(arrangedSubviews: [
            PaddingContainer(
                containing: displayNameLabel,
                padding: UIEdgeInsets(top: 24, left: 16, bottom: 8, right: 16)
            ),
            displayNameTextField,
            PaddingContainer(
                containing: captionLabel,
                padding: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            )
        ])
        formStack.axis = .vertical
        return formStack
    }
}
