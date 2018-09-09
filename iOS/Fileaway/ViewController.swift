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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func safeFileTapped(_ sender: Any) {

        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get Documents directory")
            return
        }

        createFile(at: directory.appendingPathComponent("example.txt"))


        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.allowsMultipleSelection = true  // We require multiple selection to let the user select a folder.
        documentPicker.delegate = self
        self.present(documentPicker, animated: true) {
            print("Did Present")
        }

    }

    func createFile(at fileURL: URL) {
        do {
            try "Cheese".write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write to file")
        }
    }

}

extension ViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        guard urls.count == 1 else {
            print("Selected more than one directory")
            return
        }

        guard let directoryURL = urls.first else {
            print("Unable to get directory URL")
            return
        }

        print(directoryURL)

        guard directoryURL.startAccessingSecurityScopedResource() else {
            print("Unable to access security scoped resource.")
            return
        }

        let fileManager = FileManager.default

        guard fileManager.isReadableFile(atPath: directoryURL.path) else {
            print("Unable to read directory at path")
            return
        }

        guard let contents = try? fileManager.contentsOfDirectory(atPath: directoryURL.path) else {
            print("Unable to list directory")
            return
        }

        print(contents)

        createFile(at: directoryURL.appendingPathComponent("cheese.txt"))

    }

}
