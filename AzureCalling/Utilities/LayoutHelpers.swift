//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

extension UIView {
    func expandHorizontallyInSuperView(withEqualMargin offset: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: offset),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -offset)
        ])
    }
    func expandVerticallyInSuperView(withEqualMargin offset: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.topAnchor, constant: offset),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -offset)
        ])
    }

    func pinToBottom(withMargin offset: CGFloat = 8) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: -offset)
        ])
    }

    func pinToTop(withMargin offset: CGFloat = 8) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: offset)
        ])
    }

    func pinToLeft(withMargin offset: CGFloat = 8) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: superView.leftAnchor, constant: offset)
        ])
    }

    func pinToRight(withMargin offset: CGFloat = 8) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -offset)
        ])
    }

    func centerVerticallyInContainer(offset: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: offset)
        ])
    }

    func centerHorizontallyInContainer(offset: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: offset)
        ])
    }

    func fixSizeTo(size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
}
