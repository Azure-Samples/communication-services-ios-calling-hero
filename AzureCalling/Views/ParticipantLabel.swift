//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

@IBDesignable
class ParticipantLabel: UILabel {
    var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    @IBInspectable var paddingTop: CGFloat = 0 {
        didSet {
            insets.top = paddingTop
        }
    }

    @IBInspectable var paddingLeft: CGFloat = 0 {
        didSet {
            insets.left = paddingLeft
        }
    }

    @IBInspectable var paddingBottom: CGFloat = 0 {
        didSet {
            insets.bottom = paddingBottom
        }
    }

    @IBInspectable var paddingRight: CGFloat = 0 {
        didSet {
            insets.right = paddingRight
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (insets.left + insets.right)
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

}
