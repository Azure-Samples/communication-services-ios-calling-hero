//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

struct ParticipantInfo {
    let displayName: String
    let isMuted: Bool
}

class ParticipantListDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties

    private var participantList = [BottomDrawerItem]()

    // MARK: Public API

    func createParticipantList(_ participantInfoList: [ParticipantInfo]) {
        let accessoryImage = UIImage(named: "ic_fluent_mic_off_28_filled")!
        let image = UIImage(named: "ic_fluent_person_48_filled")!

        for participantInfo in participantInfoList {
            let participantInfo = BottomDrawerItem(avatar: image, title: participantInfo.displayName, accessoryImage: accessoryImage, enabled: participantInfo.isMuted)
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
