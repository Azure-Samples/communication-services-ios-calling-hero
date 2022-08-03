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

    // MARK: Private function
    private func fetchInitialToken(completionHandler: @escaping (String?) -> Void) {
        tokenFetcher { token, error in
            guard error == nil else {
                print("ERROR: Failed to fetch initial token. \(error?.localizedDescription ?? "")")
                return
            }
            completionHandler(token)
        }
    }

    // MARK: Public API
    func getTokenCredential(completionHandler: @escaping (CommunicationTokenCredential?) -> Void) {
        fetchInitialToken { [weak self] token in
            guard let self = self else {
                return
            }
            let tokenCredentialOptions = CommunicationTokenRefreshOptions(initialToken: token, refreshProactively: true, tokenRefresher: self.tokenFetcher)

            do {
                let tokenCredential = try CommunicationTokenCredential(withOptions: tokenCredentialOptions)
                completionHandler(tokenCredential)
            } catch {
                print("ERROR: It was not possible to create user credential.")
                completionHandler(nil)
            }
        }
    }

    func startCallComposite(_ joinConfig: JoinCallConfig, completionHandler: @escaping () -> Void) {
        let callCompositeOptions = CallCompositeOptions()
        self.callComposite = CallComposite(withOptions: callCompositeOptions)

        let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let uuid = UUID(uuidString: joinIdStr) ?? UUID()
        let displayName = joinConfig.displayName

        self.getTokenCredential { [weak self] communicationTokenCredential in
            guard let communicationTokenCredential = communicationTokenCredential else {
                print("ERROR: Cannot start or join a call due to user credential creating failure.")
                completionHandler()
                return
            }
            DispatchQueue.main.async {
                switch joinConfig.callType {
                case .groupCall:
                    self?.callComposite?.launch(
                        remoteOptions: RemoteOptions(
                            for: .groupCall(groupId: uuid),
                            credential: communicationTokenCredential,
                            displayName: displayName
                        )
                    )

                case .teamsMeeting:
                    self?.callComposite?.launch(
                        remoteOptions: RemoteOptions(
                            for: .teamsMeeting(teamsLink: joinIdStr),
                            credential: communicationTokenCredential,
                            displayName: displayName
                        )
                    )
                }
            }
            completionHandler()
        }
    }
}
