//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {
    private var cellViewModelDataArray: [BottomDrawerCellViewModel]

    init(cellViewDataModel: [BottomDrawerCellViewModel]) {
        self.cellViewModelDataArray = cellViewDataModel
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModelDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomDrawerCellView", for: indexPath) as? BottomDrawerCellView
        cell?.updateCellView(cellViewModel: cellViewModelDataArray[indexPath.row])

        return cell ?? UITableViewCell()
    }

    func selectRow(indexPathRow: Int) {
        cellViewModelDataArray[indexPathRow].enabled = true
    }

    func deselectRow(indexPathRow: Int) {
        cellViewModelDataArray[indexPathRow].enabled = false
    }

    func deselectAllRows() {
        for index in cellViewModelDataArray.indices {
            cellViewModelDataArray[index].enabled = false
        }
    }

}
