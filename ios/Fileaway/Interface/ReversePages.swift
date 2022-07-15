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
