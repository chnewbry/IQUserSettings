//
//  UserSettingsViewController.swift
//  spendiq
//
//  Created by Chad Newbry on 2/6/18.
//  Copyright © 2018 Mobile Data Labs. All rights reserved.
//

import UIKit

public class UserSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum Sections: Int {
        case refresh = 0, settings, count
    }

    @IBOutlet weak var tableView: UITableView!

    var userSettingsAPI: UserSettingsAPI
    var userSettingsDataStore: UserSettingsDataStore

    public init(userSettingsProtocol: UserSettingsAPI, userSettingsDataStore: UserSettingsDataStore) {
        self.userSettingsAPI = userSettingsProtocol
        self.userSettingsDataStore = userSettingsDataStore

        let bundle = Bundle(for: UserSettingsViewController.self)
        // normally passing nil uses the main bundle
        // due to the fact we're consuming this .xib externally most likely the main bundle
        // isn't where we want to lookup this resource
        super.init(nibName: String(describing: UserSettingsViewController.self), bundle: bundle)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init() instead")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Settings"
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadSettings()
    }

    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let section = Sections(rawValue: indexPath.section) {
            switch section {
            case .refresh:
                let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "refreshSettingsCell")
                cell.textLabel?.text = "Refresh"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                cell.textLabel?.textColor = UIColor.blue
                return cell
            case .settings:
                let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "userSettingCell")

                let keyString = self.userSettingsDataStore.settings.keys.sorted()[indexPath.row]
                let valueDictionary = self.userSettingsDataStore.settings
                let valueString = String(describing: valueDictionary[keyString])

                cell.textLabel?.text = keyString
                cell.detailTextLabel?.text = valueString
                return cell
            case .count:
                // should never be encountered!!
                fatalError("Table View requested cell for section that doesn't exist!")
            }
        }

        // should never be encountered!!
        return UITableViewCell()
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = Sections(rawValue: section) {
            switch section {
            case .refresh:
                return 1
            case .settings:
                return self.userSettingsDataStore.settings.keys.count
            case .count:
                return 0
            }
        }

        return 0
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeader(section: section)
    }

    // MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let section = Sections(rawValue: indexPath.section) {
            switch section {
            case .refresh:
                self.userSettingsAPI.refresh(completion: { (r) in
                    switch r {
                    case .success:
                        DispatchQueue.main.async {
                            let message = "User settings we're refreshed successfully!"
                            let alertController = UIAlertController(title: "Settings Refresh", message: message, preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: false, completion: nil)
                            tableView.deselectRow(at: indexPath, animated: true)
                            self.loadSettings()
                        }
                    case .error:
                        // CN : TODO
                        // "User settings successfully refreshed!"
                        var a = 1
                        a += 1
                    }
                })
            case .settings:
                let keyString = self.userSettingsDataStore.settings.keys.sorted()[indexPath.row]
                let valueString = self.userSettingsDataStore.settings[keyString] as! String
                let settingsOverrideString = "Use this to override a setting locally for the current session. Changes last until the app is relaunched. If you want a setting to persist between sessions use our admin dashboard"

                let alertController = UIAlertController(title: "Settings Override", message: settingsOverrideString, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addTextField { (textField) in
                    textField.text = valueString
                }

                let overrideAction = UIAlertAction(title: "Override", style: UIAlertActionStyle.destructive) { (alertAction) in
                    let settingsValueTextField = alertController.textFields?[0]

                    if settingsValueTextField == nil {
                        return
                    }
                    self.userSettingsDataStore.setSetting(key: keyString, value: settingsValueTextField!.text as Any)
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.left)
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)

                alertController.addAction(overrideAction)
                alertController.addAction(cancelAction)

                self.present(alertController, animated: false, completion: {
                    tableView.deselectRow(at: indexPath, animated: true)
                    })
            case .count:
                return
            }
        }
    }

    // MARK: Private Methods

    func sectionHeader(section: Int) -> String {
        if let section = Sections(rawValue: section) {
            switch section {
            case .refresh:
                return "Refresh"
            case .settings:
                return "Settings"
            case .count:
                return "Unexpected Section Requested"
            }
        }

        return "Unexpected Section Requested"
    }

    func loadSettings() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
