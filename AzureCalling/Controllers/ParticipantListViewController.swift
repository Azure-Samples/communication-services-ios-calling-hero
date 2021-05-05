//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class ParticipantListViewController: UIViewController, BottomDrawerViewController {

    // MARK: Properties

    private var participantList: [BottomDrawerItem] = [BottomDrawerItem]()
    var participantTable: UITableView!
    var callingContext: CallingContext!

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

        createParticipantList()
        createParticipantTable()
    }

    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openParticipantTable()
    }

    private func createParticipantTable() {
        participantTable = createBottomDrawer()
        participantTable.allowsSelection = false
    }

    private func openParticipantTable() {
        openBottomDrawer(table: participantTable)
    }

    private func createParticipantList() {
        // Show local participant first
        let accessoryImage = UIImage(named: "ic_fluent_mic_off_28_filled")!
        let image = UIImage(named: "ic_fluent_person_48_filled")!
        let participantInfo = BottomDrawerItem(avatar: image, title: callingContext.displayName + " (Me)", accessoryImage: accessoryImage, enabled: callingContext.isMuted ?? false)
        participantList.append(participantInfo)

        for remoteParticipant in callingContext.remoteParticipants {
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
