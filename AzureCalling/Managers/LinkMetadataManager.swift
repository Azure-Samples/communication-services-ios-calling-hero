//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import LinkPresentation

final class LinkMetadataManager: NSObject, UIActivityItemSource {
    var linkMetadata = LPLinkMetadata()
    var title: String
    var text: String
    var iconImage: UIImage?

    init(title: String, text: String, iconImage: UIImage?) {
        self.title = title
        self.text = text
        self.iconImage = iconImage
        super.init()
    }
}

// MARK: - LinkMetadataManager Setup
extension LinkMetadataManager {
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let linkMetadata = LPLinkMetadata()

        linkMetadata.title = title
        linkMetadata.originalURL = URL(fileURLWithPath: text)
        if let iconImage = iconImage {
            linkMetadata.iconProvider = NSItemProvider(object: iconImage)
        }

        return linkMetadata
    }

      func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
      }

      func activityViewController(_ activityViewController: UIActivityViewController,
                                  itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
      }
}
