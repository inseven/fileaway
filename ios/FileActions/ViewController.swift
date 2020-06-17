//
//  ViewController.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 07/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import MobileCoreServices

import FileActionsCore

class ViewController: UIViewController {

    @IBOutlet weak var destinationLabel: UILabel!

    private var manager: Manager!

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

    func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Picker" {

            guard let navigationController = segue.destination as? UINavigationController else {
                present("Unexpected view controller")
                return
            }
            guard let pickerViewController = navigationController.topViewController as? PickerViewController else {
                present("Unexpected view controller")
                return
            }
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                present("Unable to get app delegate")
                return
            }

            pickerViewController.manager = appDelegate.manager
            pickerViewController.documentUrl = Bundle.main.url(forResource: "example", withExtension: "pdf")!

        } else if segue.identifier == "Settings" {

            guard
                let navigationController = segue.destination as? UINavigationController,
                let settingsViewController = navigationController.topViewController as? SettingsViewController else {
                    present("Unexpected view controller")
                    return
            }

            settingsViewController.manager = manager
            settingsViewController.delegate = self

        }
    }

	// MARK: -

    @IBAction func setDestinationTapped(_ sender: Any) {
        presentDocumentPicker()
    }

    // TODO: Delete this.
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

extension ViewController: SettingsViewControllerDelegate {

    func settingsViewControllerDidFinish(_ controller: SettingsViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
