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

import FilePicker

import FileawayCore

import UniformTypeIdentifiers

struct FileChooser: View {

    let placeholder: String
    let types: [UTType]
    @Binding var url: URL?

    init(_ placeholder: String, types: [UTType], url: Binding<URL?>) {
        self.placeholder = placeholder
        self.types = types
        _url = url
    }

    var body: some View {
        FilePicker(types: types, allowMultiple: false, asCopy: false) { urls in
            guard let url = urls.first else {
                return
            }
            do {
                try url.prepareForSecureAccess()
                self.url = url
            } catch {
                print("Failed to prepare URL for secure access with error \(error).")
            }
        } label: {
            if let url = url {
                Text(url.displayName)
                    .lineLimit(1)
            } else {
                Text(placeholder)
            }
        }
    }

}
