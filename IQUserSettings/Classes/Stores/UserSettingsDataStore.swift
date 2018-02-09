//
//  UserSettingsDataStore.swift
//  IQUserSettings
//
//  Created by Chad Newbry on 2/8/18.
//  Copyright © 2018 Chad Newbry. All rights reserved.
//

import Foundation

public protocol UserSettingsDataStore {
    var settings: [String: Any] { get }
    func setSetting(key: String, value: Any)
}
