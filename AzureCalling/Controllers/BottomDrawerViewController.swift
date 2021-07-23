//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class BottomDrawerViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: Properties

    private var tableView: UITableView!
    private var bottomDrawerDataSource: BottomDrawerDataSource?
    private var allowRowSelection: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(dataSource: BottomDrawerDataSource, allowsSelection: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        dataSource.setDismissDrawer?(dismissDrawer: dismissSelf)
        self.bottomDrawerDataSource = dataSource
        self.allowRowSelection = allowsSelection
        self.modalPresentationStyle = .overCurrentContext
    }

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalTransitionStyle = .crossDissolve

        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false

        // tapping anywhere on the view is the same as tapping cancel
        let tap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizer))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)

        createBottomDrawer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openBottomDrawer()
    }

    // MARK: UIGestureRecognizerDelegate events

    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let backgroundDidTapped = touch.view == gestureRecognizer.view
        if backgroundDidTapped {
            dismissSelf()
        }
        return backgroundDidTapped
    }

    // MARK: Public Functions

    func refreshBottomDrawer() {
        bottomDrawerDataSource?.refreshDataSource?()
        tableView.reloadData()

        NSLayoutConstraint.deactivate(tableView.constraints)
        setTableConstraints()
    }

    // MARK: Private Functions

    private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    private func createBottomDrawer() {
        tableView = UITableView()
        tableView.allowsSelection = allowRowSelection
        tableView.layer.cornerRadius = 8
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        let cell = UINib(nibName: "BottomDrawerCellView",
                         bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "BottomDrawerCellView")
        tableView.dataSource = self.bottomDrawerDataSource
        tableView.delegate = self.bottomDrawerDataSource
        tableView.reloadData()

        setTableConstraints()
    }

    private func openBottomDrawer() {
        let showConstraint = NSLayoutConstraint(item: tableView!,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.view.safeAreaLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
        showConstraint.priority = .required
        self.view.addConstraint(showConstraint)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func setTableConstraints() {
        let window = UIApplication.shared.windows[0]
        let guide = self.view.safeAreaLayoutGuide
        let midScreenHeight = window.screen.bounds.height / 2

        tableView.isScrollEnabled = tableView.contentSize.height > midScreenHeight

        var tableConstraints = [
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: min(tableView.contentSize.height, midScreenHeight))
        ]

        let hideConstraint = tableView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        hideConstraint.priority = .defaultLow
        tableConstraints.append(hideConstraint)

        NSLayoutConstraint.activate(tableConstraints)
    }
}
