//
//  ReversePages.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import MobileCoreServices
import SwiftUI

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
