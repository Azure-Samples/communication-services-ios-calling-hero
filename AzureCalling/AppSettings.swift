//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class AppSettings {

    private var settings: [String: Any] = [:]

    var communicationTokenFetchUrl: String {
        return settings["communicationTokenFetchUrl"] as! String
    }

    var isAADAuthEnabled: Bool {
        return settings["isAADAuthEnabled"] as! Bool
    }

    var aadClientId: String {
        return settings["aadClientId"] as! String
    }

    var aadTenantId: String {
        return settings["aadTenantId"] as! String
    }

    var aadRedirectURI: String {
        return settings["aadRedirectURI"] as! String
    }

    var aadScopes: [String] {
        return settings["aadScopes"] as! [String]
    }

    init() {
        if let url = Bundle.main.url(forResource: "AppSettings", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                settings = try (PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])!
            } catch {
                print(error)
            }
        }
    }

}
