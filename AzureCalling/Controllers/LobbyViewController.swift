//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureCommunicationCalling
import AVFoundation

class LobbyViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties

    var callingContext: CallingContext!
    var previewRenderer: VideoStreamRenderer?
    var rendererView: RendererView?
    var joinInput: String?
    var joinCallType: JoinCallType = .groupCall
    var audioDeviceSelectionManager: AudioDeviceSelectionManager!
    var audioDeviceTableDataSource: TableViewDataSource?

    private var displayName: String = ""

    // MARK: IBOutlets

    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var previewCenterImageView: UIImageView!
    @IBOutlet weak var permissionWarningView: UIView!
    @IBOutlet weak var permissionIconView: UIImageView!
    @IBOutlet weak var permissionWarningLabel: UILabel!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var videoMicrophoneControlStackView: UIStackView!
    @IBOutlet weak var toggleVideoButton: UIButton!
    @IBOutlet weak var toggleMicrophoneButton: UIButton!
    @IBOutlet weak var selectAudioDeviceButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startCallButton: UIButton!

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()

        showSetupLoadingView()

        // Setup calling context asynchronously so that navigation is not blocked
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            self.callingContext.setup {_ in
                self.hideSetupLoadingView()
                self.updatePermissionView()
                self.updateStartCallButtonState()
            }
        }
        audioDeviceSelectionManager = AudioDeviceSelectionManager()
        let audioDevices = audioDeviceSelectionManager.initAudioDevicess()
        var audioDeviceCellViewModels = [BottomDrawerCellViewModel]()
        for audioDevice in audioDevices {
            audioDeviceCellViewModels.append(audioDevice.convertToCellViewModel())
        }
        audioDeviceTableDataSource = TableViewDataSource(cellViewDataModel: audioDeviceCellViewModels)
        setupUI()
    }

    deinit {
        cleanRenderView()
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        displayName = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        updateStartCallButtonState()
        return true
    }

    // MARK: Private Functions

    private func setupUI() {
        setupStartCallButton()
        setupNameTextField()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupPreviewView(localVideoStream: LocalVideoStream) {
        if rendererView == nil {
            do {
                loadingView.startAnimating()
                previewRenderer = try VideoStreamRenderer(localVideoStream: localVideoStream)
                rendererView = try previewRenderer!.createView(withOptions: CreateViewOptions(scalingMode: .crop))
                rendererView!.translatesAutoresizingMaskIntoConstraints = false
                previewView.insertSubview(rendererView!, belowSubview: permissionWarningView)
                rendererView!.topAnchor.constraint(equalTo: previewView.topAnchor).isActive = true
                rendererView!.bottomAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
                rendererView!.leftAnchor.constraint(equalTo: previewView.leftAnchor).isActive = true
                rendererView!.rightAnchor.constraint(equalTo: previewView.rightAnchor).isActive = true
                loadingView.stopAnimating()
            } catch {
                print("Failed to create renderer for lobby video view")
            }
        }
    }

    private func hidePermissionWarning() {
        permissionWarningView.isHidden = true
        previewCenterImageView.isHidden = false
        toggleMicrophoneButton.isHidden = false
        toggleVideoButton.isHidden = false
    }

    private func showPermissionWarning() {
        permissionWarningView.isHidden = false
        previewCenterImageView.isHidden = true
    }

    private func showDeviceDrawer() {
        let audioDeviceSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "AudioDeviceSelectionViewController") as! AudioDeviceSelectionViewController
        audioDeviceSelectionViewController.audioDeviceSelectionManager = audioDeviceSelectionManager
        audioDeviceSelectionViewController.audioDeviceTableDataSource = audioDeviceTableDataSource
        audioDeviceSelectionViewController.modalPresentationStyle = .overCurrentContext
        audioDeviceSelectionViewController.modalTransitionStyle = .crossDissolve
        present(audioDeviceSelectionViewController, animated: false, completion: nil)
    }

    private func updateCameraDisabledPermissionWarning() {
        permissionIconView.image = UIImage(named: "videoOff")
        permissionWarningLabel.text = "Your camera is disabled. To enable, please go to Settings to allow access."
        toggleMicrophoneButton.isHidden = false
        toggleVideoButton.isHidden = true
    }

    private func updateMicrophoneDisabledPermissionWarning() {
        permissionIconView.image = UIImage(named: "audioOff")
        permissionWarningLabel.text = "Your audio is disabled. To enable, please go to Settings to allow access. You must enable audio to start this call."
        toggleMicrophoneButton.isHidden = true
        toggleVideoButton.isHidden = false
    }

    private func updateCameraAndMicrophoneDisabledPermissionWarning() {
        permissionIconView.image = UIImage(named: "audioVideoOff")
        permissionWarningLabel.text = "Your camera and audio are disabled. To enable, please go to Settings to allow access. You must enable audio to start this call."
        toggleMicrophoneButton.isHidden = true
        toggleVideoButton.isHidden = true
    }

    private func updatePermissionView() {
        let videoPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioPermissionStatus = AVAudioSession.sharedInstance().recordPermission

        if audioPermissionStatus == .granted,
           videoPermissionStatus == .notDetermined || videoPermissionStatus == .authorized {
            // audio permission granted, video permission granted or notDetermined
            hidePermissionWarning()
            return
        }

        showPermissionWarning()

        if audioPermissionStatus == .granted {
            // audio granted, video not granted
            updateCameraDisabledPermissionWarning()

        } else if videoPermissionStatus == .denied || videoPermissionStatus == .restricted {
            // audio not granted, video not granted
            updateCameraAndMicrophoneDisabledPermissionWarning()
        } else {
            // audio not granted only
            updateMicrophoneDisabledPermissionWarning()
        }
    }

    private func cleanRenderView() {
        rendererView?.dispose()
        previewRenderer?.dispose()
    }

    private func setupStartCallButton() {
        let isJoinInputValid = !(joinInput?.isEmpty ?? true)
        let startButtonTitle = isJoinInputValid ? "Join call" : "Start a call"
        startCallButton.setTitle(startButtonTitle, for: .normal)
        if let icon = UIImage(named: "ic_fluent_meet_now_24_regular") {
            let buttonIcon = icon.withRenderingMode(.alwaysTemplate)
            startCallButton.tintColor = UIColor.systemBackground
            startCallButton.setImage(buttonIcon, for: .normal)
        }
    }

    private func setupNameTextField() {
        let placeHolder = "John Smith"
        let placeHolderColor = ThemeColor.gray300
        nameTextField.delegate = self
        nameTextField.attributedPlaceholder = NSAttributedString(string: placeHolder,
                                                                 attributes: [.foregroundColor: placeHolderColor])
    }

    private func showSetupLoadingView() {
        loadingView.startAnimating()
        previewCenterImageView.isHidden = true
        toggleVideoButton.isEnabled = false
        toggleMicrophoneButton.isEnabled = false
        startCallButton.isEnabled = false
        permissionWarningView.isHidden = true
    }

    private func hideSetupLoadingView() {
        loadingView.stopAnimating()
        previewCenterImageView.isHidden = false
        toggleVideoButton.isEnabled = true
        toggleMicrophoneButton.isEnabled = true
        startCallButton.isEnabled = true
        permissionWarningView.isHidden = false
    }

    private func updateStartCallButtonState() {
        let isDisplayNameValid = !displayName.isEmpty
        let audioPermissionStatus = AVAudioSession.sharedInstance().recordPermission
        let isPermissionValid = audioPermissionStatus == .granted || audioPermissionStatus == .undetermined
        startCallButton.isEnabled = isDisplayNameValid && isPermissionValid
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           view.frame.origin.y == 0 {
            view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case "StartCall":
            prepareStartCall(destination: segue.destination)
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }

    private func prepareStartCall(destination: UIViewController) {
        guard let callViewController = destination as? CallViewController else {
            fatalError("Unexpected destination: \(destination)")
        }

        cleanRenderView()
        let joinCallConfig = JoinCallConfig(joinId: joinInput,
                                            isMicrophoneMuted: toggleMicrophoneButton.isSelected,
                                            isCameraOn: !toggleVideoButton.isSelected,
                                            displayName: displayName,
                                            callType: joinCallType)

        callViewController.joinCallConfig = joinCallConfig
        callViewController.callingContext = callingContext
        callViewController.audioDeviceSelectionManager = audioDeviceSelectionManager
        callViewController.audioDeviceTableDataSource = audioDeviceTableDataSource
    }

    // MARK: Actions

    @IBAction func toggleVideoButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            callingContext.withLocalVideoStream { [weak self] localVideoStream in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }
                    if let localVideoStream = localVideoStream {
                        self.setupPreviewView(localVideoStream: localVideoStream)
                    }
                    self.rendererView?.isHidden = false
                    self.updatePermissionView()
                }
            }
        } else {
            rendererView?.isHidden = true
        }
    }

    @IBAction func toggleMicrophoneButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func selectAudioDeviceButtonPressed(_ sender: UIButton) {
        showDeviceDrawer()
    }

    @IBAction func goToSettingsButtonPressed(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
}
