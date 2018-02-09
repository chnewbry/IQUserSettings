//
//  UserSettingsProtocol.swift
//  IQUserSettings
//
//  Created by Chad Newbry on 2/8/18.
//  Copyright © 2018 Chad Newbry. All rights reserved.
//

import Foundation

public protocol UserSettingsAPI {
    func refresh(completion: (_ result: Result) -> Void)
}
