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

    private func fetchInitialToken() async -> String? {
        return await withCheckedContinuation { continuation in
            tokenFetcher { token, error in
                guard error == nil else {
                    print("ERROR: Failed to fetch initial token. \(error?.localizedDescription ?? "")")
                    return
                }
                continuation.resume(returning: token)
            }
        }
    }

    // MARK: Public API
    func getTokenCredential() async throws -> CommunicationTokenCredential {
            let token = await fetchInitialToken()
            let tokenCredentialOptions = CommunicationTokenRefreshOptions(initialToken: token, refreshProactively: true, tokenRefresher: self.tokenFetcher)
            do {
                let tokenCredential = try CommunicationTokenCredential(withOptions: tokenCredentialOptions)
                return tokenCredential
            } catch {
                print("ERROR: It was not possible to create user credential.")
                throw error
            }
    }

    func startCallComposite(_ joinConfig: JoinCallConfig) async {
        let callCompositeOptions = CallCompositeOptions()
        self.callComposite = CallComposite(withOptions: callCompositeOptions)

        let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let uuid = UUID(uuidString: joinIdStr) ?? UUID()
        let displayName = joinConfig.displayName

        do {
            let communicationTokenCredential = try await getTokenCredential()
            DispatchQueue.main.async {
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
        } catch {
            print("ERROR: Cannot start or join a call due to user credential creating error: \(error.localizedDescription).")
        }
    }
}
