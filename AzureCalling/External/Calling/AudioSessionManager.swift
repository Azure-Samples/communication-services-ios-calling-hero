//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation

class AudioSessionManager {

    // MARK: Public Functions

    public static func getAllAudioDeviceTypes() -> [AudioDeviceType] {
        let audioDevices: [AudioDeviceType] = [.receiver, .speaker]
        return audioDevices
    }

    public static func getCurrentAudioDeviceType() -> AudioDeviceType {
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
            if desc.portType == .builtInSpeaker {
                return .speaker
            }
        }
        return .receiver
    }

    public static func switchAudioDeviceType(audioDeviceType: AudioDeviceType) {
        let audioSession = AVAudioSession.sharedInstance()
        switch audioDeviceType {
        case .receiver:
            print("iPhone Audio selected")
            do {
                try audioSession.overrideOutputAudioPort(.none)
            } catch _ {
                print("iPhone Audio selected exception")
            }
        case .speaker:
            print("Speaker Audio selected")
            do {
                try audioSession.overrideOutputAudioPort(.speaker)
            } catch _ {
                print("Speaker Audio selected exception")
            }
        }
    }
}
