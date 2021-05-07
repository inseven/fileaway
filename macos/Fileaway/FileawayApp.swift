//
//  Document_FinderApp.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 01/12/2020.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {

    var manager = Manager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Did finish launching")
        manager.start()
    }

}

struct FocusedSelectionKey : FocusedValueKey {
    typealias Value = Binding<Set<URL>>
}

struct FocusedIntKey : FocusedValueKey {
    typealias Value = Binding<Int>
}

extension FocusedValues {

    var selection: FocusedSelectionKey.Value? {
        get { self[FocusedSelectionKey.self] }
        set { self[FocusedSelectionKey.self] = newValue }
    }

    var item: FocusedIntKey.Value? {
        get { self[FocusedIntKey.self] }
        set { self[FocusedIntKey.self] = newValue }
    }

}

struct GlobalCommands: Commands {

    @FocusedBinding(\.item) var item: Int?

    var body: some Commands {
        ToolbarCommands()
        SidebarCommands()
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
                .frameAutosaveName("Main Window")
        }
        .commands {
            GlobalCommands()
        }
        .onChange(of: phase) { phase in
            switch phase {
            case .active:
                print("app state active")
            case .background:
                print("app state background")
            case .inactive:
                print("app state inactive")
            @unknown default:
                print("app state unknown")
            }
        }
        WindowGroup("Wizard") {
            RulesWizard()
                .environment(\.manager, appDelegate.manager)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
                .background(VisualEffectView(material: NSVisualEffectView.Material.sidebar,
                                             blendingMode: NSVisualEffectView.BlendingMode.behindWindow)
                                .edgesIgnoringSafeArea(.all))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        SwiftUI.Settings {
            SettingsView(manager: appDelegate.manager)
        }
    }
}
