//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import MSAL
import FluentUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let winScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: winScene)
        let fluentNavVc = FluentUI.UINavigationController(rootViewController: IntroViewController())
        fluentNavVc.view.backgroundColor = .white
        fluentNavVc.view.tintColor = FluentUI.Colors.textSecondary
        fluentNavVc.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]

        fluentNavVc.navigationBar.backgroundColor = .white
        fluentNavVc.navigationBar.topItem?.backButtonDisplayMode = .minimal
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        fluentNavVc.navigationBar.scrollEdgeAppearance = appearance
        window?.rootViewController = fluentNavVc

        if let navigationViewController = window?.rootViewController as? UINavigationController,
           let rootVc = navigationViewController.visibleViewController as? IntroViewController,
           let appDelegate = UIApplication.shared.delegate as? AppDelegate {

            rootVc.authHandler = appDelegate.authHandler
            rootVc.createCallingContextFunction = { () -> CallingContext in
                return CallingContext(tokenFetcher: appDelegate.tokenService.getCommunicationToken)
            }
        }
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else {
            return
        }
        handleMSALResponse(urlContext)
    }

    // MARK: Private Functions

    private func handleMSALResponse(_ urlContext: UIOpenURLContext) {
        // Required for AAD Authentication

        let url = urlContext.url
        let sourceApp = urlContext.options.sourceApplication

        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApp)
    }

}
