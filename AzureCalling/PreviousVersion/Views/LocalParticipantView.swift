//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class LocalParticipantView: ParticipantView {
    let switchCameraButton = UIRoundedButton()

    // MARK: Properties

    private var detachMode: Bool = false
    private var switchCamera: () -> Void = {}

    // MARK: Operation methods

    func setOnSwitchCamera(switchCamera: @escaping () -> Void) {
        self.switchCamera = switchCamera
        configureSwitchCameraButton()
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
            verticalConstraint = switchCameraButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4)
        } else {
            // Middle right camera switch for standard local participant view
            buttonLength = 30
            verticalConstraint = switchCameraButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        }

        switchCameraButton.constraints
            .filter { [.width, .height].contains($0.firstAttribute) }
            .forEach { $0.constant = buttonLength }
        switchCameraButton.updateConstraints()

        self.constraints
            .filter {
                switchCameraButton.hash == $0.firstItem?.hash &&
                    [.top, .centerY].contains($0.firstAttribute)
            }
            .forEach { self.removeConstraint($0) }
        self.addConstraint(verticalConstraint)
    }

    // MARK: Private methods

    @objc private func onSwitchCamera(_ sender: UIButton) {
        switchCamera()
    }

    private func configureSwitchCameraButton() {
        let cameraSwitchImage = UIImage(named: "ic_fluent_camera_switch_24_regular")!
        switchCameraButton.setImage(cameraSwitchImage, for: .normal)
        switchCameraButton.backgroundColor = .black.withAlphaComponent(0.6)
        switchCameraButton.tintColor = .white
        switchCameraButton.isHidden = true
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.addTarget(self, action: #selector(onSwitchCamera(_:)), for: .touchUpInside)
        switchCameraButton.cornerRadius = 4
        addSubview(switchCameraButton)

        let buttonConstraints = [
            switchCameraButton.widthAnchor.constraint(equalToConstant: 30),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 30),
            switchCameraButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.trailingAnchor.constraint(equalTo: switchCameraButton.trailingAnchor, constant: 4)
        ]
        NSLayoutConstraint.activate(buttonConstraints)
    }
}
