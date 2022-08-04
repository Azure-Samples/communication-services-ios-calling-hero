//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TokenService {
    private var communicationTokenFetchUrl: String
    private var getAuthTokenFunction: () -> String?

    init(communicationTokenFetchUrl: String, getAuthTokenFunction: @escaping () -> String?) {
        self.communicationTokenFetchUrl = communicationTokenFetchUrl
        self.getAuthTokenFunction = getAuthTokenFunction
    }

    func getCommunicationToken(completionHandler: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: communicationTokenFetchUrl),
              url.host != nil else {
            assertionFailure(
"""
\n
        You need to provide the URL for the endpoint to fetch the ACS token.
        This should be set in a AppSettings.xcconfig file.
\n
"""
            )
            return
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.httpMethod = "GET"
        if let authToken = getAuthTokenFunction() {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(TokenResponse.self, from: data)
                    print(res.token)
                    completionHandler(res.token, nil)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}

private struct TokenResponse: Decodable {
    var token: String

    private enum CodingKeys: String, CodingKey {
        case token
    }
}
