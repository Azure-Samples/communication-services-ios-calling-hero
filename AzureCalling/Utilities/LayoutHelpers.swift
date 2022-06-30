//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

extension UIView {
    func expandHorizontallyInSuperView(withEqualMargin offset: CGFloat = 0) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .leading,
                               relatedBy: .equal,
                               toItem: superview, attribute: .leading,
                               multiplier: 1, constant: offset),
            NSLayoutConstraint(item: self, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: superview, attribute: .trailing,
                               multiplier: 1, constant: -offset)
        ])
    }

    func pinToBottom(withMargin offset: CGFloat = 8) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .bottom,
                               relatedBy: .equal,
                               toItem: superview, attribute: .bottom,
                               multiplier: 1, constant: -offset)
        ])
    }
}
