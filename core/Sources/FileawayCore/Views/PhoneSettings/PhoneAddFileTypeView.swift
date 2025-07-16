// Copyright (c) 2018-2025 Jason Morley
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

import SwiftUI
import UniformTypeIdentifiers

import Interact

public struct PhoneAddFileTypeView: View {

    public enum Focus: Hashable {
        case add
    }

    @Environment(\.dismiss) var dismiss

    @ObservedObject var model: FileTypesViewModel
    @FocusState private var focus: Focus?

    public init(model: FileTypesViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("File Extension", text: $model.newFilenameExtension)
                        .autocorrectionDisabled(true)
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                        .focused($focus, equals: .add)
                }
                Section {
                    if let proposedFileType = model.proposedFileType {
                        Button {
                            model.submit()
                            dismiss()
                        } label: {
                            LabeledContent(proposedFileType.localizedDisplayName,
                                           value: proposedFileType.preferredFilenameExtension ?? "")
                        }
                        .tint(.primary)
                    }
                }
            }
            .defaultFocus($focus, .add)
            .navigationTitle("Add File Type")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

            }
        }
    }

}
