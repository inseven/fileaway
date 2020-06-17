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

    func moveFileTapped() {
        let viewController = MoveFileViewController()
        self.present(viewController, animated: true, completion: nil)
    }

}
