//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import LinkPresentation

class GroupIdShareItem: NSObject, UIActivityItemSource {
    private static let shareTitle: String = "Share Group Call ID"

    private var groupId: String

    init(groupId: String) {
        self.groupId = groupId
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return groupId
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = GroupIdShareItem.shareTitle
        return metadata
    }
}
