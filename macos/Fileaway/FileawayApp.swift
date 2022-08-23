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
import UserNotifications

import Diligence
import FileawayCore

struct FocusedSelectionKey : FocusedValueKey {
    typealias Value = SelectionManager
}

extension FocusedValues {

    var selection: FocusedSelectionKey.Value? {
        get { self[FocusedSelectionKey.self] }
        set { self[FocusedSelectionKey.self] = newValue }
    }

}

struct VisualEffectView: NSViewRepresentable
{
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

@main
struct FileawayApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
        
        WindowGroup(id: "MainWindow") {
            ContentView(manager: appDelegate.manager)
                .environment(\.manager, appDelegate.manager)
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()
        }

        Wizard(manager: appDelegate.manager)

        SwiftUI.Settings {
            SettingsView(manager: appDelegate.manager)
        }

        About(copyright: Legal.copyright) {
            Legal.actions
        } acknowledgements: {
            Legal.acknowledgements
        } licenses: {
            Legal.licenses
        }

    }
}
