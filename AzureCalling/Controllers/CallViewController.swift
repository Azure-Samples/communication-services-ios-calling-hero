//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation
import AzureCommunicationCalling

class CallViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Constants

    let updateDelayInterval: TimeInterval = 2.5

    // MARK: Properties

    var joinCallConfig: JoinCallConfig!
    var callingContext: CallingContext!

    private let eventHandlingQueue = DispatchQueue(label: "eventHandlingQueue", qos: .userInteractive)
    private var lastParticipantViewsUpdateTimestamp: TimeInterval = Date().timeIntervalSince1970
    private var isParticipantViewsUpdatePending: Bool = false
    private var isParticipantViewLayoutInvalidated: Bool = false

    private var localParticipantIndexPath: IndexPath?
    private var localParticipantView = ParticipantView()
    private var participantIdIndexPathMap: [String: IndexPath] = [:]
    private var participantIndexPathViewMap: [IndexPath: ParticipantView] = [:]

    // MARK: IBOutlets

    @IBOutlet weak var localVideoViewContainer: UIRoundedView!
    @IBOutlet weak var participantsView: UICollectionView!
    @IBOutlet weak var toggleVideoButton: UIButton!
    @IBOutlet weak var toggleMuteButton: UIButton!
    @IBOutlet weak var infoHeaderView: InfoHeaderView!
    @IBOutlet weak var bottomControlBar: UIStackView!
    @IBOutlet weak var rightControlBar: UIStackView!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTrailingContraint: NSLayoutConstraint!
    @IBOutlet weak var localVideoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var localVideoViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalToggleVideoButton: UIButton!
    @IBOutlet weak var verticalToggleMuteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()

        participantsView.delegate = self
        participantsView.dataSource = self
        participantsView.contentInsetAdjustmentBehavior = .never

        toggleVideoButton.isSelected = !joinCallConfig.isCameraOn
        toggleMuteButton.isSelected = joinCallConfig.isMicrophoneMuted

        updateToggleVideoButtonState()

        // Join the call asynchronously so that navigation is not blocked
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            self.callingContext.joinCall(self.joinCallConfig) { _ in
                self.onJoinCall()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        UIApplication.shared.isIdleTimerDisabled = false
        forcePortraitOrientation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Avoid infinite loop of collectionView layout
        if isParticipantViewLayoutInvalidated {
            participantsView.collectionViewLayout.invalidateLayout()
            isParticipantViewLayoutInvalidated = false
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        isParticipantViewLayoutInvalidated = true
        if UIDevice.current.orientation.isLandscape {
            setupLandscapeUI()
        } else {
            setupPortraitUI()
        }
    }

    private func setupLandscapeUI() {
        rightControlBar.isHidden = false
        bottomControlBar.isHidden = true
        contentViewBottomConstraint.constant = 0
        contentViewTrailingContraint.constant = rightControlBar.frame.size.width
        localVideoViewWidthConstraint.constant = 110
        localVideoViewHeightConstraint.constant = 85
        verticalToggleMuteButton.isSelected = toggleMuteButton.isSelected
        verticalToggleVideoButton.isSelected = toggleVideoButton.isSelected
    }

    private func setupPortraitUI() {
        rightControlBar.isHidden = true
        bottomControlBar.isHidden = false
        contentViewBottomConstraint.constant = bottomControlBar.frame.size.height
        contentViewTrailingContraint.constant = 0
        localVideoViewWidthConstraint.constant = 75
        localVideoViewHeightConstraint.constant = 100
        toggleMuteButton.isSelected = verticalToggleMuteButton.isSelected
        toggleVideoButton.isSelected = verticalToggleVideoButton.isSelected
    }

    deinit {
        cleanViewRendering()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participantIndexPathViewMap.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantViewCell", for: indexPath)

        if let participantView = participantIndexPathViewMap[indexPath] {
            attach(participantView, to: cell.contentView)
        }

        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isShowGrid = participantIndexPathViewMap.count > 2
        let cellWidth = isShowGrid ? collectionView.bounds.width / 2 : collectionView.bounds.width
        let cellHeight = isShowGrid ? collectionView.bounds.height / 2 : collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: Actions

    @IBAction func onNavBarStop(_ sender: UIBarButtonItem) {
        showConfirmHangupModal()
    }

    private func showConfirmHangupModal() {
        let hangupConfirmationViewController = HangupConfirmationViewController()
        hangupConfirmationViewController.callingContext = callingContext
        hangupConfirmationViewController.modalPresentationStyle = .overCurrentContext
        hangupConfirmationViewController.delegate = self
        hangupConfirmationViewController.modalTransitionStyle = .crossDissolve
        present(hangupConfirmationViewController, animated: true, completion: nil)
    }

    @IBAction func onShare(_ sender: UIButton) {
        let shareTitle = "Share Group Call ID"
        let shareItems = [JoinIdShareItem(joinId: callingContext.joinId, shareTitle: shareTitle)]
        let activityController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)

        // The UIActivityViewController's has non-null popoverPresentationController property when running on iPad
        if let popoverPC = activityController.popoverPresentationController,
           let stackView = sender.superview {
            let convertRect = stackView.convert(sender.frame, to: self.view)
            popoverPC.sourceView = self.view
            popoverPC.sourceRect = convertRect
        }

        self.present(activityController, animated: true, completion: nil)
    }

    @IBAction func onToggleVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            callingContext.stopLocalVideoStream { [weak self] _ in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.localParticipantView.updateVideoDisplayed(isDisplayVideo: false)
                    if self.localParticipantIndexPath == nil {
                        self.localVideoViewContainer.isHidden = true
                    }
                }
            }

        } else {
            callingContext.startLocalVideoStream { [weak self] localVideoStream in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    guard let localVideoStream = localVideoStream else {
                        self.updateToggleVideoButtonState()
                        return
                    }
                    self.localParticipantView.updateVideoStream(localVideoStream: localVideoStream)
                    self.localParticipantView.updateVideoDisplayed(isDisplayVideo: true)
                    if self.localParticipantIndexPath == nil {
                        self.localVideoViewContainer.isHidden = false
                    }
                }
            }
        }
    }

    @IBAction func onToggleMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isSelected ? callingContext.mute(completionHandler: updateMuteIndicator) : callingContext.unmute(completionHandler: updateMuteIndicator)
    }

    private func updateMuteIndicator(_ result: Result<Void, Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                self.localParticipantView.updateMuteIndicator(isMuted: self.callingContext.isMuted)
            case .failure:
                return
            }
        }
    }

    @IBAction func onEndCall(_ sender: UIButton) {
        showConfirmHangupModal()
    }

    @IBAction func contentViewDidTapped(_ sender: UITapGestureRecognizer) {
        infoHeaderView.toggleDisplay()
    }

    private func onJoinCall() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRemoteParticipantsUpdated(_:)), name: .remoteParticipantsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRemoteParticipantIsMutedChanged(_:)), name: .remoteParticipantIsMutedChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appAssignActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

        infoHeaderView.toggleDisplay()
        meetingInfoViewUpdate()
        initParticipantViews()
        activityIndicator.stopAnimating()
    }

    private func updateToggleVideoButtonState() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized,
             .notDetermined:
            toggleVideoButton.isEnabled = true
            verticalToggleVideoButton.isEnabled = true
        case .denied,
             .restricted:
            toggleVideoButton.isEnabled = false
            verticalToggleVideoButton.isEnabled = false
        @unknown default:
            print("Need video permission from user")
        }
    }

    private func endCall() {
        callingContext.endCall { _ in
            print("Call Ended")
        }
    }

    private func cleanViewRendering() {
        localParticipantView.dispose()

        for participantView in participantIndexPathViewMap.values {
            participantView.dispose()
        }
    }

    private func forcePortraitOrientation() {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    private func initParticipantViews() {
        // Remote participants
        for (index, participant) in callingContext.displayedRemoteParticipants.enumerated() {
            let remoteParticipantView = ParticipantView()
            remoteParticipantView.updateDisplayName(displayName: participant.displayName)
            remoteParticipantView.updateMuteIndicator(isMuted: participant.isMuted)

            if let remoteVideoStream = participant.videoStreams.first {
                remoteParticipantView.updateVideoStream(remoteVideoStream: remoteVideoStream)
            }

            let userIdentifier = participant.identifier.stringValue ?? ""
            let indexPath = IndexPath(item: index, section: 0)

            participantIdIndexPathMap[userIdentifier] = indexPath
            participantIndexPathViewMap[indexPath] = remoteParticipantView
        }

        // Local participant
        localParticipantView.updateDisplayName(displayName: callingContext.displayName + " (Me)")
        localParticipantView.updateMuteIndicator(isMuted: callingContext.isMuted)
        localParticipantView.updateVideoDisplayed(isDisplayVideo: callingContext.isCameraPreferredOn)

        if callingContext.isCameraPreferredOn {
            callingContext.withLocalVideoStream { localVideoStream in
                if let localVideoStream = localVideoStream {
                    self.localParticipantView.updateVideoStream(localVideoStream: localVideoStream)
                }
            }
        }

        if participantIndexPathViewMap.count == 1 {
            // Use separate view for local video when only 1 remote participant
            localVideoViewContainer.isHidden = !callingContext.isCameraPreferredOn
            localParticipantView.updateDisplayNameVisible(isDisplayNameVisible: false)
            attach(localParticipantView, to: localVideoViewContainer)
        } else {
            // Display Local video in last position of grid
            let indexPath = IndexPath(item: participantIndexPathViewMap.count, section: 0)
            localParticipantIndexPath = indexPath
            participantIndexPathViewMap[indexPath] = localParticipantView
            localParticipantView.updateDisplayNameVisible(isDisplayNameVisible: true)
            localVideoViewContainer.isHidden = true
        }

        participantsView.reloadData()
    }

    private func queueParticipantViewsUpdate() {
        eventHandlingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            if self.isParticipantViewsUpdatePending {
                return
            }

            self.isParticipantViewsUpdatePending = true

            // Default 0 sec delay for updates
            var delaySecs = 0.0

            // For rapid updates, include delay
            let lastUpdateInterval = Date().timeIntervalSince1970 - self.lastParticipantViewsUpdateTimestamp
            if lastUpdateInterval < self.updateDelayInterval {
                delaySecs = self.updateDelayInterval - lastUpdateInterval
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + delaySecs) {
                self.updateParticipantViews(completionHandler: self.onUpdateParticipantViewsComplete)
            }
        }
    }

    private func onUpdateParticipantViewsComplete() {
        eventHandlingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.lastParticipantViewsUpdateTimestamp = Date().timeIntervalSince1970
            self.isParticipantViewsUpdatePending = false
        }
    }

    private func updateParticipantViews(completionHandler: @escaping () -> Void) {
        // Previous maps tracking participants
        let prevParticipantIdIndexPathMap = participantIdIndexPathMap
        var prevParticipantIndexPathViewMap = participantIndexPathViewMap

        // New maps to track updated list of participants
        participantIdIndexPathMap = [:]
        participantIndexPathViewMap = [:]

        // Collect IndexPath changes for batch update
        var deleteIndexPaths: [IndexPath] = []
        var indexPathMoves: [(at: IndexPath, to: IndexPath)] = []
        var insertIndexPaths: [IndexPath] = []

        // Build new maps and collect changes
        for (index, participant) in callingContext.displayedRemoteParticipants.enumerated() {
            let userIdentifier = participant.identifier.stringValue ?? ""
            let indexPath = IndexPath(item: index, section: 0)
            var participantView: ParticipantView

            // Check for previously tracked participants
            if let prevIndexPath = prevParticipantIdIndexPathMap[userIdentifier],
               let prevParticipantView = prevParticipantIndexPathViewMap[prevIndexPath] {
                prevParticipantIndexPathViewMap.removeValue(forKey: prevIndexPath)

                participantView = prevParticipantView

                if prevIndexPath != indexPath {
                    // Add to move list
                    indexPathMoves.append((at: prevIndexPath, to: indexPath))
                }
            } else {
                participantView = ParticipantView()

                // Add to insert list
                insertIndexPaths.append(indexPath)
            }

            participantView.updateDisplayName(displayName: participant.displayName)
            participantView.updateMuteIndicator(isMuted: participant.isMuted)
            participantView.updateVideoStream(remoteVideoStream: participant.videoStreams.first)

            participantIdIndexPathMap[userIdentifier] = indexPath
            participantIndexPathViewMap[indexPath] = participantView
        }

        // Do not include local participant in cleanup
        if localParticipantIndexPath != nil {
            prevParticipantIndexPathViewMap.removeValue(forKey: localParticipantIndexPath!)
        }

        // Handle local video
        if participantIndexPathViewMap.count == 1 {
            // Remove local participant from grid when only 1 remote participant
            if localParticipantIndexPath != nil {
                deleteIndexPaths.append(localParticipantIndexPath!)
                localParticipantIndexPath = nil
                detach(localParticipantView)
            }

            localVideoViewContainer.isHidden = !callingContext.isCameraPreferredOn
            localParticipantView.updateDisplayNameVisible(isDisplayNameVisible: false)
            attach(localParticipantView, to: localVideoViewContainer)
        } else {
            // Display Local video in last position of grid
            let indexPath = IndexPath(item: participantIndexPathViewMap.count, section: 0)

            if let prevIndexPath = localParticipantIndexPath {
                if prevIndexPath != indexPath {
                    // Move if previously in the grid but wrong position
                    indexPathMoves.append((at: prevIndexPath, to: indexPath))
                }
            } else {
                detach(localParticipantView)

                // Insert new grid item for local video
                insertIndexPaths.append(indexPath)
            }

            localParticipantIndexPath = indexPath
            participantIndexPathViewMap[indexPath] = localParticipantView
            localParticipantView.updateDisplayNameVisible(isDisplayNameVisible: true)
            localVideoViewContainer.isHidden = true
        }

        // Clean up removed participants - previously tracked but no longer tracked
        for (key, value) in prevParticipantIndexPathViewMap {
            value.dispose()
            deleteIndexPaths.append(key)
        }

        // Batch updates on UICollectionView
        UIView.performWithoutAnimation {
            participantsView.performBatchUpdates({
                participantsView.deleteItems(at: deleteIndexPaths)

                for move in indexPathMoves {
                    participantsView.moveItem(at: move.at, to: move.to)
                }

                participantsView.insertItems(at: insertIndexPaths)
            }, completion: {_ in
                completionHandler()
            })
        }
    }

    private func attach(_ participantView: ParticipantView, to containerView: UIView) {
        participantView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(participantView)

        let constraints = [
            participantView.topAnchor.constraint(equalTo: containerView.topAnchor),
            participantView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            participantView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            participantView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func detach(_ participantView: ParticipantView) {
        participantView.removeFromSuperview()
    }

    private func meetingInfoViewUpdate() {
        infoHeaderView.updateParticipant(count: callingContext.participantCount)
    }

    @objc func onRemoteParticipantsUpdated(_ notification: Notification) {
        queueParticipantViewsUpdate()
        meetingInfoViewUpdate()
    }

    @objc func onRemoteParticipantIsMutedChanged(_ notification: Notification) {
        guard let participant = notification.userInfo?["participant"] as? RemoteParticipant else {
            return
        }

        if let userIdentifier = participant.identifier.stringValue,
           let indexPath = participantIdIndexPathMap[userIdentifier],
           let participantView = participantIndexPathViewMap[indexPath] {
            participantView.updateMuteIndicator(isMuted: participant.isMuted)
        }
    }

    @objc func appResignActive(_ notification: Notification) {
        callingContext.pauseLocalVideoStream { _ in }
    }

    @objc func appAssignActive(_ notification: Notification) {
        callingContext.resumeLocalVideoStream { _ in }
    }

    func promptForFeedback() {
        let feedbackViewController = FeedbackViewController()
        feedbackViewController.onDoneBlock = { [weak self] didTapFeedback in
            if !didTapFeedback {
                let sequeId = "UnwindToStart"
                self?.performSegue(withIdentifier: sequeId, sender: nil)
            }
        }
        navigationController?.pushViewController(feedbackViewController, animated: true)
    }
}

extension CallViewController: HangupConfirmationViewControllerDelegate {
    func didConfirmEndCall() {
        endCall()
        promptForFeedback()
        cleanViewRendering()
    }
}
