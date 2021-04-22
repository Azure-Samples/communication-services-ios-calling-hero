//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

@IBDesignable
class ParticipantLabelView: UIStackView {
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var participantMuteIndicator: UIView!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    func updateDisplayName(displayName: String) {
        participantLabel.text = displayName
        participantLabel.isHidden = displayName.isEmpty
    }

    func updateMuteIndicator(isMuted: Bool) {
        participantMuteIndicator.isHidden = !isMuted
    }
}
