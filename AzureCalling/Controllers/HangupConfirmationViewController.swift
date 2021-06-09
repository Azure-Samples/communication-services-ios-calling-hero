//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

protocol HangupConfirmationViewControllerDelegate: AnyObject {
    func didConfirmEndCall()
}

class HangupConfirmationViewController: UIViewController {
    weak var delegate: HangupConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false

        let primaryColor = ThemeColor.primary
        let hangupButton = createButton(title: "Leave Call", action: #selector(endCall))
        hangupButton.setTitleColor(UIColor.systemBackground, for: .normal)
        hangupButton.backgroundColor = primaryColor
        view.addSubview(hangupButton)
        hangupButton.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = createButton(title: "Cancel", action: #selector(dismissSelf))
        cancelButton.borderColor = primaryColor
        cancelButton.setTitleColor(primaryColor, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.borderWidth = 1
        view.addSubview(cancelButton)

        let constraints = [
            hangupButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -8),
            hangupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangupButton.widthAnchor.constraint(equalToConstant: 328),
            hangupButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.widthAnchor.constraint(equalTo: hangupButton.widthAnchor),
            cancelButton.heightAnchor.constraint(equalTo: hangupButton.heightAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: hangupButton.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: hangupButton.bottomAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(constraints)

        // tapping anywhere on the view is the same as tapping cancel
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }

    @objc func dismissSelf(sender: NSObject) {
        dismiss(animated: true, completion: nil)
    }

    @objc func endCall() {
        dismiss(animated: true) {
            self.delegate?.didConfirmEndCall()
        }
    }

    private func createButton(title: String, action: Selector) -> UIRoundedButton {
        let button = UIRoundedButton()
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = self.view.tintColor
        button.cornerRadius = 8
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
