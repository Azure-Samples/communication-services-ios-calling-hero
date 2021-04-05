//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class MessageBannerStackView: UIStackView {

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var messageBannerView: UIView!
    @IBOutlet weak var safeAreaSpaceView: UIView!

    @IBAction func dismissButtonDidTapped(_ sender: Any) {
        dismiss()
    }

    func showBannerMessage(_ attributedText: NSAttributedString) {
        showNotificationBannerView()
        textField.attributedText = attributedText
    }

    func dismiss() {
        messageBannerView.isHidden = true
        safeAreaSpaceView.backgroundColor = UIColor.clear
    }

    // MARK: Private methods

    private func showNotificationBannerView() {
        messageBannerView.isHidden = false
        safeAreaSpaceView.backgroundColor = UIColor.systemBackground
    }
}
