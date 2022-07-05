//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import MSAL

enum AADAuthStatus {
    case noAuthRequired
    case unauthorized
    case authorizing
    case authorized
}

enum AADAuthError: Error {
    case msalNotConfigured
    case noApplicationContext
    case noMsalAccount
    case missingAuthToken
    case jsonParsingFailed
    case badImageData
}

class AADAuthHandler {
    // MARK: Constants
    private let kAADAuthority: String = "https://login.microsoftonline.com/common"
    private let kGraphHost: String = "https://graph.microsoft.com/v1.0"

    // MARK: Properties
    private (set) var authStatus: AADAuthStatus
    private (set) var authToken: String?
    private (set) var userAvatar: UIImage?
    private (set) var userDisplayName: String?

    private var appSettings: AppSettings
    private var applicationContext: MSALPublicClientApplication?
    private var currentAccount: MSALAccount?

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        authStatus = self.appSettings.isAADAuthEnabled ? .unauthorized : .noAuthRequired

        guard appSettings.isAADAuthEnabled,
              !appSettings.aadClientId.isEmpty,
              let authUrl = URL(string: kAADAuthority) else {
            assert(!appSettings.communicationTokenFetchUrl.isEmpty,
            """
            *****************************

            You don't have Azure Active Directory enabled and also don't have a token URL setup.
            Please configure the AppSettings.plist file appropriately

            *****************************

            """)
            return
        }

        var redirectUri: String?
        if !appSettings.aadRedirectURI.isEmpty {
            redirectUri = appSettings.aadRedirectURI
        }

        let tenantAuthUrl = authUrl.appendingPathComponent(appSettings.aadTenantId)

        do {
            let authority = try MSALAADAuthority(url: tenantAuthUrl)
            let msalConfiguration = MSALPublicClientApplicationConfig(clientId: appSettings.aadClientId, redirectUri: redirectUri, authority: authority)
            self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        } catch let error {
            print("Unable to initialize MSAL: \(error)")
        }
    }

    // MARK: Public API
    func login(presentingVc: UIViewController,
               completionHandler: @escaping (Error?) -> Void) {

        // Attempt silent login with existing account, falling back to interactive.
        Task {
            do {
                var result: MSALResult?
                if let account = try await loadMsalAccount() {
                    result = try? await loginSilently(account: account)
                }

                if result == nil {
                    result = try await loginInteractively(from: presentingVc)
                }

                updateAccessToken(result?.accessToken)
                currentAccount = result?.account

                let profile = try await getProfile()
                userDisplayName = profile.displayName

                // Uncomment to obtain the user's avatar image if they have one
//                let avatar = try? await getAvatarImage()
//                userAvatar = avatar

                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        }
    }

    func signOut(presentingVc viewController: UIViewController,
                 completionHandler: @escaping (Error?) -> Void) {
        Task {
            do {
                try await signOut(from: viewController)
                print("MSAL sign out completed")
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            } catch {
                print("MSAL couldn't sign out account with error: \(error)")
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        }
    }

    // MARK: Private Functions
    @MainActor
    private func signOut(from viewController: UIViewController) async throws {
        guard let appContext = self.applicationContext,
              let account = self.currentAccount else {
            throw AADAuthError.noApplicationContext
        }

        let signoutParameters = MSALSignoutParameters(
            webviewParameters: MSALWebviewParameters(authPresentationViewController: viewController)
        )
        signoutParameters.signoutFromBrowser = false

        try await appContext.signout(with: account, signoutParameters: signoutParameters)
        updateAccessToken(nil)
        currentAccount = nil
        userAvatar = nil
        userDisplayName = nil
    }

    private func loadMsalAccount() async throws -> MSALAccount? {
        guard let applicationContext = self.applicationContext else {
            throw AADAuthError.noApplicationContext
        }
        return try await withCheckedThrowingContinuation({ continuation in
            let msalParameters = MSALParameters()
            applicationContext.getCurrentAccount(with: msalParameters) { currentAccount, _, error in
                if let err = error {
                    continuation.resume(throwing: err)
                } else {
                    continuation.resume(returning: currentAccount)
                }
            }
        })
    }

    private func loginSilently(account: MSALAccount) async throws -> MSALResult {
        guard let appContext = applicationContext else {
            throw AADAuthError.noApplicationContext
        }

        let parameters = MSALSilentTokenParameters(scopes: appSettings.aadScopes, account: account)
        return try await appContext.acquireTokenSilent(with: parameters)
    }

    @MainActor
    private func loginInteractively(from viewController: UIViewController) async throws -> MSALResult {
        guard let appContext = applicationContext else {
            throw AADAuthError.noApplicationContext
        }

        let webViewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        webViewParameters.webviewType = .wkWebView

        let parameters = MSALInteractiveTokenParameters(scopes: appSettings.aadScopes,
                                                        webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        return try await appContext.acquireToken(with: parameters)
    }

    private func getProfile() async throws -> UserDetails {
        guard let detailsUrl = URL(string: kGraphHost.appending("/me")),
              let accessToken = authToken else {
            throw AADAuthError.missingAuthToken
        }
        var request = URLRequest(url: detailsUrl)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if let jsonData = data,
                   let profile = try? JSONDecoder().decode(UserDetails.self, from: jsonData) {
                    continuation.resume(returning: profile)
                } else {
                    continuation.resume(throwing: AADAuthError.jsonParsingFailed)
                }
            }.resume()
        })
    }

    private func getAvatarImage() async throws -> UIImage {
        guard let avatarUrl = URL(string: kGraphHost.appending("/me/photos/48x48/$value")),
              let accessToken = authToken else {
            throw AADAuthError.missingAuthToken
        }
        var request = URLRequest(url: avatarUrl)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: request) { imageData, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let data = imageData,
                   let image = UIImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: AADAuthError.badImageData)
                }
            }.resume()
        })
    }

    private func updateAccessToken(_ token: String?) {
        self.authToken = token
        if token?.isEmpty ?? true {
            self.authStatus = appSettings.isAADAuthEnabled ? .unauthorized : .noAuthRequired
        } else {
            self.authStatus = .authorized
        }
    }
}
