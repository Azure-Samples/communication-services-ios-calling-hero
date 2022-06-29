//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import LinkPresentation

class JoinIdShareItem: NSObject, UIActivityItemSource {

    private var joinId: String
    private var shareTitle: String

    init(joinId: String, shareTitle: String) {
        self.joinId = joinId
        self.shareTitle = shareTitle
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return joinId
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = shareTitle
        return metadata
    }
}
