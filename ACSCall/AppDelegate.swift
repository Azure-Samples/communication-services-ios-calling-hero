//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import MSAL
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private (set) var appSettings: AppSettings!
    private (set) var authHandler: AADAuthHandler!
    private (set) var tokenService: TokenService!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setAudioSessionOutputToSpeaker()
        initializeDependencies()

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        if let keywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
            let navigationController = keywindow.rootViewController as? UINavigationController {

            if navigationController.visibleViewController is CallViewController {
                return UIInterfaceOrientationMask.all
            } else {
                return UIInterfaceOrientationMask.portrait
            }
        }

        return UIInterfaceOrientationMask.portrait
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        // Required for AAD Authentication
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }

    // MARK: Private Functions

    private func initializeDependencies() {
        appSettings = AppSettings()
        authHandler = AADAuthHandler(appSettings: appSettings)
        tokenService = TokenService(acsTokenFetchUrl: appSettings.acsTokenFetchUrl, getAuthTokenFunction: { () -> String? in
            return self.authHandler.authToken
        })
    }

    private func setAudioSessionOutputToSpeaker() {
        // Make loud-speaker as the default sound output in the app

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat)
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch {
            print("Failed to set audio session category.")
        }
    }

}
