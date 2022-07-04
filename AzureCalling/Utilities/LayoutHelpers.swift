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
                               toItem: superview?.safeAreaLayoutGuide, attribute: .bottom,
                               multiplier: 1, constant: -offset)
        ])
    }

    func pinToTop(withMargin offset: CGFloat = 8) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .top,
                               relatedBy: .equal,
                               toItem: superview?.safeAreaLayoutGuide, attribute: .top,
                               multiplier: 1, constant: offset)
        ])
    }

    func pinToLeft(withMargin offset: CGFloat = 8) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .left,
                               relatedBy: .equal,
                               toItem: superview, attribute: .left,
                               multiplier: 1, constant: offset)
        ])
    }

    func pinToRight(withMargin offset: CGFloat = 8) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .right,
                               relatedBy: .equal,
                               toItem: superview, attribute: .right,
                               multiplier: 1, constant: -offset)
        ])
    }

    func centerVerticallyInContainer(offset: CGFloat = 0) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal,
                               toItem: superview, attribute: .centerY,
                               multiplier: 1, constant: offset)
        ])
    }

    func centerHorizontallyInContainer(offset: CGFloat = 0) {
        guard self.superview != nil else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal,
                               toItem: superview?.safeAreaLayoutGuide, attribute: .centerX,
                               multiplier: 1, constant: offset)
        ])
    }

    func fixSizeTo(size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
                               toItem: nil, attribute: .width,
                               multiplier: 1, constant: size.width),
            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .height,
                               multiplier: 1, constant: size.height)
        ])
    }
}
