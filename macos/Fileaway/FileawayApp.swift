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
import UserNotifications

import Glitter

import Diligence
import FileawayCore

@main
struct FileawayApp: App {

    var updaterModel = UpdaterModel()

    @StateObject var applicationModel = ApplicationModel()
    @FocusedValue(\.directoryViewModel) var directoryViewModel

    @Environment(\.scenePhase) private var phase

    func enableNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
            if let error = error {
                print("Failed to access notifications with error \(error)")
                return
            }
            print("User notification state \(granted)")
        }
    }

    init() {
        self.enableNotifications()
    }

    var body: some Scene {
        
        WindowGroup(id: "main") {
            ContentView(applicationModel: applicationModel)
                .environmentObject(applicationModel)
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()
            FileCommands(directoryViewModel: directoryViewModel)
            FolderCommands(applicationModel: applicationModel)
            UpdateCommands(updater: updaterModel.updaterController.updater)
        }

        Wizard(applicationModel: applicationModel)

        SwiftUI.Settings {
            SettingsView(applicationModel: applicationModel)
                .environmentObject(applicationModel)
        }

        About(Legal.contents)

    }
}
