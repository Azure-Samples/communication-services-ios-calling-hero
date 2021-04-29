//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class AudioDeviceSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties

    private var audioDeviceOptions: [BottomDrawerItem] = [BottomDrawerItem]()
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

    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openDeviceTable()
    }

    func createDeviceTable() {
        deviceTable = UITableView()
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

        let window = UIApplication.shared.windows[0]
        let guide = view.safeAreaLayoutGuide
        let bottomPadding = window.safeAreaInsets.bottom

        var deviceTableConstraints = [
            deviceTable.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            deviceTable.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            deviceTable.heightAnchor.constraint(equalToConstant: deviceTable.contentSize.height + bottomPadding)
        ]

        let hideConstraint = deviceTable.topAnchor.constraint(equalTo: view.bottomAnchor)
        hideConstraint.priority = .defaultLow
        deviceTableConstraints.append(hideConstraint)

        NSLayoutConstraint.activate(deviceTableConstraints)
    }

    func openDeviceTable() {
        let showConstraint = NSLayoutConstraint(item: deviceTable!,
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

    func createAudioDeviceOptions() {
        let audioDeviceTypes = AudioSessionManager.getAllAudioDeviceTypes()
        let currentAudioDeviceType = AudioSessionManager.getCurrentAudioDeviceType()

        for audioDeviceType in audioDeviceTypes {

            let accessoryImage = UIImage(named: "ic_fluent_checkmark_20_filled")!

            var image: UIImage
            switch audioDeviceType {
            case .receiver:
                image = UIImage(named: "ic_fluent_speaker_2_28_regular")!
            case .speaker:
                image = UIImage(named: "ic_fluent_speaker_2_28_filled")!
            }

            let audioDeviceOption = BottomDrawerItem(avatar: image, title: audioDeviceType.name, accessoryImage: accessoryImage, enabled: audioDeviceType == currentAudioDeviceType)
            audioDeviceOptions.append(audioDeviceOption)
        }
    }

    // MARK: UITableViewDelegate events

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let audioDeviceType = AudioDeviceType(rawValue: audioDeviceOptions[indexPath.row].title)!
        AudioSessionManager.switchAudioDeviceType(audioDeviceType: audioDeviceType)
        dismissSelf()
    }

    // MARK: UITableViewDataSource events

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioDeviceOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomDrawerCellView", for: indexPath) as! BottomDrawerCellView
        let audioOption = audioDeviceOptions[indexPath.row]
        cell.updateCellView(cellViewModel: audioOption)

        return cell
    }

}
