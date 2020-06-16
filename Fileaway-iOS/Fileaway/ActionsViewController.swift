//
//  ActionsViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 16/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import MobileCoreServices
import SwiftUI
import UIKit

class Settings: ObservableObject {

    @Published var destination: String?

}

protocol ActionsViewDelegate: NSObject {

    func settingsTapped()
    func moveFileTapped()
    func moveExampleFileTapped()
    func setDestinationTapped()

}

struct ActionView: View {

    var text: String
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: imageName)
            }
        }.foregroundColor(.primary)
    }
}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings

    var body: some View {
        VStack {
            List {
                Section(footer: Text(settings.destination != nil ? "Files will be moved to '\(settings.destination!)'." : "No destination set.")) {
                    ActionView(text: "Move file...", imageName: "doc") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.moveFileTapped()
                    }
                }
                Section(header: Text("Debug".uppercased())) {
                    ActionView(text: "Move example file...", imageName: "doc") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.moveExampleFileTapped()
                    }
                    ActionView(text: "Set destination...", imageName: "folder") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.setDestinationTapped()
                    }
                }
            }.listStyle(GroupedListStyle())
        }.navigationBarTitle("File Actions")
            .navigationBarItems(leading: Button(action: {
                print("Settings tapped")
                guard let delegate = self.delegate else {
                    return
                }
                delegate.settingsTapped()
            }, label: {
                Text("Settings")
            }))
    }

}

extension String {

    var lastPathComponent: String {
        get {
            (self as NSString).lastPathComponent
        }
    }

}

class ActionsViewController: UIHostingController<ActionsView> {

    var settings: Settings = Settings()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ActionsView(settings: settings))
    }

    override func viewDidLoad() {
        self.rootView.delegate = self
        let rootUrl = try? StorageManager.rootUrl()
        let destination = rootUrl?.absoluteString
        settings.destination = destination?.lastPathComponent
    }

}


enum StoryboardIdentifier: String {
    case settings = "Settings"
    case picker = "PickerViewController"
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

    }

    func moveExampleFileTapped() {
        guard let pickerViewController = AppDelegate.shared.instantiateViewController(identifier: .picker) as? PickerViewController else {
            return
        }
        pickerViewController.manager = AppDelegate.shared.manager
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let exampleUrl = Bundle.main.url(forResource: "example", withExtension: "pdf")!
        let documentUrl = documentsDirectory.appendingPathComponent("example.url")
        try? FileManager.default.copyItem(at: exampleUrl, to: documentUrl)
        pickerViewController.documentUrl = documentUrl
        let navigationController = UINavigationController(rootViewController: pickerViewController)
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: true, completion: nil)
    }

    func setDestinationTapped() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

}

extension ActionsViewController: SettingsViewControllerDelegate {

    func settingsViewControllerDidFinish(_ controller: SettingsViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}

extension ActionsViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let directoryUrl = urls.first else {
            return
        }
        do {
            try StorageManager.setRootUrl(directoryUrl)
            settings.destination = (try? StorageManager.rootUrl().absoluteString)?.lastPathComponent
        } catch {
            settings.destination = nil
            present(error: error)
        }
    }

}
