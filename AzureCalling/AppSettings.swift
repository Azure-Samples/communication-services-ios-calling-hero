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
        guard let clientId = settings["aadClientId"] as? String else {
            return false
        }
        return !clientId.isEmpty
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

    var displayName: String? {
        return settings["displayName"] as? String
    }

    var teamsUrl: URL? {
        guard let teamsUrlString = settings["teamsUrl"] as? String else {
            return nil
        }
        return URL(string: teamsUrlString)
    }

    var groupCallUuid: UUID? {
        guard let groupIdString = settings["groupCallUuid"] as? String else {
            return nil
        }
        return UUID(uuidString: groupIdString)
    }

    init() {
        settings = Bundle.main.infoDictionary ?? [:]
    }
}
