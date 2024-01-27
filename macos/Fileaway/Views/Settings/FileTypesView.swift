// Copyright (c) 2018-2024 Jason Morley
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

import Combine
import SwiftUI
import UniformTypeIdentifiers

import Interact

import FileawayCore

struct FileTypesView: View {

    @StateObject var model: FileTypesViewModel

    init(settings: FileawayCore.Settings) {
        _model = StateObject(wrappedValue: FileTypesViewModel(settings: settings))
    }

    var body: some View {
        GroupBox("File Types") {
            VStack {
                List(selection: $model.selection) {
                    ForEach(model.fileTypes) { type in
                        HStack {
                            Text(type.localizedDisplayName)
                            Spacer()
                            if let preferredFilenameExtension = type.preferredFilenameExtension {
                                Text(preferredFilenameExtension)
                                    .foregroundColor(.secondary)
                            } else if let preferredMIMEType = type.preferredMIMEType {
                                Text(preferredMIMEType)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .lineLimit(1)
                    }
                }
                .contextMenu(forSelectionType: UTType.ID.self) { selection in
                    Button("Remove") {
                        model.remove(selection)
                    }
                }
                .onDeleteCommand {
                    model.remove(model.selection)
                }
                HStack {
                    TextField("File Extension", text: $model.newFilenameExtension)
                        .onSubmit {
                            model.submit()
                        }
                    Button("Add") {
                        model.submit()
                    }
                    .disabled(!model.canSubmit)
                }
            }
        }
        .runs(model)
    }

}
