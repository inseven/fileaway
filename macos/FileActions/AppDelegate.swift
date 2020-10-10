//
//  AppDelegate.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 01/06/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

import FileActionsCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    public var manager: Manager!

    static public var shared: AppDelegate {
        get {
            return NSApplication.shared.delegate as! AppDelegate
        }
    }

    override init() {
        super.init()
        let userDefaultsRoot = UserDefaults.standard.string(forKey: "root")!
        let rootUrl = URL(fileURLWithPath: NSString(string: userDefaultsRoot).expandingTildeInPath)
        let configurationUrl = rootUrl.appendingPathComponent("file-actions.json")
        manager = Manager(configurationUrl: configurationUrl)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        let viewController : ViewController = application.mainWindow?.contentViewController as! ViewController
        viewController.documentURL = urls.last
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}


