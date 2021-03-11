//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling
import AVFoundation

enum CallingInterfaceState {
    case connecting
    case waitingAdmission
    case admissionDenied
    case connected
    case removed
}

public typealias TokenFetcher = (@escaping (String?, Error?) -> Void) -> Void

class CallingContext: NSObject {
    // MARK: Constants
    private static let remoteParticipantsDisplayed: Int = 3

    // MARK: Properties
    private (set) var joinId: String!
    private (set) var displayName: String!
    private (set) var isCameraPreferredOn: Bool = false
    private (set) var displayedRemoteParticipants: MappedSequence<String, RemoteParticipant> = MappedSequence<String, RemoteParticipant>()
    private (set) var remoteParticipants: MappedSequence<String, RemoteParticipant> = MappedSequence<String, RemoteParticipant>()
    private var localVideoStream: LocalVideoStream?
    private var tokenFetcher: TokenFetcher

    private var isSetup: Bool = false
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?

    var callingInterfaceState: CallingInterfaceState = .connecting
    var callType: JoinCallType = .groupCall
    var isRecordingActive: Bool = false
    var participantCount: Int {
        let remoteParticipantCount = call?.remoteParticipants?.count ?? 0
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
                self.isSetup = true
                completionHandler(.success(()))
            }
        }
    }

    func joinCall(_ joinConfig: JoinCallConfig, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.callAgent = nil
        self.callingInterfaceState = .connecting
        self.setupCallAgent(displayName: joinConfig.displayName) { [weak self] _ in
            guard let self = self else {
                return
            }

            let joinCallOptions = JoinCallOptions()

            if joinConfig.isCameraOn && self.localVideoStream != nil {
                let videoOptions = VideoOptions(localVideoStream: self.localVideoStream)
                joinCallOptions!.videoOptions = videoOptions
            }

            joinCallOptions!.audioOptions = AudioOptions()
            joinCallOptions!.audioOptions.muted = joinConfig.isMicrophoneMuted

            var joinLocator: AbstractJoinMeetingLocator!
            let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? UUID().uuidString
            switch joinConfig.callType {
            case .groupCall:
                let groupId = UUID(uuidString: joinIdStr) ?? UUID()
                joinLocator = GroupCallLocator(groupId: groupId)!
            case .teamsMeeting:
                joinLocator = TeamsMeetingLinkLocator(meetingLink: joinIdStr)
                self.callingInterfaceState = .waitingAdmission
            }

            self.call = self.callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions)
            self.call?.delegate = self

            self.joinId = joinConfig.joinId
            self.callType = joinConfig.callType
            self.displayName = joinConfig.displayName
            self.isCameraPreferredOn = joinConfig.isCameraOn
            completionHandler(.success(()))
        }
    }

    func endCall(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.call?.hangup(options: HangupOptions()) { (error) in
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

    func startVideo(completionHandler: @escaping (LocalVideoStream?) -> Void) {
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

    func stopVideo(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        isCameraPreferredOn = false
        self.call?.stopVideo(stream: self.localVideoStream) { (error) in
            if error != nil {
                print("ERROR: Local video failed to stop. \(error!)")
                completionHandler(.failure(error!))
                return
            }
            print("Local video stopped successfully")
            completionHandler(.success(()))
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
        setupCallAgent(displayName: "") { [weak self] result in
            guard let self = self else {
                return
            }

            if case .failure(let error) = result {
                completionHandler(.failure(error))
                return
            }
            self.setupDeviceManager(completionHandler: completionHandler)
        }
    }

    private func setupCallAgent(displayName: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        var tokenCredential: CommunicationTokenCredential?
        let tokenCredentialOptions = CommunicationTokenRefreshOptions(initialToken: nil, refreshProactively: true, tokenRefresher: tokenFetcher)

        do {
            tokenCredential = try CommunicationTokenCredential(with: tokenCredentialOptions)
        } catch {
            print("ERROR: It was not possible to create user credential.")
            completionHandler(.failure(error))
            return
        }

        let options = CallAgentOptions()
        options?.displayName = displayName

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
        let camera = deviceManager.getCameraList()![0]
        localVideoStream = LocalVideoStream(camera: camera)
        completionHandler(localVideoStream)
    }
}

extension CallingContext: CallDelegate, RemoteParticipantDelegate {
    func onCallStateChanged(_ call: Call!, args: PropertyChangedEventArgs!) {
        switch call.state {
        case .none:
            if callType == .teamsMeeting {
                callingInterfaceState = callingInterfaceState == .connected ? .removed : .admissionDenied
            }
        case .connected:
            callingInterfaceState = .connected
        case .inLobby:
            callingInterfaceState = .waitingAdmission
        default:
            break
        }
        notifyOnCallStateUpdated()
    }

    func onRemoteParticipantsUpdated(_ call: Call, args: ParticipantsUpdatedEventArgs) {
        for removedParticipant in args.removedParticipants {
            if let removedUser = removedParticipant.identity as? CommunicationUserIdentifier {
                self.remoteParticipants.removeValue(forKey: removedUser.identifier)?.delegate = nil
                self.displayedRemoteParticipants.removeValue(forKey: removedUser.identifier)
            }
        }

        for addedParticipant in args.addedParticipants {
            if let addedUser = addedParticipant.identity as? CommunicationUserIdentifier {
                addedParticipant.delegate = self
                self.remoteParticipants.append(forKey: addedUser.identifier, value: addedParticipant)
            }
        }

        for remoteParticipant in remoteParticipants {
            //if a remote participant is waiting permission to join a Teams meeting, his state is .idle
            if displayedRemoteParticipants.count < CallingContext.remoteParticipantsDisplayed,
               remoteParticipant.state != .idle,
               let user = remoteParticipant.identity as? CommunicationUserIdentifier {
                displayedRemoteParticipants.append(forKey: user.identifier, value: remoteParticipant)
            }
        }

        notifyRemoteParticipantsUpdated()
    }

    func onVideoStreamsUpdated(_ remoteParticipant: RemoteParticipant, args: RemoteVideoStreamsEventArgs) {
        notifyRemoteParticipantsUpdated()
    }

    func onIsSpeakingChanged(_ remoteParticipant: RemoteParticipant, args: PropertyChangedEventArgs) {
        if remoteParticipant.isSpeaking, let user = remoteParticipant.identity as? CommunicationUserIdentifier {
            // Swap in speaking participant if not currently displayed
            if displayedRemoteParticipants.value(forKey: user.identifier) == nil {
                if displayedRemoteParticipants.count == CallingContext.remoteParticipantsDisplayed {
                    findInactiveSpeakerToSwap(with: remoteParticipant, id: user.identifier)
                }
            }
        }
    }

    func onIsRecordingActiveChanged(_ call: Call!, args: PropertyChangedEventArgs!) {
        let newRecordingActive = call.isRecordingActive
        if newRecordingActive != isRecordingActive {
            isRecordingActive = newRecordingActive
            notifyOnRecordingActiveChangeUpdated()
        }
    }

    func onParticipantStateChanged(_ remoteParticipant: RemoteParticipant!, args: PropertyChangedEventArgs!) {
        guard displayedRemoteParticipants.count < CallingContext.remoteParticipantsDisplayed,
           let user = remoteParticipant.identity as? CommunicationUserIdentifier,
           remoteParticipant.state == .connected else {
            return
        }

        displayedRemoteParticipants.append(forKey: user.identifier, value: remoteParticipant)
        notifyRemoteParticipantsUpdated()
    }

    private func findInactiveSpeakerToSwap(with remoteParticipant: RemoteParticipant, id: String) {
        for displayedRemoteParticipant in displayedRemoteParticipants {
            if !displayedRemoteParticipant.isSpeaking, let displayedUser = displayedRemoteParticipant.identity as? CommunicationUserIdentifier {
                displayedRemoteParticipants.removeValue(forKey: displayedUser.identifier)
                displayedRemoteParticipants.append(forKey: id, value: remoteParticipant)
                notifyRemoteParticipantsUpdated()
                return
            }
        }
    }

    private func notifyRemoteParticipantsUpdated() {
        NotificationCenter.default.post(name: .remoteParticipantsUpdated, object: nil)
    }

    private func notifyOnRecordingActiveChangeUpdated() {
        NotificationCenter.default.post(name: .onRecordingActiveChangeUpdated, object: nil)
    }

    private func notifyOnCallStateUpdated() {
        NotificationCenter.default.post(name: .onCallStateUpdated, object: nil)
    }
}

extension Notification.Name {
    static let remoteParticipantsUpdated = Notification.Name("RemoteParticipantsUpdated")
    static let onCallStateUpdated = Notification.Name("OnCallStateUpdated")
    static let onRecordingActiveChangeUpdated = Notification.Name("OnRecordingActiveChangeUpdated")
}
