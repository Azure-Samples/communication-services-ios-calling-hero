//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

let learnMoreURL = "https://aka.ms/acs"

class IntroViewController: UIViewController {

    // MARK: Properties
    var authHandler: AADAuthHandler!
    var createCallingContextFunction: (() -> CallingContext)!

    private var userDetails: UserDetails?

    private var signinButton: FluentUI.Button!
    private var startCallButton: FluentUI.Button!
    private var joinCallButton: FluentUI.Button!
    private var signOutButton: FluentUI.Button!
    private var topBar: UIView!
    private var userAvatar: MSFAvatar!
    private var userDisplayName: FluentUI.Label!
    private let busyOverlay = BusyOverlay(frame: .zero)

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FluentUI.Colors.surfaceSecondary
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
        signinButton.setTitle("Signing in...", for: .disabled)

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
            style: .borderless,
            title: "Sign out",
            action: { [weak self] _ in self?.showSignOutAlert() }
        )
    }

    private func layoutView() {
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
        stackView.pinToBottom(withMargin: 16)
    }

    private func layoutMainContainer() {
        let titleLabel = FluentUI.Label.createWith(style: .title1,
                                                   colorStyle: .regular,
                                                   value: "Video calling sample")

        let builtWithLabel = FluentUI.Label.createWith(style: .body,
                                                       colorStyle: .regular,
                                                       value: "Built with")
        builtWithLabel.directionalLayoutMargins.top = 24

        let acsImageLabel = FluentUI.Label.createWith(style: .button1,
                                                      colorStyle: .primary,
                                                      value: "Azure Communication Services")

        let acsLabelStack = UIStackView(arrangedSubviews: [
            UIImageView(image: UIImage(named: "acsLogo")),
            acsImageLabel
        ])
        acsLabelStack.spacing = 8

        let labelContainer = UIView()
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.addSubview(builtWithLabel)
        labelContainer.addSubview(acsLabelStack)
        builtWithLabel.centerHorizontallyInContainer()
        acsLabelStack.centerHorizontallyInContainer()

        labelContainer.layer.cornerRadius = 12
        labelContainer.backgroundColor = FluentUI.Colors.surfaceTertiary
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
        labelContainer.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.showLearnMoreWebView)
            )
        )

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
        signOutButton.expandVerticallyInSuperView()
        signOutButton.pinToRight()

        userAvatar = MSFAvatar(style: .default, size: .small)
        userDisplayName = FluentUI.Label.createWith(style: .body,
                                                    colorStyle: .regular)
        let userDetails = UIStackView(arrangedSubviews: [
            userAvatar.view,
            userDisplayName
        ])
        topBar.addSubview(userDetails)
        userDetails.spacing = 8
        userDetails.centerVerticallyInContainer()
        userDetails.pinToLeft(withMargin: 16)
    }

    // MARK: - Authentication State Handling
    private func handleAuthState() {
        userAvatar.state.image = userDetails?.avatar
        userAvatar.state.primaryText = userDetails?.userProfile?.displayName
        userDisplayName.text = userDetails?.userProfile?.displayName
        var showBusy = false

        switch authHandler.authStatus {
        case .authorized:
            hideLoginButtonAndDisplayCallingButtons()
            topBar.isHidden = false

        case .noAuthRequired:
            hideLoginButtonAndDisplayCallingButtons()
            topBar.isHidden = true

        case .unauthorized:
            topBar.isHidden = true
            showLoginButtonAndHideCallingButtons()

        case .authorizing:
            showBusy = true
        }

        if showBusy {
            busyOverlay.present()
            signinButton.isEnabled = false
        } else {
            busyOverlay.hide()
            signinButton.isEnabled = true
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

    @objc private func showLearnMoreWebView() {
        guard let urlLink = URL(string: learnMoreURL) else {
            return
        }

        UIApplication.shared.open(urlLink)
    }

    // MARK: Action Handling
    private func loginAAD() {
        Task {
            do {
                signinButton.isEnabled = false
                busyOverlay.present()
                userDetails = try await authHandler.login(presentingVc: self)
            } catch {
                print(error)
                handleError(message: error.localizedDescription)
            }
            handleAuthState()
        }
    }

    private func handleError(message: String) {
        let notification = FluentUI.NotificationView()
        notification.setup(style: .dangerToast, message: message)
        notification.show(in: view)
        notification.hide(after: 5, animated: true, completion: nil)
    }

    private func signOutAAD() {
        Task {
            do {
                signOutButton.isEnabled = false
                busyOverlay.present()
                try await authHandler.signOut(presentingVc: self)
            } catch {
                print("MSAL couldn't sign out account with error: \(error)")
                handleError(message: error.localizedDescription)
            }
            signOutButton.isEnabled = true
            handleAuthState()
        }
    }

    private func joinCall() {
        let joinCallVc = JoinCallViewController()
        joinCallVc.callingContext = createCallingContextFunction()
        joinCallVc.displayName = displayName()
        navigationController?.pushViewController(joinCallVc, animated: true)
    }

    private func startCall() {
        let startCallVc = StartCallViewController()
        startCallVc.callingContext = createCallingContextFunction()
        startCallVc.displayName = displayName()
        navigationController?.pushViewController(startCallVc, animated: true)
    }

    private func displayName() -> String? {
        return userDetails?.userProfile?.displayName ?? AppSettings().displayName
    }
}
