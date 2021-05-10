//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureCommunicationCalling

struct ParticipantListInfo {
    let localDisplayName: String
    let localIsMuted: Bool?
    let remoteParticipants: MappedSequence<String, RemoteParticipant>
}

class ParticipantListViewController: NSObject, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties

    private var participantList = [BottomDrawerItem]()

    // MARK: Public API

    func createParticipantList(_ participantListInfo: ParticipantListInfo) {
        // Show local participant first
        let accessoryImage = UIImage(named: "ic_fluent_mic_off_28_filled")!
        let image = UIImage(named: "ic_fluent_person_48_filled")!
        let participantInfo = BottomDrawerItem(avatar: image, title: participantListInfo.localDisplayName + " (Me)", accessoryImage: accessoryImage, enabled: participantListInfo.localIsMuted ?? false)
        participantList.append(participantInfo)

        for remoteParticipant in participantListInfo.remoteParticipants {
            let participantInfo = BottomDrawerItem(avatar: image, title: remoteParticipant.displayName, accessoryImage: accessoryImage, enabled: remoteParticipant.isMuted)
            participantList.append(participantInfo)
        }
    }

    // MARK: UITableViewDataSource events

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomDrawerCellView", for: indexPath) as! BottomDrawerCellView
        let participantInfo = participantList[indexPath.row]
        cell.updateCellView(cellViewModel: participantInfo)

        return cell
    }
}
