//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class CellView: UITableViewCell {

    // MARK: IBOutlets

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var statusImage: UIImageView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public func updateCellViewData(cellViewData: CellViewData) {
        self.title.text = cellViewData.title
        self.avatar.image = cellViewData.avatar
        self.statusImage.image = cellViewData.statusImage
        self.statusImage.isHidden = !cellViewData.shouldDisplayStatus
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
