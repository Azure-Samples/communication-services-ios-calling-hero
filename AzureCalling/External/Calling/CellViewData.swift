//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

struct CellViewData {
    let avatar: UIImage
    let title: String
    let enabled: Bool
}

extension CellViewData {
    func convertToAudioDeviceDataModel() -> AudioDeviceDataModel {
        return AudioDeviceDataModel(image: avatar, name: title, enabled: enabled)
    }
}
