//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling
import AVFoundation

public typealias TokenFetcher = (@escaping (String?, Error?) -> Void) -> Void

class CallingContext: NSObject {
    // MARK: Constants
    private static let remoteParticipantsDisplayed: Int = 5

    // MARK: Properties
    private (set) var joinId: String!
    private (set) var displayName: String!
    private (set) var isCameraPreferredOn: Bool = false
    private (set) var isVideoOnHold: Bool = false
    private (set) var displayedRemoteParticipants: MappedSequence<String, RemoteParticipant> = MappedSequence<String, RemoteParticipant>()
    private (set) var remoteParticipants: MappedSequence<String, RemoteParticipant> = MappedSequence<String, RemoteParticipant>()
    private var localVideoStream: LocalVideoStream?
    private var tokenFetcher: TokenFetcher

    private var isSetup: Bool = false
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var participantsEventsAdapter: ParticipantsEventsAdapter?

    var callType: JoinCallType = .groupCall

    var participantCount: Int {
        let remoteParticipantCount = call?.remoteParticipants.count ?? 0
        return remoteParticipantCount + 1
    }

    // MARK: Initialization

    init(tokenFetcher: @escaping TokenFetcher) {
        self.tokenFetcher = tokenFetcher
    }

    // MARK: Public API

    func setup(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        if isSetup {
            completionHandler(.success(()))
            print("Setup already completed")
            return
        }

        self.setupAudioPermissions { [weak self] in
            guard let self = self else {
                return
            }

            self.setupCalling { result in
                if case .failure(let error) = result {
                    completionHandler(.failure(error))
                    return
                }
                self.setupRemoteParticipantsEventsAdapter()
                self.isSetup = true
                completionHandler(.success(()))
            }
        }
    }

    func joinCall(_ joinConfig: JoinCallConfig, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.setupCallAgent(displayName: joinConfig.displayName) { [weak self] _ in
            guard let self = self else {
                return
            }

            let joinCallOptions = JoinCallOptions()

            if joinConfig.isCameraOn && self.localVideoStream != nil {
                let localVideoStreamArray = [self.localVideoStream!]
                let videoOptions = VideoOptions(localVideoStreams: localVideoStreamArray)
                joinCallOptions.videoOptions = videoOptions
            }

            joinCallOptions.audioOptions = AudioOptions()
            joinCallOptions.audioOptions?.muted = joinConfig.isMicrophoneMuted

            var joinLocator: JoinMeetingLocator!
            let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? UUID().uuidString
            switch joinConfig.callType {
            case .groupCall:
                let groupId = UUID(uuidString: joinIdStr) ?? UUID()
                joinLocator = GroupCallLocator(groupId: groupId)
            }

            self.callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions) { [weak self] (call, error) in
                guard let self = self,
                    let call = call,
                    error == nil else {
                    print("Join call failed")
                    completionHandler(.failure(error!))
                    return
                }

                call.delegate = self
                self.call = call
                self.joinId = joinIdStr
                self.callType = joinConfig.callType
                self.displayName = joinConfig.displayName
                self.isCameraPreferredOn = joinConfig.isCameraOn
                completionHandler(.success(()))
            }
        }
    }

    func endCall(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.call?.hangUp(options: HangUpOptions()) { (error) in
            if error != nil {
                print("ERROR: It was not possible to hangup the call.")
                completionHandler(.failure(error!))
                return
            }
            print("Call ended successfully")
            completionHandler(.success(()))
        }
    }

    func withLocalVideoStream(completionHandler: @escaping (LocalVideoStream?) -> Void) {
        if let localVideoStream = self.localVideoStream {
            completionHandler(localVideoStream)
            return
        }

        let videoPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if videoPermissionStatus == .authorized {
            setupLocalVideoStream(completionHandler: completionHandler)
        } else if videoPermissionStatus == .notDetermined {
            setupVideoPermissions(completionHandler: completionHandler)
        } else {
            completionHandler(nil)
        }
    }

    func startLocalVideoStream(completionHandler: @escaping (LocalVideoStream?) -> Void) {
        isCameraPreferredOn = true
        withLocalVideoStream { [weak self] localVideoStream in
            guard let self = self else {
                return
            }

            guard let localVideoStream = localVideoStream else {
                completionHandler(nil)
                return
            }

            self.call?.startVideo(stream: localVideoStream) { (error) in
                if error != nil {
                    print("ERROR: Local video failed to start. \(error!)")
                    return
                }
                print("Local video started successfully")
            }

            completionHandler(self.localVideoStream)
        }
    }

    func resumeLocalVideoStream(completionHandler: @escaping (LocalVideoStream?) -> Void) {
        if isVideoOnHold {
            startLocalVideoStream { [weak self] localVideoStream in
                guard let self = self else {
                    return
                }

                guard localVideoStream != nil else {
                    completionHandler(nil)
                    return
                }

                self.isVideoOnHold = false
                print("Local video resumed successfully")
                completionHandler(self.localVideoStream)
            }
        }
    }

    func stopLocalVideoStream(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        isCameraPreferredOn = false
        guard let videoStream = self.localVideoStream else {
            print("Local video has already stopoed")
            completionHandler(.success(()))
            return
        }
        self.call?.stopVideo(stream: videoStream) { (error) in
            if error != nil {
                print("ERROR: Local video failed to stop. \(error!)")
                completionHandler(.failure(error!))
                return
            }
            print("Local video stopped successfully")
            completionHandler(.success(()))
        }
    }

    func pauseLocalVideoStream(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        if isCameraPreferredOn {
            self.stopLocalVideoStream { [weak self] result in
                guard let self = self else {
                    return
                }
                if case .failure(let error) = result {
                    print("ERROR: Local video failed to pause. \(error)")
                    completionHandler(.failure(error))
                    return
                }
                self.isVideoOnHold = true
                print("Local video paused successfully")
                completionHandler(.success(()))
            }
        }
    }

    func mute(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.call?.mute(completionHandler: { (error) in
            if error != nil {
                print("ERROR: It was not possible to mute. \(error!)")
                completionHandler(.failure(error!))
                return
            }
            print("Mute successful")
            completionHandler(.success(()))
        })
    }

    func unmute(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.call?.unmute(completionHandler: { (error) in
            if error != nil {
                print("ERROR: It was not possible to unmute. \(error!)")
                completionHandler(.failure(error!))
                return
            }
            print("Unmute successful")
            completionHandler(.success(()))
        })
    }

    private func setupCalling(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        callClient = CallClient()
        self.setupDeviceManager(completionHandler: completionHandler)
    }

    private func setupCallAgent(displayName: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        var tokenCredential: CommunicationTokenCredential
        let tokenCredentialOptions = CommunicationTokenRefreshOptions(initialToken: nil, refreshProactively: true, tokenRefresher: tokenFetcher)

        do {
            tokenCredential = try CommunicationTokenCredential(withOptions: tokenCredentialOptions)
        } catch {
            print("ERROR: It was not possible to create user credential.")
            completionHandler(.failure(error))
            return
        }

        let options = CallAgentOptions()
        options.displayName = displayName

        callClient?.createCallAgent(userCredential: tokenCredential, options: options) { [weak self] (agent, error) in
            guard let self = self else {
                return
            }

            if error != nil {
                print("ERROR: It was not possible to create a call agent.")
                completionHandler(.failure(error!))
                return
            }

            print("Call agent successfully created.")
            self.callAgent = agent
            completionHandler(.success(()))
        }
    }

    private func setupDeviceManager(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        callClient?.getDeviceManager { [weak self] (deviceManager, error) in
            guard let self = self else {
                return
            }

            if error != nil {
                print("ERROR: Failed to get device manager instance")
                completionHandler(.failure(error!))
                return
            }

            print("Got device manager instance")
            self.deviceManager = deviceManager

            completionHandler(.success(()))
        }
    }

    private func setupAudioPermissions(completionHandler: @escaping () -> Void) {
        if AVAudioSession.sharedInstance().recordPermission == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { _ in
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }

    private func setupVideoPermissions(completionHandler: @escaping (LocalVideoStream?) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else {
                return
            }

            if granted {
                self.setupLocalVideoStream(completionHandler: completionHandler)
            } else {
                completionHandler(nil)
            }
        }
    }

    private func setupLocalVideoStream(completionHandler: @escaping (LocalVideoStream?) -> Void) {
        guard let deviceManager = deviceManager else {
            return
        }
        let camera = deviceManager.cameras[0]
        localVideoStream = LocalVideoStream(camera: camera)
        completionHandler(localVideoStream)
    }

    private func setupRemoteParticipantsEventsAdapter() {
        participantsEventsAdapter = ParticipantsEventsAdapter()

        participantsEventsAdapter?.onIsMutedChanged = { [weak self] remoteParticipant in
            guard let self = self else {
                return
            }
            if let userIdentifier = remoteParticipant.identifier.stringValue,
               self.displayedRemoteParticipants.value(forKey: userIdentifier) != nil {
                self.notifyRemoteParticipantViewChanged()
            }
        }

        participantsEventsAdapter?.onIsSpeakingChanged = { [weak self] remoteParticipant in
            guard let self = self else {
                return
            }
            if let userIdentifier = remoteParticipant.identifier.stringValue {
                if remoteParticipant.isSpeaking,
                   self.displayedRemoteParticipants.count == CallingContext.remoteParticipantsDisplayed,
                   self.displayedRemoteParticipants.value(forKey: userIdentifier) == nil {
                    // Swap in speaking participant if not currently displayed
                    self.findInactiveSpeakerToSwap(with: remoteParticipant, id: userIdentifier)
                } else if self.displayedRemoteParticipants.value(forKey: userIdentifier) != nil {
                    // Highlight active speaker
                    self.notifyRemoteParticipantViewChanged()
                }
            }
        }

        participantsEventsAdapter?.onVideoStreamsUpdated = { [weak self] _ in
            guard let self = self else {
                return
            }
            self.notifyRemoteParticipantsUpdated()
        }
    }
}

extension CallingContext: CallDelegate {
    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        switch call.state {
        case .connected:
            addRemoteParticipants(call.remoteParticipants)
            updateDisplayedRemoteParticipants()
            notifyRemoteParticipantsUpdated()
        default:
            break
        }
    }

    func call(_ call: Call, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs) {
        removeRemoteParticipants(args.removedParticipants)
        addRemoteParticipants(args.addedParticipants)
        updateDisplayedRemoteParticipants()
        notifyRemoteParticipantsUpdated()
    }

    private func findInactiveSpeakerToSwap(with remoteParticipant: RemoteParticipant, id: String) {
        for displayedRemoteParticipant in displayedRemoteParticipants {
            if !displayedRemoteParticipant.isSpeaking,
               let displayedUserIdentifier = displayedRemoteParticipant.identifier.stringValue {
                displayedRemoteParticipants.removeValue(forKey: displayedUserIdentifier)
                displayedRemoteParticipants.append(forKey: id, value: remoteParticipant)
                notifyRemoteParticipantsUpdated()
                return
            }
        }
    }

    private func removeRemoteParticipants(_ remoteParticipants: [RemoteParticipant]) {
        for participant in remoteParticipants {
            if let userIdentifier = participant.identifier.stringValue {
                self.remoteParticipants.removeValue(forKey: userIdentifier)?.delegate = nil
                self.displayedRemoteParticipants.removeValue(forKey: userIdentifier)
            }
        }
    }

    private func addRemoteParticipants(_ remoteParticipants: [RemoteParticipant]) {
        for participant in remoteParticipants {
            if let userIdentifier = participant.identifier.stringValue {
                participant.delegate = self.participantsEventsAdapter
                self.remoteParticipants.append(forKey: userIdentifier, value: participant)
            }
        }
    }

    private func updateDisplayedRemoteParticipants() {
        for remoteParticipant in remoteParticipants {
            if displayedRemoteParticipants.count < CallingContext.remoteParticipantsDisplayed,
               remoteParticipant.state != .inLobby,
               let userIdentifier = remoteParticipant.identifier.stringValue {
                displayedRemoteParticipants.append(forKey: userIdentifier, value: remoteParticipant)
            }
        }
    }

    private func notifyRemoteParticipantsUpdated() {
        NotificationCenter.default.post(name: .remoteParticipantsUpdated, object: nil)
    }

    private func notifyRemoteParticipantViewChanged() {
        NotificationCenter.default.post(name: .remoteParticipantViewChanged, object: nil)
    }
}

extension Notification.Name {
    static let remoteParticipantsUpdated = Notification.Name("RemoteParticipantsUpdated")
    static let remoteParticipantViewChanged = Notification.Name("RemoteParticipantViewChanged")
}
