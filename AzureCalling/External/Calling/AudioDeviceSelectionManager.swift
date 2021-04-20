//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation

class AudioDeviceSelectionManager {
    private var parentView: UIViewController

    init(view: UIViewController) {
        parentView = view
    }
    /*
     What states do we need to keep track of?
     let audioSession = AVAudioSession.sharedInstance()
     
     func switchAudio(enum audioDevice)
     
     */
    func getAudioDevicess() -> [AudioDeviceDataModel] {
        let audioSession = AVAudioSession.sharedInstance()
        let inputs = audioSession.availableInputs
        print("There are \(inputs!.count) inputs available")

        for input in inputs! {
            print("Port name: \(input.portName)")
            print("Port type: \(input.portType)")
        }

        let iPhoneDevice = AudioDeviceDataModel(image: UIImage(named: "ic_fluent_mic_on_28_filled")!, name: "iPhone", enabled: false)
        let speakerPhone = AudioDeviceDataModel(image: UIImage(named: "ic_fluent_speaker_2_28_filled")!, name: "Speaker", enabled: true)

        let audioDevices = [iPhoneDevice, speakerPhone]
        return audioDevices
    }

    func switchAudioDevice(audioDeviceDataModel: AudioDeviceDataModel) {
        let audioSession = AVAudioSession.sharedInstance()
        //let audioSessionMode = AVAudioSession.Mode.default
        //let audioSessionOptions: AVAudioSession.CategoryOptions = [.duckOthers, .allowBluetooth, .interruptSpokenAudioAndMixWithOthers, .allowBluetoothA2DP]
        switch audioDeviceDataModel.name {
        case "iPhone":
            print("iPhone Audio selected")
            do {
                try audioSession.overrideOutputAudioPort(.none)
            } catch _ {
                print("iPhone Audio selected exception")
            }
        case "Speaker":
            print("Speaker Audio selected")
            do {
                try audioSession.overrideOutputAudioPort(.speaker)
            } catch _ {
                print("Speaker Audio selected exception")
            }
        default:
            print("default")
        }
    }
}
