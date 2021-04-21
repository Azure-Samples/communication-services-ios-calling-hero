//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

struct BottomDrawerCellViewModel {
    let avatar: UIImage
    let title: String
    var enabled: Bool
}

extension BottomDrawerCellViewModel {
    func convertToAudioDeviceDataModel() -> AudioDeviceDataModel {
        return AudioDeviceDataModel(image: avatar, name: title, enabled: enabled)
    }
}
