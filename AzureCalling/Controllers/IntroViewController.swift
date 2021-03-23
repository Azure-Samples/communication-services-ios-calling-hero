//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

let learnMoreURL = "https://aka.ms/ACS-CallingSample-iOS"

class IntroViewController: UIViewController {

    // MARK: Properties

    var authHandler: AADAuthHandler!
    var createCallingContextFunction: (() -> CallingContext)!

    // MARK: IBOutlets

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var loginButton: UIRoundedButton!
    @IBOutlet weak var startCallButton: UIRoundedButton!
    @IBOutlet weak var joinCallButton: UIRoundedButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAuthAndUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case "StartNewCall":
            prepareStartCall(destination: segue.destination)
        case "JoinCall":
            prepareJoinCall(destination: segue.destination)
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }

    private func prepareStartCall(destination: UIViewController) {
        guard let lobbyViewController = destination as? LobbyViewController else {
            fatalError("Unexpected destination: \(destination)")
        }

        lobbyViewController.callingContext = createCallingContextFunction()

    }

    private func prepareJoinCall(destination: UIViewController) {
        guard let joinCallViewController = destination as? JoinCallViewController else {
            fatalError("Unexpected destination: \(destination)")
        }

        joinCallViewController.callingContext = createCallingContextFunction()
    }

    // MARK: UI layout

    private func setupAuthAndUI() {
        authHandler.loadAccountAndSilentlyLogin(from: self) { [weak self] in
            guard let self = self else {
                return
            }
            self.layoutButton()
        }
    }

    private func layoutButton() {
        switch authHandler.authStatus {
        case .authorized:
            hideLoginButtonAndDisplayCallingButton()
            showSignOutButton()
        case .noAuthRequire:
            hideLoginButtonAndDisplayCallingButton()
            hideSignOutButton()
        case .waitingAuth:
            showLoginButtonAndHideCallingButton()
            hideSignOutButton()
        }
    }

    private func hideLoginButtonAndDisplayCallingButton() {
        loginButton.isHidden = true
        startCallButton.isHidden = false
        joinCallButton.isHidden = false
    }

    private func showLoginButtonAndHideCallingButton() {
        loginButton.isHidden = false
        startCallButton.isHidden = true
        joinCallButton.isHidden = true
    }

    private func showSignOutButton() {
        signOutButton.isHidden = false
    }

    private func hideSignOutButton() {
        signOutButton.isHidden = true
    }

    private func showSignOutAlert() {
        let alert = UIAlertController(title: "Are you sure you want to sign out?",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { [weak self] _ in
                                        guard let self = self else {
                                            return
                                        }
                                        self.signOutAAD()
                                      }))

        self.present(alert, animated: true, completion: nil)
    }

    private func showLearnMoreWebView() {
        guard let urlLink = URL(string: learnMoreURL) else {
            return
        }

        UIApplication.shared.open(urlLink)
    }

    // MARK: Private Functions

    private func loginAAD() {
        authHandler.acquireTokenInteractively(from: self) { [weak self] in
            guard let self = self else {
                return
            }
            self.layoutButton()
        }
    }

    private func signOutAAD() {
        authHandler.signOutCurrentAccount(from: self) { [weak self] in
            guard let self = self else {
                return
            }
            self.layoutButton()
        }
    }

    // MARK: Actions

    @IBAction func unwindToStart(sender: UIStoryboardSegue) {
        // Allow segue unwind
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loginAAD()
    }

    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        showSignOutAlert()
    }

    @IBAction func learnMoreLinkPressed(_ sender: UITapGestureRecognizer) {
        showLearnMoreWebView()
    }
}
