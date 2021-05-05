//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

protocol BottomDrawerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func createBottomDrawer() -> UITableView
    func openBottomDrawer(table: UITableView)
}

extension BottomDrawerViewController {
    func createBottomDrawer() -> UITableView {
        let table = UITableView()
        table.layer.cornerRadius = 8
        table.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(table)
        let participantCell = UINib(nibName: "BottomDrawerCellView",
                                      bundle: nil)
        table.register(participantCell, forCellReuseIdentifier: "BottomDrawerCellView")
        table.dataSource = self
        table.delegate = self
        table.reloadData()

        let window = UIApplication.shared.windows[0]
        let guide = self.view.safeAreaLayoutGuide
        let bottomPadding = window.safeAreaInsets.bottom
        let midScreenHeight = window.screen.bounds.height / 2

        table.isScrollEnabled = table.contentSize.height > midScreenHeight

        var tableConstraints = [
            table.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            table.heightAnchor.constraint(equalToConstant: min(table.contentSize.height, midScreenHeight) + bottomPadding)
        ]

        let hideConstraint = table.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        hideConstraint.priority = .defaultLow
        tableConstraints.append(hideConstraint)

        NSLayoutConstraint.activate(tableConstraints)

        return table
    }

    func openBottomDrawer(table: UITableView) {
        let showConstraint = NSLayoutConstraint(item: table,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
        showConstraint.priority = .required
        self.view.addConstraint(showConstraint)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
