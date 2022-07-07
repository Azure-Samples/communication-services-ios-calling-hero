//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI

class StartCallViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    private var displayNameStackView: UIStackView!
    private var displayNameLabel: FluentUI.Label!
    private var captionLabel: FluentUI.Label!
    private var displayNameTextField: IconTextField!
    private var nextButton: FluentUI.Button!

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayNameTextField.becomeFirstResponder()
    }

    // MARK: UI layout
    private func setupUI() {
        view.backgroundColor = ThemeColor.lightSurfacesPrimary
        self.navigationItem.title = "Start call"
        setupLabels()
        setupDisplayNameTextField()
        setupNextButton()
        layoutTextFieldContainer()
        layoutMainContainer()
    }

    private func setupLabels() {
        displayNameLabel = FluentUI.Label(style: .footnote)
        displayNameLabel.text = "Display name"
        displayNameLabel.textColor = FluentUI.Colors.textSecondary

        captionLabel = FluentUI.Label(style: .caption1)
        captionLabel.text = "Name shown the others on the call."
        captionLabel.textColor = FluentUI.Colors.textSecondary
    }

    private func setupDisplayNameTextField() {
        displayNameTextField = IconTextField()
        displayNameTextField.placeholder = "Enter a name"
        displayNameTextField.image = UIImage(named: "ic_fluent_person_20_regular")
        displayNameTextField.imageSize = CGSize(width: 16, height: 20)

        displayNameTextField.delegate = self
        // Dismiss keyboard if tapping outside
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupNextButton() {
        nextButton = FluentUI.Button.createWith(
            style: .primaryFilled,
            title: "Next",
            action: { [weak self] _ in self?.onNextButtonTapped() }
        )
    }

    private func layoutTextFieldContainer() {
        let displayNameLabelContainer = containerWithHorizontalEqualMargin(contentView: displayNameLabel)
        displayNameLabel.pinToBottom(withMargin: 4)
        let captionLabelContainer = containerWithHorizontalEqualMargin(contentView: captionLabel)

        displayNameTextField.fixHeightTo(height: 48)

        displayNameStackView = UIStackView(arrangedSubviews: [displayNameLabelContainer, displayNameTextField, captionLabelContainer])

        displayNameStackView.axis = .vertical
        displayNameStackView.alignment = .fill
        displayNameStackView.spacing = 4
        view.addSubview(displayNameStackView)

        displayNameStackView.expandHorizontallyInSuperView(withEqualMargin: 0)
        displayNameStackView.pinToTop()
    }

    private func layoutMainContainer() {
        let buttonContainer = containerWithHorizontalEqualMargin(contentView: nextButton)

        let stackView = UIStackView(arrangedSubviews: [self.displayNameStackView, buttonContainer])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        view.addSubview(stackView)

        stackView.expandHorizontallyInSuperView(withEqualMargin: 0)
        stackView.pinToTop(withMargin: 24)
        stackView.pinToBottom(withMargin: 16)

    }

    private func containerWithHorizontalEqualMargin(contentView: UIView, withEqualMargin: CGFloat = 16) -> UIView {
        let container = UIView()
        container.addSubview(contentView)
        contentView.expandHorizontallyInSuperView(withEqualMargin: withEqualMargin)
        contentView.expandVerticallyInSuperView(withEqualMargin: 0)
        return container
    }

    // MARK: Action Handling
    private func onNextButtonTapped() {
        let inviteVc = UIViewController()
        navigationController?.pushViewController(inviteVc, animated: true)
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 256
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, view.frame.size.height == UIScreen.main.bounds.height {
            view.frame.size.height -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.size.height != UIScreen.main.bounds.height {
            view.frame.size.height = UIScreen.main.bounds.height
        }
    }

}
