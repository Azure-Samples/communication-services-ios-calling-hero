//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class InfoHeaderView: UIView {

    private var hideTimer: Timer?

    // MARK: IBOutlets

    @IBOutlet weak var infoLabel: UILabel!

    func updateParticipant(count: Int) {
        infoLabel.text = "Number of Participants: \(count)"
    }

    func toggleDisplay() {
        isHidden ? displayWithTimer() : hide()
    }

    func displayWithTimer() {
        animate(hidden: false)
        resetTimer()
    }

    @objc func hide() {
        animate(hidden: true)
        hideTimer?.invalidate()
    }

    // MARK: Private methods

    private func animate(hidden: Bool) {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.isHidden = hidden
        })
    }

    private func resetTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                     target: self,
                                     selector: #selector(hide),
                                     userInfo: nil, repeats: false)
    }

}
