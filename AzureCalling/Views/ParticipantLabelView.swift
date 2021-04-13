//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

@IBDesignable
class ParticipantLabelView: UIStackView {
    var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
