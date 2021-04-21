//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {

    // MARK: Properties

    private var cellViewModelDataArray: [BottomDrawerCellViewModel]

    // MARK: Initialization

    init(cellViewDataModel: [BottomDrawerCellViewModel]) {
        self.cellViewModelDataArray = cellViewDataModel
    }

    // MARK: Public Functions

    public func selectRow(indexPathRow: Int) {
        cellViewModelDataArray[indexPathRow].enabled = true
    }

    public func selectRow(title: String) {
        if let rowIndex = cellViewModelDataArray.firstIndex(where: {$0.title == title}) {
            cellViewModelDataArray[rowIndex].enabled = true
        }
    }

    public func deselectRow(indexPathRow: Int) {
        cellViewModelDataArray[indexPathRow].enabled = false
    }

    public func deselectAllRows() {
        for index in cellViewModelDataArray.indices {
            cellViewModelDataArray[index].enabled = false
        }
    }

    // MARK: UITableViewDataSource events

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModelDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomDrawerCellView", for: indexPath) as? BottomDrawerCellView
        cell?.updateCellView(cellViewModel: cellViewModelDataArray[indexPath.row])

        return cell ?? UITableViewCell()
    }
}
