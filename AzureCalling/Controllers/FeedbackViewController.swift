//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

let feedbackURL = "https://aka.ms/ACS-CallingSample-iOS-Issues"

class FeedbackViewController: UIViewController {

    var onDoneBlock: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let image = UIImage(named: "IntroGraphic")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        let endedLabel = UILabel()
        endedLabel.translatesAutoresizingMaskIntoConstraints = false
        endedLabel.textAlignment = .center
        endedLabel.text = "Call Ended"
        endedLabel.font = .boldSystemFont(ofSize: 30)
        view.addSubview(endedLabel)

        let feedbackLabel = UILabel()
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel.textAlignment = .center
        feedbackLabel.text = "Have any feedback for us? We'd love to hear how we can improve this experience."
        feedbackLabel.font = .systemFont(ofSize: 17)
        feedbackLabel.numberOfLines = 2
        view.addSubview(feedbackLabel)

        let feedbackButton = UIRoundedButton()
        feedbackButton.titleLabel?.font = .systemFont(ofSize: 15)
        feedbackButton.backgroundColor = self.view.tintColor
        feedbackButton.cornerRadius = 8
        feedbackButton.setTitle("Provide Feedback", for: .normal)
        feedbackButton.addTarget(self, action: #selector(provideFeedback), for: .touchUpInside)
        feedbackButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feedbackButton)

        let returnHomeButton = UIButton()
        returnHomeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        returnHomeButton.translatesAutoresizingMaskIntoConstraints = false
        returnHomeButton.setTitle("Return to home screen", for: .normal)
        returnHomeButton.setTitleColor(self.view.tintColor, for: .normal)
        returnHomeButton.titleLabel?.font = .systemFont(ofSize: 15)
        view.addSubview(returnHomeButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            endedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endedLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
            endedLabel.heightAnchor.constraint(equalToConstant: 30),
            endedLabel.widthAnchor.constraint(equalToConstant: 300),
            feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 44),
            feedbackLabel.topAnchor.constraint(equalTo: endedLabel.bottomAnchor, constant: 12),
            feedbackButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -215),
            feedbackButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            feedbackButton.widthAnchor.constraint(equalToConstant: 203),
            feedbackButton.heightAnchor.constraint(equalToConstant: 50),
            returnHomeButton.topAnchor.constraint(equalTo: feedbackButton.bottomAnchor, constant: 24),
            returnHomeButton.centerXAnchor.constraint(equalTo: feedbackButton.centerXAnchor)
        ])
    }

    @objc func provideFeedback() {
        onDoneBlock?(true)
        if let link = URL(string: feedbackURL) {
          UIApplication.shared.open(link)
        }
        dismiss(animated: true)
    }

    @objc func close() {
        dismiss(animated: true) {
            self.onDoneBlock?(false)
        }
    }
}
