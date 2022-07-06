//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import FluentUI

@IBDesignable

open class IconTextField: UITextField {

    open override var placeholder: String? {
        didSet {
            let placeHolderColor = FluentUI.Colors.textSecondary
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                            attributes: [.foregroundColor: placeHolderColor])
        }
    }

    open var image: UIImage? {
        didSet {
            guard image != nil else {
                removeImage()
                return
            }
            setImage()
        }
    }

    open var imageSize: CGSize? {
        didSet {
            guard imageSize != nil else {
                return
            }
            setImage()
        }
    }

    open var leftPadding: CGFloat = 22 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    open var imageViewLeftPadding: CGFloat = 20 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    open var rightPadding: CGFloat = 16 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public init() {
        super.init(frame: .zero)
        initialize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        self.backgroundColor = .white
        self.textColor = FluentUI.Colors.textPrimary
        UITextField.appearance().tintColor = FluentUI.Colors.iconSecondary
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setImage() {
        self.leftViewMode = .always
        let imageRect = CGRect(x: 0, y: 0, width: imageSize?.width ?? 0, height: imageSize?.height ?? 0)
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
        var left = leftPadding
        if image != nil {
            let leftViewOriginX = leftView?.frame.origin.x ?? 0
            let leftViewWidth = leftView?.frame.size.width ?? 0
            left = leftViewOriginX + leftViewWidth + leftPadding
        }
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: rightPadding)
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: getPaddingEdgeInsets())
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: getPaddingEdgeInsets())
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: getPaddingEdgeInsets())
    }

    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftViewWidth = leftView?.frame.size.width ?? 0
        let leftViewHeight = leftView?.frame.size.height ?? 0
        let verticalCenteredInset = (bounds.height - leftViewHeight) / 2
        return CGRect(x: imageViewLeftPadding, y: verticalCenteredInset, width: leftViewWidth, height: leftViewHeight)
    }
}
