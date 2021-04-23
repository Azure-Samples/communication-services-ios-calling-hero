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

    // MARK: UITableViewCell events

    required init?(coder: NSCoder) {
        super.init(coder: coder)    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: Public Functions

    public func updateCellView(cellViewModel: BottomDrawerCellViewModel) {
        self.title.text = cellViewModel.title
        self.avatar.image = cellViewModel.avatar
        self.accessoryImage.image = cellViewModel.accessoryImage
        self.accessoryImage.isHidden = !cellViewModel.enabled
    }
}
