//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

enum AudioDeviceType: String {
    case receiver = "iOS"
    case speaker = "Speaker"

    var name: String {
        return self.rawValue
    }
    var iconName: String {
        switch self {
        case .receiver:
            return "ic_fluent_speaker_2_28_regular"
        case .speaker:
            return "ic_fluent_speaker_2_28_filled"
        }
    }
}
