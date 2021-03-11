//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class AttributedStringFactory {
    static func customizedString(title: String,
                                 body: String,
                                 linkDisplay: String,
                                 link: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
        attrString.append(NSMutableAttributedString(string: body))
        attrString.append(NSMutableAttributedString(string: linkDisplay, attributes: [NSAttributedString.Key.link: URL(string: link)!]))
        return attrString
    }
}
