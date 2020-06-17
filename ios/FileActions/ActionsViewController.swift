//
//  ActionsViewController.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 16/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import MobileCoreServices
import PDFKit
import SwiftUI
import UIKit

class ActionsViewController: UIHostingController<ActionsView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ActionsView(settings: AppDelegate.shared.settings))
    }

    override func viewDidLoad() {
        self.rootView.delegate = self
    }

}

extension ActionsViewController: ActionsViewDelegate {

    func settingsTapped() {
        guard
            let navigationController = AppDelegate.shared.instantiateViewController(identifier: .settings) as? UINavigationController,
            let settingsViewController = navigationController.topViewController as? SettingsViewController else {
                return
        }
        settingsViewController.delegate = self
        self.present(navigationController, animated: true, completion: nil)
    }

    func moveFileTapped() {
        let viewController = MoveFileViewController()
        self.present(viewController, animated: true, completion: nil)
    }

    func reversePages(url: URL, completion: @escaping (Error?) -> Void) {
        PDFDocument.reverse(url: url) { result in
            if case .failure(let error) = result {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

}

extension ActionsViewController: SettingsViewControllerDelegate {

    func settingsViewControllerDidFinish(_ controller: SettingsViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
