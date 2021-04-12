//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import MSAL

enum AADAuthStatus {
    case noAuthRequire
    case waitingAuth
    case authorized
}

class AADAuthHandler {
    // MARK: Constants

    private let kAADAuthority: String = "https://login.microsoftonline.com"

    // MARK: Properties

    private (set) var authStatus: AADAuthStatus
    private (set) var authToken: String?

    private var appSettings: AppSettings
    private var applicationContext: MSALPublicClientApplication?
    private var currentAccount: MSALAccount?

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        authStatus = self.appSettings.isAADAuthEnabled ? .waitingAuth : .noAuthRequire

        guard appSettings.isAADAuthEnabled,
              !appSettings.aadClientId.isEmpty,
              let authUrl = URL(string: kAADAuthority) else {
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

    func loadAccountAndSilentlyLogin(from viewController: UIViewController,
                                     completionHandler: @escaping () -> Void) {
        loadAccount { [weak self] account in
            guard let account = account else {
                completionHandler()
                return
            }

            self?.acquireTokenSilently(from: viewController, account: account) {
                completionHandler()
            }
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
            completionHandler()
        }
    }

    private func updateCurrentAccount(_ account: MSALAccount?) {
        self.currentAccount = account
    }

    private func updateAccessToken(_ token: String?) {
        self.authToken = token
        if token?.isEmpty ?? true {
            self.authStatus = appSettings.isAADAuthEnabled ? .waitingAuth : .noAuthRequire
        } else {
            self.authStatus = .authorized
        }
    }
}
