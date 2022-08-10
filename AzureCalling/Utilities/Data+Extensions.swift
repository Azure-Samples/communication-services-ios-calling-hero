//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Data {
    var asPrettyJson: String? {
        guard let json = try? JSONSerialization.jsonObject(with: self),
              let jsonString = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let prettyValue = String(data: jsonString, encoding: .utf8) else {
            return nil
        }
        return prettyValue
    }
}
