//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureCommunicationCalling
import AVFoundation
import MediaPlayer

class LobbyViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {

    // MARK: Properties

    var callingContext: CallingContext!
    var previewRenderer: VideoStreamRenderer?
    var rendererView: RendererView?
    var joinInput: String?
    var joinCallType: JoinCallType = .groupCall

    private var displayName: String = ""

    // MARK: IBOutlets

    @IBOutlet weak var overlayView: UIView!
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
    @IBOutlet weak var deviceDrawer: UITableView!
    var datasource: TableViewDataSource?

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
        let isJoinInputValid = !(joinInput?.isEmpty ?? true)
        let startButtonTitle = isJoinInputValid ? "Join call" : "Start a call"
        startCallButton.setTitle(startButtonTitle, for: .normal)
        nameTextField.delegate = self
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
                rendererView = try previewRenderer!.createView(with: RenderingOptions(scalingMode: .crop))
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
        print("Audio selection pressed")
        let audioSession = AVAudioSession.sharedInstance()
        let inputs = audioSession.availableInputs
        print("There are \(inputs!.count) inputs available")

        for input in inputs! {
            print("Port name: \(input.portName)")
            print("Port type: \(input.portType)")
        }

        overlayView.isHidden = false

        let audioDeviceCell = UINib(nibName: "CellView",
                                      bundle: nil)
        deviceDrawer.register(audioDeviceCell, forCellReuseIdentifier: "CellView")
        deviceDrawer.isHidden = false
        //deviceDrawer.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        let iPhoneDevice = CellViewData(avatar: UIImage(named: "ic_fluent_mic_on_28_filled")!, title: "iPhone", statusImage: UIImage.init(systemName: "checkmark")!, shouldDisplayStatus: true)
        let speakerPhone = CellViewData(avatar: UIImage(named: "ic_fluent_speaker_2_28_filled")!, title: "Speaker", statusImage: UIImage.init(systemName: "checkmark")!, shouldDisplayStatus: false)

//        AudioDeviceSelectionManager
//        - Creates the CellViewDate
//        (Generates available audio devices)
//        - Passes AudioModule type to ViewController
//        View Controller creates the BottomDrawerView
//

        let audioDevices = [iPhoneDevice, speakerPhone]
        datasource = TableViewDataSource(cellViewData: audioDevices)
        //UITableViewDelegate(closures: closures)
        deviceDrawer.dataSource = datasource
        deviceDrawer.delegate = self
        deviceDrawer.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print("Selected table row: \(indexPath.row)")

        let audioSession = AVAudioSession.sharedInstance()
        //let audioSessionMode = AVAudioSession.Mode.default
        //let audioSessionOptions: AVAudioSession.CategoryOptions = [.duckOthers, .allowBluetooth, .interruptSpokenAudioAndMixWithOthers, .allowBluetoothA2DP]
        switch indexPath.row {
        case 0:
            print("iPhone Audio selected")
            do {
                //audiodeviceSelectionmanger.turnonearpiece()
                try audioSession.overrideOutputAudioPort(.none)
            } catch _ {
                print("iPhone Audio selected exception")
            }
        case 1:
            print("Speaker Audio selected")
            do {
                try audioSession.overrideOutputAudioPort(.speaker)
            } catch _ {
                print("Speaker Audio selected exception")
            }
        default:
            print("default")
        }

        tableView.deselectRow(at: indexPath, animated: false)
        tableView.isHidden = true
        //tableView.frame.size.height = tableView.contentSize.height
        overlayView.isHidden = true

        return indexPath
    }

    @IBAction func goToSettingsButtonPressed(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
}

extension MPVolumeView {
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
      slider?.value = volume
    }
  }
}
