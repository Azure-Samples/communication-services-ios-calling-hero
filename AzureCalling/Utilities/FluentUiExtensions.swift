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

extension FluentUI.Label {

    static func createWith(style: TextStyle,
                           colorStyle: TextColorStyle,
                           value: String? = nil) -> FluentUI.Label {
        // Mapping colorStyle to a set color to disable dark mode support from FluentUI
        var lightModeTextColor: UIColor

        switch colorStyle {
        case .regular:
            lightModeTextColor = ThemeColor.textPrimary
        case .secondary:
            lightModeTextColor = ThemeColor.textSecondary
        case .white:
            lightModeTextColor = .white
        case .primary:
            lightModeTextColor = ThemeColor.primary
        case .error:
            lightModeTextColor = ThemeColor.error
        case .warning:
            lightModeTextColor = ThemeColor.warning
        case .disabled:
            lightModeTextColor = ThemeColor.gray300
        }
        let label = FluentUI.Label(style: style, colorStyle: colorStyle)
        label.text = value
        label.textColor = lightModeTextColor

        return label
    }
}
