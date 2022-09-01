//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI

@IBDesignable

final class IconTextField: UITextField {

    override var placeholder: String? {
        didSet {
            let placeHolderColor = FluentUI.Colors.textSecondary
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                            attributes: [.foregroundColor: placeHolderColor, .font: FluentUI.Fonts.body])
        }
    }

    var image: UIImage? {
        didSet {
            guard image != nil else {
                removeImage()
                return
            }
            setImage()
        }
    }

    var imageSize: CGSize? {
        didSet {
            guard imageSize != nil else {
                return
            }
            setImage()
        }
    }

    var padding = UIEdgeInsets(top: 13, left: 22, bottom: 13, right: 16) {
        didSet {
            setNeedsDisplay()
        }
    }

    var imageViewPadding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 16) {
        didSet {
            self.setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: .zero)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        self.backgroundColor = FluentUI.Colors.surfacePrimary
        self.textColor = FluentUI.Colors.textPrimary
        self.font = FluentUI.Fonts.body
        UITextField.appearance().tintColor = FluentUI.Colors.iconSecondary
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setImage() {
        self.leftViewMode = .always
        let imageRect = CGRect(
            x: 0, y: 0,
            width: imageSize?.width ?? image?.size.width ?? 0,
            height: imageSize?.height ?? image?.size.height ?? 0
        )
        let imageView = UIImageView(frame: imageRect)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.tintColor = FluentUI.Colors.iconSecondary
        self.leftView = imageView
    }

    private func removeImage() {
        leftViewMode = .never
        leftView = nil
        self.imageSize = nil
        self.setNeedsDisplay()
    }

    private func getPaddingEdgeInsets() -> UIEdgeInsets {
        var left = padding.left
        if image != nil {
            let leftViewOriginX = leftView?.frame.origin.x ?? 0
            let leftViewWidth = leftView?.frame.size.width ?? 0
            left = leftViewOriginX + leftViewWidth + imageViewPadding.right
        }
        return UIEdgeInsets(top: padding.top,
                            left: left,
                            bottom: padding.bottom,
                            right: padding.right)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: getPaddingEdgeInsets())
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: getPaddingEdgeInsets())
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: getPaddingEdgeInsets())
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftViewWidth = leftView?.frame.size.width ?? 0
        let leftViewHeight = leftView?.frame.size.height ?? 0
        let verticalCenteredInset = (bounds.height - leftViewHeight) / 2
        return CGRect(x: imageViewPadding.left, y: verticalCenteredInset, width: leftViewWidth, height: leftViewHeight)
    }
}
