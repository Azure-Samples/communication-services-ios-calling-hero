//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class BottomDrawerCellView: UITableViewCell {

    // MARK: IBOutlets

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var accessoryImage: UIImageView!

    // MARK: Public Functions

    public func updateCellView(cellViewModel: BottomDrawerItem) {
        self.title.text = cellViewModel.title
        self.avatar.image = cellViewModel.avatar
        self.accessoryImage.image = cellViewModel.accessoryImage
        self.accessoryImage.isHidden = !cellViewModel.enabled
    }
}
