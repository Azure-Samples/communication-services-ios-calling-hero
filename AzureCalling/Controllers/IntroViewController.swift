//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

let learnMoreURL = "https://aka.ms/ACS-CallingSample-iOS"

class IntroViewController: UIViewController {

    // MARK: Properties

    var authHandler: AADAuthHandler!
    var createCallingContextFunction: (() -> CallingContext)!

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

    // MARK: UI layout

    private func setupAuthAndUI() {
        view.backgroundColor = .white
        self.layoutButtons()

        authHandler.loadAccountAndSilentlyLogin(from: self) { [weak self] in
            guard let self = self else {
                return
            }
            self.handleAuthState()
        }
    }

    private func handleAuthState() {
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
        signinButton.isHidden = true
        startCallButton.isHidden = false
        joinCallButton.isHidden = false
    }

    private func showLoginButtonAndHideCallingButton() {
        signinButton.isHidden = false
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
            self.handleAuthState()
        }
    }

    private func signOutAAD() {
        authHandler.signOutCurrentAccount(from: self) { [weak self] in
            guard let self = self else {
                return
            }
            self.handleAuthState()
        }
    }

    @objc func loginButtonPressed(_ sender: UIButton) {
        loginAAD()
    }

    @objc func joinCallPressed(_ sender: UIButton) {
        let joinCallVc = JoinCallViewController()
        joinCallVc.createCallingContextFunction = createCallingContextFunction
        navigationController?.pushViewController(joinCallVc, animated: true)
    }

    @objc func startCallPressed(_ sender: UIButton) {
        let lobbyVc = LobbyViewController()
        lobbyVc.callingContext = createCallingContextFunction()
        navigationController?.pushViewController(lobbyVc, animated: true)
    }

    @objc func signOutButtonPressed(_ sender: UIButton) {
        showSignOutAlert()
    }

    private func layoutTopBar() {

    }

    private func layoutMainContainer() {
        let view = UIView()

        view.addSubview(titleLabel)
    }

    private func layoutButtons() {
        let stackView = UIStackView(
            arrangedSubviews: [
                signinButton,
                startCallButton,
                joinCallButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 8
        view.addSubview(stackView)
        signinButton.expandHorizontallyInSuperView()
        startCallButton.expandHorizontallyInSuperView()
        joinCallButton.expandHorizontallyInSuperView()
        stackView.expandHorizontallyInSuperView(withEqualMargin: 16)

        stackView.pinToBottom(withMargin: view.safeAreaInsets.bottom + 34)
    }

    // MARK: - Control constructors
    private var titleLabel: FluentUI.Label = {
        let sampleLabel = FluentUI.Label(style: .title1)

        sampleLabel.text = "Video calling sample"
        return sampleLabel
    }()

    private lazy var signinButton: FluentUI.Button = {
        let button = FluentUI.Button(style: .primaryFilled)
        button.setTitle("Sign in", for: .normal)
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

        return button
    }()

    private lazy var startCallButton: FluentUI.Button = {
        let button = FluentUI.Button(style: .primaryFilled)
        button.setTitle("Start a call", for: .normal)
        button.addTarget(self, action: #selector(startCallPressed), for: .touchUpInside)

        return button
    }()

    private lazy var joinCallButton: FluentUI.Button = {
        let button = FluentUI.Button(style: .primaryOutline)
        button.setTitle("Join a call", for: .normal)
        button.addTarget(self, action: #selector(joinCallPressed), for: .touchUpInside)

        return button
    }()

    private lazy var signOutButton: FluentUI.Button = {
        let button = FluentUI.Button(style: .secondaryOutline)
        button.setTitle("Sign out", for: .normal)
        button.addTarget(self, action: #selector(signOutButtonPressed), for: .touchUpInside)

        return button
    }()
}
