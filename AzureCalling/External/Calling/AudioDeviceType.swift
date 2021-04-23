//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

enum AudioDeviceType: String {
    case receiver = "iPhone"
    case speaker = "Speaker"

    var image: UIImage {
        switch self {
        case .receiver:
            return UIImage(named: "ic_fluent_speaker_2_28_regular")!
        case .speaker:
            return UIImage(named: "ic_fluent_speaker_2_28_filled")!
        }
    }

    var name: String {
        return self.rawValue
    }

    var accessoryImage: UIImage {
        return UIImage(named: "ic_fluent_checkmark_20_filled")!
    }
}
