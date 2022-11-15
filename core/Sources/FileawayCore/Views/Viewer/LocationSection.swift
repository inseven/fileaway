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

import SwiftUI

import FilePicker

public struct LocationSection: View {

    @Environment(\.applicationModel) private var applicationModel

#if os(iOS)
    @Environment(\.editMode) private var editMode
#endif

    @ObservedObject var sceneModel: SceneModel

    private var title: String
    private var type: DirectoryModel.DirectoryType

    // TODO: This is nasty
    public var models: [DirectoryViewModel] {
        switch type {
        case .inbox:
            return sceneModel.inboxes
        case .archive:
            return sceneModel.archives
        }
    }

    public init(sceneModel: SceneModel, title: String, type: DirectoryModel.DirectoryType) {
        self.sceneModel = sceneModel
        self.title = title
        self.type = type
    }

    public var body: some View {
        Section(title) {
            ForEach(models) { directoryViewModel in
                LocationRow(directoryViewModel: directoryViewModel)
            }
            .onDelete { indexSet in
                let urls = indexSet.map { models[$0].url }
                for url in urls {
                    // TODO: Handle the error here!
                    try! applicationModel.removeLocation(url: url)
                }
            }
#if os(iOS)
            if (editMode?.wrappedValue.isEditing ?? false) || models.isEmpty {
                Button("Add...") {
                    sceneModel.addLocation(type: type)
                }
            }
#endif
        }
    }

}
