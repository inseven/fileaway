//
//  MoveFileViewController.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 16/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import MobileCoreServices
import UIKit

class MoveFileViewController: UINavigationController {

    let documentBrowser: UIDocumentBrowserViewController

    init() {
        documentBrowser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: [kUTTypePDF as String])
        documentBrowser.allowsDocumentCreation = false
        super.init(rootViewController: documentBrowser)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        documentBrowser.delegate = self
        self.documentBrowser.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.documentBrowser.navigationItem.title = "Select File"
    }

    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension MoveFileViewController: UIDocumentBrowserViewControllerDelegate {

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard
            let url = documentURLs.first,
            let pickerViewController = AppDelegate.shared.instantiateViewController(identifier: .picker) as? PickerViewController else {
                return
        }
        pickerViewController.manager = AppDelegate.shared.manager
        do {
            try url.prepareForSecureAccess()
        } catch {
            return
        }
        pickerViewController.documentUrl = url
        self.pushViewController(pickerViewController, animated: true)
        self.setNavigationBarHidden(false, animated: true)
    }

}
