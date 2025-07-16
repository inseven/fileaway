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

#if canImport(Glitter)
import Glitter
#endif

import Diligence
import FileawayCore

@main
struct FileawayApp: App {
    
#if canImport(Sparkle)
    var updaterModel = UpdaterModel()
#endif
    
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
#if os(iOS)
        // We only need to request notification permission on iOS; macOS lets us badge the app icon without this.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge]) { success, error in }
#else
        self.enableNotifications()
#endif
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
#if canImport(Glitter)
            UpdateCommands(updater: updaterModel.updaterController.updater)
#endif
        }
        
#if os(macOS)
        
        Wizard(applicationModel: applicationModel)
        
        SwiftUI.Settings {
            SettingsView(applicationModel: applicationModel)
                .environmentObject(applicationModel)
        }
        
        About(Legal.contents)
        
#endif
        
    }
}
