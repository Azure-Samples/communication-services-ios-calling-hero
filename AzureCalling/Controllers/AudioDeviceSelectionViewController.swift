//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class AudioDeviceSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties

    private var audioDeviceOptions: [AudioDeviceOption] = [AudioDeviceOption]()
    var deviceTable: UITableView!

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

        createAudioDeviceOptions()
        createDeviceTable()
    }

    @objc func dismissSelf(sender: NSObject) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openDeviceTable()
    }

    func createDeviceTable() {
        deviceTable = UITableView()
        deviceTable.isHidden = true
        deviceTable.allowsSelection = true
        deviceTable.isScrollEnabled = false
        deviceTable.layer.cornerRadius = 8
        deviceTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deviceTable)
        let audioDeviceCell = UINib(nibName: "BottomDrawerCellView",
                                      bundle: nil)
        deviceTable.register(audioDeviceCell, forCellReuseIdentifier: "BottomDrawerCellView")
        deviceTable.dataSource = self
        deviceTable.delegate = self
        deviceTable.reloadData()

        var deviceTableConstraints = [
        deviceTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        deviceTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        deviceTable.heightAnchor.constraint(equalToConstant: 100)
        ]

        let hideConstraint = deviceTable.topAnchor.constraint(equalTo: view.bottomAnchor)
        hideConstraint.priority = .defaultLow
        deviceTableConstraints.append(hideConstraint)

        NSLayoutConstraint.activate(deviceTableConstraints)
    }

    func openDeviceTable() {
        deviceTable.isHidden = false

        let centerYConstraint = NSLayoutConstraint(item: deviceTable!,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
        centerYConstraint.priority = .required
        self.view.addConstraint(centerYConstraint)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func createAudioDeviceOptions() {
        let audioDeviceTypes = AudioSessionManager.getAllAudioDeviceTypes()
        let currentAudioDeviceType = AudioSessionManager.getCurrentAudioDeviceType()

        for audioDeviceType in audioDeviceTypes {
            let audioDeviceOption = AudioDeviceOption(image: audioDeviceType.image, name: audioDeviceType.name, accessoryImage: audioDeviceType.accessoryImage, enabled: audioDeviceType == currentAudioDeviceType)
            audioDeviceOptions.append(audioDeviceOption)
        }
    }

    // MARK: UITableViewDelegate events

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BottomDrawerCellView
        let audioDeviceType = AudioDeviceType(rawValue: cell.title.text)!
        AudioSessionManager.switchAudioDeviceType(audioDeviceType: audioDeviceType)
        dismissSelf(sender: self)
    }

    // MARK: UITableViewDataSource events

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioDeviceOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomDrawerCellView", for: indexPath) as? BottomDrawerCellView
        let audioOption = audioDeviceOptions[indexPath.row]
        let bottomDrawerCellViewModel = BottomDrawerCellViewModel(avatar: audioOption.image, title: audioOption.name, accessoryImage: audioOption.accessoryImage, enabled: audioOption.enabled)
        cell?.updateCellView(cellViewModel: bottomDrawerCellViewModel)

        return cell ?? UITableViewCell()
    }

}

struct AudioDeviceOption {
    let image: UIImage
    let name: String
    let accessoryImage: UIImage
    let enabled: Bool
}
