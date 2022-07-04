//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

extension FluentUI.Button {

    ///
    /// Helper to create Fluent buttons
    ///
    static func createWith(style: ButtonStyle,
                           title: String,
                           action: @escaping UIActionHandler) -> FluentUI.Button {
        let button = FluentUI.Button(style: style)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction(handler: action), for: .touchUpInside)

        return button
    }
}
