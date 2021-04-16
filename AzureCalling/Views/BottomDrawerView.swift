//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

@IBDesignable
class BottomDrawerView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
        self.layer.cornerRadius = cornerRadius
        }
    }

    public func open() {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.isHidden = false
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyleCell", for: indexPath)

        cell.textLabel!.text = "Row \(indexPath.row)"

        return cell
    }

}
