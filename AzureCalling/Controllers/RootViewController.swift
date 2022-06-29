//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class RootViewController: UIViewController {

    var authHandler: AADAuthHandler!
    var createCallingContextFunction: (() -> CallingContext)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // TODO: Layout the view
        view.backgroundColor = .green

        // TODO: Check and maintain the auth state; pop up the LoginViewController as a sheet to log a user in
    }
}
