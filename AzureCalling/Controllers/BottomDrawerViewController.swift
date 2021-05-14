//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class BottomDrawerViewController: UIViewController {

    // MARK: Properties

    private var tableView: UITableView!
    private var tableViewDataSource: UITableViewDataSource?
    private weak var tableViewDelegate: UITableViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(dataSource: UITableViewDataSource, delegate: UITableViewDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.tableViewDataSource = dataSource
        self.tableViewDelegate = delegate
        self.modalPresentationStyle = .overCurrentContext
    }

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalTransitionStyle = .crossDissolve

        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false

        // tapping anywhere on the view is the same as tapping cancel
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true

        createBottomDrawer()
    }

    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openBottomDrawer()
    }

    func refreshBottomDrawer(dataSource: UITableViewDataSource) {
        self.tableViewDataSource = dataSource
        tableView.dataSource = self.tableViewDataSource
        tableView.reloadData()

        NSLayoutConstraint.deactivate(tableView.constraints)
        setTableConstraints()
    }

    // MARK: Private Functions

    private func createBottomDrawer() {
        tableView = UITableView()
        tableView.layer.cornerRadius = 8
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        let cell = UINib(nibName: "BottomDrawerCellView",
                         bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "BottomDrawerCellView")
        tableView.dataSource = self.tableViewDataSource
        tableView.delegate = self.tableViewDelegate
        tableView.reloadData()

        setTableConstraints()
    }

    private func openBottomDrawer() {
        let showConstraint = NSLayoutConstraint(item: tableView!,
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

    private func setTableConstraints() {
        let window = UIApplication.shared.windows[0]
        let guide = self.view.safeAreaLayoutGuide
        let bottomPadding = window.safeAreaInsets.bottom
        let midScreenHeight = window.screen.bounds.height / 2

        tableView.isScrollEnabled = tableView.contentSize.height > midScreenHeight

        var tableConstraints = [
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: min(tableView.contentSize.height, midScreenHeight) + bottomPadding)
        ]

        let hideConstraint = tableView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        hideConstraint.priority = .defaultLow
        tableConstraints.append(hideConstraint)

        NSLayoutConstraint.activate(tableConstraints)
    }
}
