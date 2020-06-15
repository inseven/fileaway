//
//  SettingsViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/05/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import UIKit
import SwiftUI

import FileawayCore

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewControllerDidFinish(_ controller: SettingsViewController)
}

class SettingsViewController: UIHostingController<SettingsView> {

    weak var delegate: SettingsViewControllerDelegate?
    var manager: Manager?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsView(tasks: AppDelegate.shared.manager!.tasks))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }

    @objc func doneTapped() {
        guard let delegate = self.delegate else {
            return
        }
        delegate.settingsViewControllerDidFinish(self)
    }

}
