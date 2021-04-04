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
    var task: ReverseTask

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
                self.task.reverse(url: self.url!) { result in
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
                    Text("Save")
                        .bold()
                        .disabled(self.url == nil)
                }
            }))
            .navigationBarTitle("Reverse Pages", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .disabled(isProcessing)
    }

}
