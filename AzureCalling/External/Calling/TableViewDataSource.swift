//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var cellViewDataArray: [CellViewData]

    init(cellViewData: [CellViewData]) {
        self.cellViewDataArray = cellViewData
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellView", for: indexPath) as? CellView
        cell?.updateCellViewData(cellViewData: cellViewDataArray[indexPath.row])

        return cell ?? UITableViewCell()
    }

}
