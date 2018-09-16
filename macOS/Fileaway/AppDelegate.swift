//
//  AppDelegate.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 01/06/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    public let manager = Manager()

    static public var shared: AppDelegate {
        get {
            return NSApplication.shared.delegate as! AppDelegate
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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


