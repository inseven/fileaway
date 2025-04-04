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

import Interact
import FilePicker

import FileawayCore

struct ContentView: View {

    @ObservedObject var applicationModel: ApplicationModel
    @StateObject var sceneModel: SceneModel

    init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
        _sceneModel = StateObject(wrappedValue: SceneModel(applicationModel: applicationModel))
    }

    var body: some View {

        NavigationSplitView {
            Sidebar(sceneModel: sceneModel)
                .navigationTitle("Folders")
                .toolbar {

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            sceneModel.showSettings()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }

                }
        } detail: {
            if let directoryViewModel = sceneModel.directoryViewModel {
                DirectoryView(directoryViewModel: directoryViewModel)
            } else {
                PlaceholderView("No Directory Selected")
                    .searchable()
            }
        }
        .sheet(item: $sceneModel.action) { action in
            switch action {
            case .settings:
                SettingsView(applicationModel: applicationModel, settings: applicationModel.settings)
            case .addLocation(let type):
                FilePickerUIRepresentable(types: [.folder], allowMultiple: false, asCopy: false) { urls in
                    guard let url = urls.first else {
                        return
                    }
                    // TODO: Handle the error here.
                    try! applicationModel.addLocation(type: type, url: url)
                }
            case .move(let files):
                WizardView(file: files.first!)
            case .editRules(let url):
                RulesView(rulesModel: RulesModel(archiveURL: url))
            }
        }
        .runs(sceneModel)
        .environmentObject(sceneModel)
        .focusedSceneObject(sceneModel)
    }

}
