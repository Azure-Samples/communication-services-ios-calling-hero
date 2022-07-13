//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class PaddingContainer<T: UIView>: UIView {
    unowned var contained: T

    init(containing: T, padding: UIEdgeInsets) {
        contained = containing
        super.init(frame: .zero)
        addSubview(contained)

        contained.pinToTop(withMargin: padding.top)
        contained.pinToBottom(withMargin: padding.bottom)
        contained.pinToLeft(withMargin: padding.left)
        contained.pinToRight(withMargin: padding.right)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
