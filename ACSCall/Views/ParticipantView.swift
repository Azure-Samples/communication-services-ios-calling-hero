//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation
import AzureCommunicationCalling

class ParticipantView: UIView {
    private static let xibName: String = "ParticipantView"

    // MARK: Properties

    private var renderer: Renderer?
    private var rendererView: RendererView?
    private var localVideoSourceId: String?
    private var remoteVideoStreamId: Int32?

    // MARK: IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var videoViewContainer: UIView!
    @IBOutlet weak var participantLabel: ParticipantLabel!

    // MARK: Constructors

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    // MARK: Operation methods

    func updateDisplayName(displayName: String) {
        participantLabel.text = displayName
        participantLabel.isHidden = displayName.isEmpty
    }

    func updateVideoStream(localVideoStream: LocalVideoStream?) {
        if localVideoStream == nil {
            cleanUpVideoRendering()
            return
        }

        if localVideoStream!.source.id == localVideoSourceId {
            return
        }

        do {
            let newRenderer: Renderer = try Renderer(localVideoStream: localVideoStream!)
            try updateRendering(newRenderer: newRenderer)
            localVideoSourceId = localVideoStream!.source.id
        } catch {
            print("Failed to render local video")
        }
    }

    func updateVideoStream(remoteVideoStream: RemoteVideoStream?) {
        if remoteVideoStream == nil {
            cleanUpVideoRendering()
            return
        }

        if remoteVideoStream!.id == remoteVideoStreamId {
            return
        }

        do {
            let newRenderer: Renderer = try Renderer(remoteVideoStream: remoteVideoStream!)
            try updateRendering(newRenderer: newRenderer)
            remoteVideoStreamId = remoteVideoStream!.id
        } catch {
            print("Failed to render remote video")
        }
    }

    func updateDisplayNameVisible(isDisplayNameVisible: Bool) {
        guard let view = participantLabel else {
            return
        }

        view.isHidden = !isDisplayNameVisible
    }

    func updateVideoDisplayed(isDisplayVideo: Bool) {
        guard let view = videoViewContainer else {
            return
        }

        placeholderImage.isHidden = isDisplayVideo
        view.isHidden = !isDisplayVideo
    }

    func dispose() {
        cleanUpVideoRendering()
    }

    // MARK: Private methods

    private func initSubviews() {
        let nib = UINib(nibName: ParticipantView.xibName, bundle: nil)
        nib.instantiate(withOwner: self, options: nil)

        contentView.frame = bounds
        addSubview(contentView)
    }

    private func updateRendering(newRenderer: Renderer) throws {
        let newRendererView: RendererView = try newRenderer.createView(with: RenderingOptions(scalingMode: .crop))

        attachRendererView(rendererView: newRendererView)

        renderer = newRenderer
        rendererView = newRendererView
    }

    private func attachRendererView(rendererView: RendererView) {
        rendererView.translatesAutoresizingMaskIntoConstraints = false
        videoViewContainer.addSubview(rendererView)

        let constraints = [
            rendererView.topAnchor.constraint(equalTo: videoViewContainer.topAnchor),
            rendererView.bottomAnchor.constraint(equalTo: videoViewContainer.bottomAnchor),
            rendererView.leftAnchor.constraint(equalTo: videoViewContainer.leftAnchor),
            rendererView.rightAnchor.constraint(equalTo: videoViewContainer.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

    }

    private func cleanUpVideoRendering() {
        rendererView?.removeFromSuperview()
        rendererView?.dispose()
        renderer?.dispose()
        renderer = nil
        rendererView = nil
        localVideoSourceId = nil
        remoteVideoStreamId = nil
    }
}
