//
//  FilePicker.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import MobileCoreServices
import SwiftUI
import UIKit

struct FilePickerSheet: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var documentTypes: [String]
    @Binding var url: URL?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {
        var parent: FilePickerSheet

        init(_ parent: FilePickerSheet) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            do {
                try url.prepareForSecureAccess()
            } catch {
                print("Failed to grant access")
                return
            }
            parent.url = url
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<FilePickerSheet>) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerSheet>) {

    }

}
