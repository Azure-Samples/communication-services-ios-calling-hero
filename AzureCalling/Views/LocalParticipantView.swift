//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class LocalParticipantView: ParticipantView {

    // MARK: Properties

    private var detachMode: Bool = false
    private var switchCamera: () -> Void = {}

    // MARK: Actions

    @IBAction func onSwitchCamera(_ sender: UIButton) {
        switchCamera()
    }

    func setOnSwitchCamera(switchCamera: @escaping () -> Void) {
        self.switchCamera = switchCamera
    }

    func updateVideoDisplayed(isDisplayVideo: Bool) {
        guard let view = videoViewContainer else {
            return
        }

        placeholderImage.isHidden = isDisplayVideo
        switchCameraButton.isHidden = !isDisplayVideo
        view.isHidden = !isDisplayVideo
    }

    func updateCameraSwitch(isOneOnOne detachMode: Bool) {
        // Skip update if display mode is the same
        guard self.detachMode != detachMode else {
            return
        }
        self.detachMode = detachMode

        let buttonLength: CGFloat
        let verticalConstraint: NSLayoutConstraint

        if detachMode {
            // Top right (smaller) camera switch for detached local participant view
            buttonLength = 24
            verticalConstraint = switchCameraButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4)
        } else {
            // Middle right camera switch for standard local participant view
            buttonLength = 30
            verticalConstraint = switchCameraButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        }

        switchCameraButton.constraints
            .filter { [.width, .height].contains($0.firstAttribute) }
            .forEach { $0.constant = buttonLength }
        switchCameraButton.updateConstraints()

        containerView.constraints
            .filter {
                switchCameraButton.hash == $0.firstItem?.hash &&
                    [.top, .centerY].contains($0.firstAttribute)
            }
            .forEach { containerView.removeConstraint($0) }
        containerView.addConstraint(verticalConstraint)
    }
}
