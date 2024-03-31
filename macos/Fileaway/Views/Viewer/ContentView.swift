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

import Interact

import FileawayCore

struct ContentView: View {

    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.directoryViewModel) var directoryViewModel

    @ObservedObject var applicationModel: ApplicationModel
    @StateObject var sceneModel: SceneModel

    init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
        _sceneModel = StateObject(wrappedValue: SceneModel(applicationModel: applicationModel))
    }

    var body: some View {
        NavigationSplitView {
            Sidebar(sceneModel: sceneModel)
        } detail: {
            if let directoryViewModel = sceneModel.directoryViewModel {
                DirectoryView(directoryViewModel: directoryViewModel)
            } else {
                PlaceholderView("No Directory Selected")
                    .searchable()
            }
        }
        .toolbar(id: "main") {
            SelectionToolbar(directoryViewModel: directoryViewModel)
        }
        .runs(sceneModel)
        .environmentObject(sceneModel)
        .focusedSceneObject(sceneModel)
        .onChange(of: sceneModel.action) { _, action in
            // macOS treats actions as a stream of operation requests.
            // This allows us to open windows instead of presenting sheets as we do on iOS.
            guard let action = action else {
                return
            }
            switch action {
            case .move(let files):
                for file in files {
                    openWindow(id: Wizard.windowID, value: file.url)
                }
            default:
                assertionFailure("Unsupported scene action \(String(describing: action))")
            }
            sceneModel.action = nil
        }
    }
}
