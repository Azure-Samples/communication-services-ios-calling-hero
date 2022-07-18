//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class BusyOverlay: UIView {

    private let activityIndicator = UIActivityIndicatorView(style: .large)

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
        activityIndicator.startAnimating()
        activityIndicator.color = .white

        addSubview(activityIndicator)
        activityIndicator.centerVerticallyInContainer()
        activityIndicator.centerHorizontallyInContainer()

        isUserInteractionEnabled = false
    }
}
