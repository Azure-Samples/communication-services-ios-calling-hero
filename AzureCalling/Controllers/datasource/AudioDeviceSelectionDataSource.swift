//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class AudioDeviceSelectionDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties

    private var audioDeviceOptions = [BottomDrawerItem]()

    // MARK: Initialization

    override init() {
        super.init()
        createAudioDeviceOptions()
    }

    // MARK: Private Functions

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
