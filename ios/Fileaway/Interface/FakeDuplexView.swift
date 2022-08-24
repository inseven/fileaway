// Copyright (c) 2018-2022 InSeven Limited
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
                    Section(footer: ErrorText(text: self.error?.localizedDescription)) {
                        FilePicker(placeholder: "Select file...", documentTypes: [.pdf], url: $url1).lineLimit(1)
                        FilePicker(placeholder: "Select file...", documentTypes: [.pdf], url: $url2).lineLimit(1)
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
                    Text("Save")
                        .bold()
                        .disabled(self.url1 == nil || self.url2 == nil)
                }
            }))
            .navigationBarTitle("Fake Duplex", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .disabled(isProcessing)
    }

}
