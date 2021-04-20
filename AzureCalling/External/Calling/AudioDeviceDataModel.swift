//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

struct AudioDeviceDataModel {
    let image: UIImage
    let name: String
    let enabled: Bool
}

extension AudioDeviceDataModel {
    func convertToCellViewData() -> CellViewData {
        return CellViewData(avatar: image, title: name, enabled: enabled)
    }
}
