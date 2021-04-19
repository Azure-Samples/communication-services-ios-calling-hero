//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

class ParticipantsEventsAdapter: NSObject, RemoteParticipantDelegate {
    var onVideoStreamsUpdated: ((RemoteParticipant) -> Void) = {_ in }
    var onIsSpeakingChanged: ((RemoteParticipant) -> Void) = {_ in }

    func remoteParticipant(_ remoteParticipant: RemoteParticipant, didUpdateVideoStreams args: RemoteVideoStreamsEventArgs) {
        onVideoStreamsUpdated(remoteParticipant)
    }

    func remoteParticipant(_ remoteParticipant: RemoteParticipant, didChangeSpeakingState args: PropertyChangedEventArgs) {
        onIsSpeakingChanged(remoteParticipant)
    }
}
