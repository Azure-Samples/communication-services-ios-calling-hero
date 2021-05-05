//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class AudioDeviceSelectionViewController: UIViewController, BottomDrawerViewController {

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

    private func createDeviceTable() {
        deviceTable = createBottomDrawer()
    }

    private func openDeviceTable() {
        openBottomDrawer(table: deviceTable)
    }

    private func createAudioDeviceOptions() {
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
