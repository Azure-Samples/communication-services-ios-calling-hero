//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import UIKit
import FluentUI

class InviteViewController: UIViewController {
    // MARK: Properties
    var createCallingContextFunction: (() -> CallingContext)?
    var groupCallId: String?

    private var iconImageView: UIImageView!
    private var titleLabel: FluentUI.Label!
    private var subtitleLabel: FluentUI.Label!
    private var shareButton: FluentUI.Button!
    private var continueButton: FluentUI.Button!

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: UI layout
    private func setupUI() {
        view.backgroundColor = ThemeColor.lightSurfacesPrimary
        title = "Invite another device ?"
        setupImageViews()
        setupLabels()
        setupButtons()
        layoutContinueButton()
        layoutMainContainer()
    }

    private func setupImageViews() {
        let imageRect = CGRect(x: 0, y: 0, width: 27, height: 23)
        iconImageView = UIImageView(frame: imageRect)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = FluentUI.Colors.iconSecondary
        iconImageView.image = UIImage(named: "ic_fluent_phone_desktop_28_regular")
    }

    private func setupLabels() {
        titleLabel = FluentUI.Label.createWith(style: .title1,
                                               colorStyle: .regular,
                                               value: "Invite another device?")
        subtitleLabel = FluentUI.Label.createWith(style: .body,
                                                  colorStyle: .regular,
                                                  value: "Use the group call ID to join this call on another device.")
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
    }

    private func setupButtons() {
        shareButton = FluentUI.Button.createWith(
            style: .secondaryOutline,
            title: "Share group call ID",
            action: { [weak self] _ in self?.onShareButtonTapped() }
        )
        shareButton.image = UIImage(named: "ic_fluent_share_screen_stop_20_regular")

        continueButton = FluentUI.Button.createWith(
            style: .primaryFilled,
            title: "Continue",
            action: { [weak self] _ in self?.onContinueButtonTapped() }
        )
    }

    private func layoutContinueButton() {
        view.addSubview(continueButton)
        continueButton.fixHeightTo(height: 52)
        continueButton.expandHorizontallyInSuperView(withEqualMargin: 16)
        continueButton.pinToBottom(withMargin: 16)
    }

    private func layoutMainContainer() {
        let mainContainer = UIView()
        view.addSubview(mainContainer)
        mainContainer.expandHorizontallyInSuperView(withEqualMargin: 16)
        mainContainer.pinToTop(withMargin: 0)
        continueButton.topAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: 12).isActive = true

        let iconContainer = PaddingContainer(containing: iconImageView, padding: UIEdgeInsets(top: 29, left: 0, bottom: 4, right: 0))
        iconImageView.fixHeightTo(height: 28)

        let buttonContainer = PaddingContainer(containing: shareButton, padding: UIEdgeInsets(top: 32, left: 76, bottom: 12, right: 76))
        shareButton.fixHeightTo(height: 48)

        let stackView = UIStackView(arrangedSubviews: [iconContainer, titleLabel, subtitleLabel, buttonContainer])
        mainContainer.addSubview(stackView)

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 4

        stackView.expandHorizontallyInSuperView()
        stackView.centerVerticallyInContainer()
    }

    // MARK: Action Handling
    private func onShareButtonTapped() {
        let image = UIImage(named: "ic_fluent_key_20_regular")
        let textToShare = LinkMetadataManager(title: "Group call ID",
                                              text: groupCallId ?? "",
                                              iconImage: image)
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                  applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }

    private func onContinueButtonTapped() {
    }
}
