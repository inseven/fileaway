//
//  AppDelegate.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 07/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import FileawayCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var manager: Manager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        manager = Manager()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if let rootUrl = try? StorageManager.rootUrl() {
            do {
                try FileManager.default.copyItem(at: url, to: rootUrl.appendingPathComponent("Adobe").appendingPathComponent("Example.pdf"))
            } catch let error {
                print(error)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

