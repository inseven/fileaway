//
//  SettingsViewController.swift
//  File Actions
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
    var tasks: [TaskState]

    required init?(coder aDecoder: NSCoder) {
        tasks = AppDelegate.shared.manager!.tasks.map { TaskState(task: $0) }
        super.init(coder: aDecoder, rootView: SettingsView(tasks: tasks))
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
