//
//  ViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 07/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    @IBOutlet weak var destinationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateDestinationLabel() {
        destinationLabel.text = try? StorageManager.rootUrl().absoluteString
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDestinationLabel()
    }

    func presentDocumentPickerIfNeeded() {
        if let _ = try? StorageManager.rootUrl() {
            return
        }
        let alert = UIAlertController(title: "Document access",
                                      message: "Press OK to continue and select the folder in which you wish to store your documents.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            self.presentDocumentPicker()
        }))
        present(alert, animated: true, completion: nil)
    }

    func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.allowsMultipleSelection = true  // required to allow folder selection
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Picker") {
            guard let navigationViewController = segue.destination as? UINavigationController else {
                present("Unexpected view controller")
                return
            }
            guard let pickerViewController = navigationViewController.topViewController as? PickerViewController else {
                present("Unexpected view controller")
                return
            }
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                present("Unable to get app delegate")
                return
            }

            pickerViewController.manager = appDelegate.manager
            pickerViewController.documentUrl = Bundle.main.url(forResource: "example", withExtension: "pdf")!
        }
    }

    @IBAction func setDestinationTapped(_ sender: Any) {
        presentDocumentPickerIfNeeded()
    }

    @IBAction func saveFileTapped(_ sender: Any) {
		do {
			let rootUrl = try StorageManager.rootUrl()
			createFile(at: rootUrl.appendingPathComponent("Accommodation").appendingPathComponent("hello.txt"))
		} catch {
			present(error: error, title: "Unable to save file")
		}
    }

    func createFile(at fileURL: URL) {
        do {
            try "Cheese".write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
			present(error: error, title: "Failed to write to file")
        }
    }

}

extension ViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        guard urls.count == 1 else {
            present("Selected more than one directory")
            return
        }

        guard let directoryUrl = urls.first else {
            present("Unable to get directory URL")
            return
        }

        do {
            try StorageManager.setRootUrl(directoryUrl)
            destinationLabel.text = try? StorageManager.rootUrl().absoluteString
        } catch {
			present(error: error)
        }
    }

}
