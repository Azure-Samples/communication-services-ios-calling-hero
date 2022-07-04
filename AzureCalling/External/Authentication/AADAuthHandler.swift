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
    func login(presentVc: UIViewController,
               completionHandler: @escaping (Error?) -> Void) {

    }

    func loadAccountAndSilentlyLogin(from viewController: UIViewController,
                                     completionHandler: @escaping () -> Void) {
        loadAccount { [weak self] account in
            guard let account = account else {
                print("ERROR: Missing MSAL Account")
                completionHandler()
                return
            }

            self?.acquireTokenSilently(from: viewController,
                                       account: account,
                                       completionHandler: completionHandler)
        }
    }

    func acquireTokenInteractively(from viewController: UIViewController,
                                   completionHandler: @escaping () -> Void) {
        guard let applicationContext = self.applicationContext else {
            return
        }
        let webViewParamaters = MSALWebviewParameters(authPresentationViewController: viewController)
        webViewParamaters.webviewType = .wkWebView

        let parameters = MSALInteractiveTokenParameters(scopes: appSettings.aadScopes, webviewParameters: webViewParamaters)
        parameters.promptType = .selectAccount
        parameters.completionBlockQueue = DispatchQueue.main

        applicationContext.acquireToken(with: parameters) { [weak self] (result, error) in

            if let error = error {
                print("Could not acquire token: \(error)")
                completionHandler()
                return
            }

            guard let result = result else {
                print("Could not acquire token: No result returned")
                completionHandler()
                return
            }

            self?.updateAccessToken(result.accessToken)
            self?.updateCurrentAccount(result.account)
            completionHandler()

        }
    }

    func signOutCurrentAccount(from viewController: UIViewController,
                               completionHandler: @escaping () -> Void) {
        guard let applicationContext = self.applicationContext,
              let account = self.currentAccount else {
            completionHandler()
            return
        }

        let webViewParamaters = MSALWebviewParameters(authPresentationViewController: viewController)

        do {
            let signoutParameters = MSALSignoutParameters(webviewParameters: webViewParamaters)
            signoutParameters.signoutFromBrowser = false
            signoutParameters.completionBlockQueue = DispatchQueue.main

            applicationContext.signout(with: account, signoutParameters: signoutParameters) { [weak self] (_, error) in

                if let error = error {
                    print("MSAL couldn't sign out account with error: \(error)")
                    completionHandler()
                    return
                }

                print("MSAL sign out completed")
                self?.updateAccessToken(nil)
                self?.updateCurrentAccount(nil)
                completionHandler()
            }
        }
    }

    // MARK: Private Functions

    private func getProfile(completion: @escaping () -> Void) {
        guard let avatarUrl = URL(string: kGraphHost.appending("/me/photos/48x48/$value")),
              let detailsUrl = URL(string: kGraphHost.appending("/me")),
              let accessToken = authToken else {
            return
        }
        var detailsRequest = URLRequest(url: detailsUrl)
        detailsRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        var request = URLRequest(url: avatarUrl)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: detailsRequest) { (data, _, _) in
            if let jsonData = data,
               let profile = try? JSONDecoder().decode(UserDetails.self, from: jsonData) {
                self.userDisplayName = profile.displayName
            }

            URLSession.shared.dataTask(with: request) { imageData, _, error in
                if let data = imageData {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            self?.userAvatar = image
                            completion()
                        }
                    }
                } else if let err = error {
                    print(err)
                    completion()
                }
            }.resume()
        }.resume()
    }

    private func loadAccount(completionHandler: @escaping (MSALAccount?) -> Void) {
        guard let applicationContext = self.applicationContext else {
            completionHandler(nil)
            return
        }

        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main

        applicationContext.getCurrentAccount(with: msalParameters) { [weak self] (currentAccount, _, error) in

            if let error = error {
                print("Couldn't query current account with error: \(error)")
                completionHandler(nil)
                return
            }

            if let currentAccount = currentAccount {
                self?.updateCurrentAccount(currentAccount)
                completionHandler(currentAccount)
                return
            }

            self?.updateCurrentAccount(nil)
            completionHandler(nil)
        }
    }

    func acquireTokenSilently(from viewController: UIViewController,
                              account: MSALAccount,
                              completionHandler: @escaping () -> Void) {
        guard let applicationContext = self.applicationContext else {
            completionHandler()
            return
        }
        let parameters = MSALSilentTokenParameters(scopes: appSettings.aadScopes, account: account)
        parameters.completionBlockQueue = DispatchQueue.main

        applicationContext.acquireTokenSilent(with: parameters) { [weak self] (result, error) in

            if let error = error {
                let nsError = error as NSError
                if nsError.domain == MSALErrorDomain {
                    if nsError.code == MSALError.interactionRequired.rawValue {
                        DispatchQueue.main.async {
                            self?.acquireTokenInteractively(from: viewController, completionHandler: completionHandler)
                        }
                        completionHandler()
                        return
                    }
                }
                print("Could not acquire token silently: \(error)")
                completionHandler()
                return
            }

            guard let result = result else {
                print("Could not acquire token: No result returned")
                completionHandler()
                return
            }

            self?.updateAccessToken(result.accessToken)
            self?.updateCurrentAccount(result.account)
            self?.getProfile(completion: completionHandler)
        }
    }

    private func updateCurrentAccount(_ account: MSALAccount?) {
        self.currentAccount = account
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
