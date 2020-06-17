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

class Settings: ObservableObject {

    @Published var destination: String?

}

enum FilePickerError: Error {
    case failed
}

protocol ActionsViewDelegate: NSObject {

    func settingsTapped()
    func moveFileTapped()
    func setDestinationTapped()
    func reversePages(url: URL, completion: @escaping (Error?) -> Void)

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

struct FilePicker: View {

    @State private var showingFilePicker = false
    let placeholder: String
    let documentTypes: [String]
    @Binding var url: URL?

    var body: some View {
        Button(action: {
            self.showingFilePicker = true
        }) {
            if url == nil {
                Text(placeholder)
            } else {
                Text(url!.lastPathComponent)
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            FilePickerSheet(documentTypes: self.documentTypes, url: self.$url)
        }
    }

}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(activityIndicatorStyle: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ReversePages: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var url: URL?
    @State private var isProcessing = false
    @State private var error: Error?
    var action: (URL, @escaping (Error?) -> Void) -> Void

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(footer: Text(self.error != nil ? String(describing: error!) : "").foregroundColor(.red)) {
                        FilePicker(placeholder: "Select file...", documentTypes: [kUTTypePDF as String], url: $url).lineLimit(1)
                    }
                }
            }
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                self.error = nil
                self.isProcessing = true
                self.action(self.url!) { error in
                    self.isProcessing = false
                    self.error = error
                    if error == nil {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }, label: {
                if isProcessing {
                    ActivityIndicator(isAnimating: $isProcessing, style: .medium)
                } else {
                    Text("Save").disabled(self.url == nil)
                }
            }))
            .navigationBarTitle("Reverse Pages", displayMode: .inline)
        }
        .disabled(isProcessing)
    }

}

struct ActionsView: View {

    weak var delegate: ActionsViewDelegate?
    @ObservedObject var settings: Settings
    @State private var displayModal = false

    var body: some View {
        VStack {
            List {
                Section(footer: Text(settings.destination != nil ? "Files will be moved to '\(settings.destination!)'." : "No destination set.")) {
                    ActionView(text: "Move file...", imageName: "folder") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.moveFileTapped()
                    }
                    ActionView(text: "Reverse pages...", imageName: "doc.on.doc") {
                        self.displayModal = true
                    }
                }
                Section(header: Text("Debug".uppercased())) {
                    ActionView(text: "Set destination...", imageName: "folder") {
                        guard let delegate = self.delegate else {
                            return
                        }
                        delegate.setDestinationTapped()
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .sheet(isPresented: $displayModal) {
            ReversePages { url, completion in
                guard let delegate = self.delegate else {
                    return
                }
                delegate.reversePages(url: url, completion: completion)
            }
        }
        .navigationBarTitle("File Actions")
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
    case pickerNavigationController = "PickerNavigationController"
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

    func setDestinationTapped() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
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
