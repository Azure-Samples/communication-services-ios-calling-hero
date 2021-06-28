//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

@objc protocol BottomDrawerDataSource: UITableViewDelegate, UITableViewDataSource {
    @objc optional func refreshDataSource()

    @objc optional func setDismissDrawer(dismissDrawer: @escaping () -> Void)
}
