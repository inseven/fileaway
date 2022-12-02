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

import Interact

import FileawayCore

struct LocationsEditor: View {

    enum AlertType {
        case error(error: Error)
    }

    var name: String
    var type: DirectoryModel.DirectoryType
    @ObservedObject var applicationModel: ApplicationModel

    @Binding var directories: [DirectoryModel]

    @State var selection: UUID?
    @State var alertType: AlertType?

    init(applicationModel: ApplicationModel,
         name: String,
         type: DirectoryModel.DirectoryType,
         directories: Binding<Array<DirectoryModel>>) {
        self.name = name
        self.type = type
        self.applicationModel = applicationModel
        _directories = directories
    }

    func addLocation(type: DirectoryModel.DirectoryType, url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        do {
            try applicationModel.addLocation(type: type, url: url)
        } catch {
            alertType = .error(error: error)
        }
    }

    var body: some View {
        GroupBox(label: Text(name)) {
            HStack {
                List(selection: $selection) {
                    ForEach(directories) { directory in
                        HStack {
                            IconView(url: directory.url, size: CGSize(width: 16, height: 16))
                            Text(directory.name)
                        }
                        .contextMenu {
                            LocationMenuCommands(url: directory.url)
                        }
                    }
                    .onMove { (fromOffsets, toOffset) in
                        directories.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: Binding.constant(false)) { itemProviders in
                    for item in itemProviders {
                        _ = item.loadObject(ofClass: URL.self) { url, _ in
                            guard let url = url else {
                                return
                            }
                            DispatchQueue.main.async {
                                addLocation(type: type, url: url)
                            }
                        }
                    }
                    return true
                }
                VStack {
                    Button {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        openPanel.canCreateDirectories = true
                        guard openPanel.runModal() ==  NSApplication.ModalResponse.OK,
                              let url = openPanel.url else {
                            return
                        }
                        addLocation(type: type, url: url)
                    } label: {
                        Text("Add")
                            .frame(width: 80)
                    }
                    Button {
                        guard let directory = (applicationModel.inboxes + applicationModel.archives)
                            .first(where: { $0.id == selection }) else {
                            return
                        }
                        try? applicationModel.removeLocation(url: directory.url)
                    } label: {
                        Text("Remove")
                            .frame(width: 80)
                    }
                    .disabled(selection == nil)
                    Spacer()
                }
            }
            .padding(4)
        }
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .error(let error):
                return Alert(error: error)
            }
        }
    }

}

extension LocationsEditor.AlertType: Identifiable {
    public var id: String {
        switch self {
        case .error(let error):
            return "error-\(String(describing: error))"
        }
    }
}
