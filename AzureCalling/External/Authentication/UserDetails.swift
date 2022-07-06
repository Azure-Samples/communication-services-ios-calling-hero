//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

struct UserProfile: Decodable {

    var displayName: String?
    var givenName: String?
    var surname: String?
    var mail: String?
    var id: String?
}

struct UserDetails {
    var authToken: String?
    var avatar: UIImage?
    var userProfile: UserProfile?
}
