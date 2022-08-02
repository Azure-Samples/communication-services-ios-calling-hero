//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling
import AzureCommunicationUICalling

public typealias TokenFetcher = (@escaping (String?, Error?) -> Void) -> Void

final class CallingContext {
    // MARK: Constants
    private static let remoteParticipantsDisplayed: Int = 5

    // MARK: Properties
    private (set) var joinId: String!
    private (set) var displayName: String!
    private var tokenFetcher: TokenFetcher
    private var callComposite: CallComposite?

    var callType: JoinCallType = .groupCall

    // MARK: Initialization

    init(tokenFetcher: @escaping TokenFetcher) {
        self.tokenFetcher = tokenFetcher
    }

    // MARK: Public API

    func getTokenCredential() -> CommunicationTokenCredential? {
        var tokenCredential: CommunicationTokenCredential
        let tokenCredentialOptions = CommunicationTokenRefreshOptions(initialToken: nil, refreshProactively: true, tokenRefresher: tokenFetcher)

        do {
            tokenCredential = try CommunicationTokenCredential(withOptions: tokenCredentialOptions)
        } catch {
            print("ERROR: It was not possible to create user credential.")
            return nil
        }
        return tokenCredential
    }

    func startCallComposite(_ joinConfig: JoinCallConfig) {
        let callCompositeOptions = CallCompositeOptions()
        self.callComposite = CallComposite(withOptions: callCompositeOptions)

        let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let uuid = UUID(uuidString: joinIdStr) ?? UUID()
        let displayName = joinConfig.displayName

        guard let communicationTokenCredential = self.getTokenCredential() else {
            return
        }

        switch joinConfig.callType {
        case .groupCall:
            self.callComposite?.launch(
                remoteOptions: RemoteOptions(
                    for: .groupCall(groupId: uuid),
                    credential: communicationTokenCredential,
                    displayName: displayName
                )
            )

        case .teamsMeeting:
            self.callComposite?.launch(
                remoteOptions: RemoteOptions(
                    for: .teamsMeeting(teamsLink: joinIdStr),
                    credential: communicationTokenCredential,
                    displayName: displayName
                )
            )
        }
    }
}
