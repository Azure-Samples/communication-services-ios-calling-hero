//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class AudioDeviceSelectionViewController: UIViewController, UITableViewDelegate {

    // MARK: Properties

    var audioDeviceSelectionManager: AudioDeviceSelectionManager!
    var audioDeviceTableDataSource: TableViewDataSource!
    var deviceDrawerConstraint: NSLayoutConstraint?

    // MARK: IBOutlets

    @IBOutlet weak var deviceDrawer: UITableView!

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false

        let audioDeviceCell = UINib(nibName: "BottomDrawerCellView",
                                      bundle: nil)
        deviceDrawer.layer.cornerRadius = 8
        deviceDrawer.register(audioDeviceCell, forCellReuseIdentifier: "BottomDrawerCellView")
        deviceDrawer.dataSource = audioDeviceTableDataSource
        deviceDrawer.delegate = self
        audioDeviceTableDataSource?.deselectAllRows()
        let currentAudioDevice = audioDeviceSelectionManager.getCurrentAudioDevice()
        audioDeviceTableDataSource?.selectRow(title: currentAudioDevice.name)
        deviceDrawer.reloadData()
        hideDeviceDrawer()
        showDeviceDrawer()
    }

    // MARK: Private Functions

    private func hideDeviceDrawer() {
        if deviceDrawerConstraint != nil {
            self.view.removeConstraint(deviceDrawerConstraint!)
        }
        let hideConstraint = NSLayoutConstraint(item: deviceDrawer!,
                attribute: .top,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
        self.view.addConstraint(hideConstraint)
        deviceDrawerConstraint = hideConstraint
        self.view.layoutIfNeeded()
    }

    private func showDeviceDrawer() {
        if deviceDrawerConstraint != nil {
            self.view.removeConstraint(deviceDrawerConstraint!)
        }
        let centerYConstraint = NSLayoutConstraint(item: deviceDrawer!,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
        self.view.addConstraint(centerYConstraint)
        deviceDrawerConstraint = centerYConstraint
        UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BottomDrawerCellView
        let audioDeviceDataModel = AudioDeviceDataModel(image: cell.avatar.image!, name: cell.title.text!, enabled: false)
        audioDeviceSelectionManager.switchAudioDevice(audioDeviceDataModel: audioDeviceDataModel)
        dismiss(animated: true, completion: nil)
    }

    // MARK: Actions

    @IBAction func overLayViewDidTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
