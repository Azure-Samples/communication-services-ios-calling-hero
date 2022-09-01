//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class BusyOverlay: UIView {

    private let activityIndicator = MSFActivityIndicator(size: .large)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    private func layout() {
        self.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .black.withAlphaComponent(0.3)
        activityIndicator.state.color = Colors.gray400
        activityIndicator.state.isAnimating = true

        let containerView = UIView()
        containerView.backgroundColor = Colors.gray800
        containerView.clipsToBounds = false
        containerView.layer.cornerRadius = 4

        containerView.fixHeightTo(height: 100)
        containerView.fixWidthTo(width: 100)
        containerView.addSubview(activityIndicator.view)
        activityIndicator.view.centerVerticallyInContainer()
        activityIndicator.view.centerHorizontallyInContainer()

        addSubview(containerView)
        containerView.centerVerticallyInContainer()
        containerView.centerHorizontallyInContainer()

        isUserInteractionEnabled = false
    }
}

extension BusyOverlay {

    func present(animated: Bool = true) {
        guard superview == nil else {
            setVisible(visible: true, animated: animated)
            return
        }

        let appKeyWindow = UIApplication.shared.connectedScenes
            .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
            .first { $0.isKeyWindow }

        guard let view = appKeyWindow else {
            print("Error: No top level view to present in!")
            return
        }
        presentIn(view: view, animated: animated)
    }

    func presentIn(view: UIView, animated: Bool = true) {
        guard superview == nil else {
            setVisible(visible: true, animated: animated)
            return
        }

        view.addSubview(self)
        expandVerticallyInSuperView()
        expandHorizontallyInSuperView()
        setVisible(visible: true, animated: animated)
    }

    func hide(animated: Bool = true) {
        guard superview != nil else {
            return
        }
        setVisible(visible: false, animated: animated)
    }

    private func setVisible(visible: Bool, animated: Bool) {
        let targetOpacity: Float = visible ? 1.0 : 0.0
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseInOut
            ) { [weak self] in
                self?.layer.opacity = targetOpacity
            } completion: { [weak self] complete in
                if complete && !visible {
                    self?.removeFromSuperview()
                }
            }
        } else {
            layer.opacity = targetOpacity
        }
    }
}
