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

@main
struct Document_FinderApp: App {

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
        WindowGroup {
            ContentView(manager: appDelegate.manager)
        }
        .commands {
            CommandGroup(after: .systemServices) {
                Divider()
                Button {
                    FileActions.open()
                } label: {
                    Text("File Actions...")
                }
                Button {
                    FileActions.openiOS()
                } label: {
                    Text("File Actions for iOS...")
                }

            }
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
    }
}
