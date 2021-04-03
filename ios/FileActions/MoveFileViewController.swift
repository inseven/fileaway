// Copyright (c) 2018-2021 InSeven Limited
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
        pickerViewController.manager = AppDelegate.shared.settings.manager!
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
