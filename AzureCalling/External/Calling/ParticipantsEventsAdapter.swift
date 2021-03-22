//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

class ParticipantsEventsAdapter: NSObject, RemoteParticipantDelegate {
    var onStateChanged: ((RemoteParticipant) -> Void) = {_ in }
    var onVideoStreamsUpdated: ((RemoteParticipant) -> Void) = {_ in }
    var onIsSpeakingChanged: ((RemoteParticipant) -> Void) = {_ in }

    func onStateChanged(_ remoteParticipant: RemoteParticipant!, args: PropertyChangedEventArgs!) {
        onStateChanged(remoteParticipant)
    }

    func onVideoStreamsUpdated(_ remoteParticipant: RemoteParticipant, args: RemoteVideoStreamsEventArgs) {
        onVideoStreamsUpdated(remoteParticipant)
    }

    func onIsSpeakingChanged(_ remoteParticipant: RemoteParticipant, args: PropertyChangedEventArgs) {
        onIsSpeakingChanged(remoteParticipant)
    }
}
