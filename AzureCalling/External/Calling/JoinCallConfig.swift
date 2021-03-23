//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AVFoundation

struct JoinCallConfig {
    let joinId: String?
    let isMicrophoneMuted: Bool
    let isCameraOn: Bool
    let displayName: String
    let callType: JoinCallType
}
