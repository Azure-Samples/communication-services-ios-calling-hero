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

    private var signinButton: FluentUI.Button!
    private var startCallButton: FluentUI.Button!
    private var joinCallButton: FluentUI.Button!
    private var signOutButton: FluentUI.Button!
    private var topBar: UIView!
    private var userAvatar: MSFAvatar!
    private var userDisplayName: FluentUI.Label!

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        createControls()
        layoutView()

        handleAuthState()
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
    private func createControls() {
        signinButton = FluentUI.Button.createWith(
            style: .primaryFilled,
            title: "Sign in",
            action: { [weak self] _ in self?.loginAAD() }
        )
        startCallButton = FluentUI.Button.createWith(
            style: .primaryFilled,
            title: "Start a call",
            action: { [weak self] _ in self?.startCall() }
        )
        joinCallButton = FluentUI.Button.createWith(
            style: .primaryOutline,
            title: "Join a call",
            action: { [weak self] _ in self?.joinCall() }
        )
        signOutButton = FluentUI.Button.createWith(
            style: .borderless, title: "Sign out",
            action: { [weak self] _ in self?.showSignOutAlert() }
        )
    }

    private func layoutView() {
        view.backgroundColor = ThemeColor.lightSurfacesSecondary
        layoutButtons()
        layoutMainContainer()
        layoutTopBar()
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
        stackView.pinToBottom()
    }

    private func layoutMainContainer() {
        let titleLabel = FluentUI.Label(style: .title1)
        titleLabel.text = "Video calling sample"

        let builtWithLabel = FluentUI.Label(style: .body)
        builtWithLabel.text = "Built with"
        builtWithLabel.directionalLayoutMargins.top = 24

        let acsImageLabel = FluentUI.Label(style: .button1)
        acsImageLabel.text = "Azure Communication Services"
        acsImageLabel.textColor = ThemeColor.primary

        let acsLabelStack = UIStackView(arrangedSubviews: [
            UIImageView(image: UIImage(named: "acsLogo")),
            acsImageLabel
        ])

        let labelContainer = UIView()
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.addSubview(builtWithLabel)
        labelContainer.addSubview(acsLabelStack)
        builtWithLabel.centerHorizontallyInContainer()
        acsLabelStack.centerHorizontallyInContainer()

        labelContainer.layer.cornerRadius = 12
        labelContainer.backgroundColor = ThemeColor.lightSurfacesPrimary
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-24-[builtWith]-[labelStack]-24-|",
                metrics: nil,
                views: ["builtWith": builtWithLabel,
                        "labelStack": acsLabelStack]
            )
        )

        let stackView = UIStackView(arrangedSubviews: [titleLabel, labelContainer])
        labelContainer.expandHorizontallyInSuperView()

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 32
        view.addSubview(stackView)

        stackView.expandHorizontallyInSuperView(withEqualMargin: 16)
        stackView.centerVerticallyInContainer()
    }

    private func layoutTopBar() {
        let container = UIView()
        topBar = container
        view.addSubview(container)
        topBar.pinToTop()
        topBar.expandHorizontallyInSuperView()
        topBar.addSubview(signOutButton)
        signOutButton.pinToRight()

        userAvatar = MSFAvatar(style: .default, size: .small)
        userDisplayName = FluentUI.Label(style: .title2, colorStyle: .primary)

        let userDetails = UIStackView(arrangedSubviews: [
            userAvatar.view,
            userDisplayName
        ])
        userDetails.spacing = 8

        topBar.addSubview(userDetails)
        userDetails.pinToLeft(withMargin: 16)
    }

    // MARK: - Authentication State Handling
    private func setupAuthAndUI() {
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
            hideLoginButtonAndDisplayCallingButtons()

        case .noAuthRequire:
            hideLoginButtonAndDisplayCallingButtons()

        case .waitingAuth:
            showLoginButtonAndHideCallingButtons()
        }
    }

    private func hideLoginButtonAndDisplayCallingButtons() {
        signinButton.isHidden = true
        startCallButton.isHidden = false
        joinCallButton.isHidden = false
    }

    private func showLoginButtonAndHideCallingButtons() {
        signinButton.isHidden = false
        startCallButton.isHidden = true
        joinCallButton.isHidden = true
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

    // MARK: Action Handling
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

    private func joinCall() {
        let joinCallVc = JoinCallViewController()
        joinCallVc.createCallingContextFunction = createCallingContextFunction
        navigationController?.pushViewController(joinCallVc, animated: true)
    }

    private func startCall() {
        let lobbyVc = LobbyViewController()
        lobbyVc.callingContext = createCallingContextFunction()
        navigationController?.pushViewController(lobbyVc, animated: true)
    }
}
