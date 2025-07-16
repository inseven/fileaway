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

public struct PhoneFileTypesView: View {

    enum SheetType: Identifiable {

        var id: Self { self }

        case add
    }

    @StateObject var model: FileTypesViewModel
    @State var sheet: SheetType?

    public init(settings: Settings) {
        _model = StateObject(wrappedValue: FileTypesViewModel(settings: settings))
    }

    public var body: some View {
        List {
            ForEach(model.fileTypes) { fileType in
                LabeledContent(fileType.localizedDisplayName, value: fileType.preferredFilenameExtension ?? "")
            }
            .onDelete { indexSet in
                model.remove(indexSet)
            }
        }
        .navigationTitle("File Types")
        .toolbar {

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    sheet = .add
                } label: {
                    Label("Add File Type", systemImage: "plus")
                }
            }

        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .add:
                PhoneAddFileTypeView(model: model)
            }
        }
        .runs(model)
    }

}
