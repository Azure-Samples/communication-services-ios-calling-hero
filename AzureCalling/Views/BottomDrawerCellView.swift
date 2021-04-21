//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class BottomDrawerCellView: UITableViewCell {

    // MARK: IBOutlets

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public func updateCellView(cellViewModel: BottomDrawerCellViewModel) {
        self.title.text = cellViewModel.title
        self.avatar.image = cellViewModel.avatar
        if cellViewModel.enabled {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
