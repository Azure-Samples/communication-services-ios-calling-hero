//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation

class AudioDeviceSelectionManager {

    func initAudioDevicess() -> [AudioDeviceDataModel] {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch _ {
            print("Speaker Audio selected exception")
        }

        let iPhoneDevice = AudioDeviceDataModel(image: UIImage(named: "ic_fluent_mic_on_28_filled")!, name: "iPhone", enabled: false)
        let speakerPhone = AudioDeviceDataModel(image: UIImage(named: "ic_fluent_speaker_2_28_filled")!, name: "Speaker", enabled: true)

        let audioDevices = [iPhoneDevice, speakerPhone]
        return audioDevices
    }

    func switchAudioDevice(audioDeviceDataModel: AudioDeviceDataModel) {
        let audioSession = AVAudioSession.sharedInstance()
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
