//
//  FakeDuplexView.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation

import MobileCoreServices
import SwiftUI

struct FakeDuplexView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var url1: URL?
    @State private var url2: URL?
    @State private var isProcessing = false
    @State private var error: Error?
    var task: FakeDuplexTask

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(footer: Text(self.error != nil ? String(describing: error!) : "").foregroundColor(.red)) {
                        FilePicker(placeholder: "Select file...", documentTypes: [kUTTypePDF as String], url: $url1).lineLimit(1)
                        FilePicker(placeholder: "Select file...", documentTypes: [kUTTypePDF as String], url: $url2).lineLimit(1)
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
                self.task.perform(url1: self.url1!, url2: self.url2!, output:  self.url1!) { result in
                    self.isProcessing = false
                    switch result {
                    case .success:
                        self.error = nil
                        self.presentationMode.wrappedValue.dismiss()
                    case .failure(let error):
                        self.error = error
                    }
                }
            }, label: {
                if isProcessing {
                    ActivityIndicator(isAnimating: $isProcessing, style: .medium)
                } else {
                    Text("Save").disabled(self.url1 == nil || self.url2 == nil)
                }
            }))
            .navigationBarTitle("Reverse Pages", displayMode: .inline)
        }
        .disabled(isProcessing)
    }

}
