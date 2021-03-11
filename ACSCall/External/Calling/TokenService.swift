//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TokenService {
    private var acsTokenFetchUrl: String
    private var getAuthTokenFunction: () -> String?

    init(acsTokenFetchUrl: String, getAuthTokenFunction: @escaping () -> String?) {
        self.acsTokenFetchUrl = acsTokenFetchUrl
        self.getAuthTokenFunction = getAuthTokenFunction
    }

    func getACSToken(completionHandler: @escaping (String?, Error?) -> Void) {
        let url = URL(string: acsTokenFetchUrl)!
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
