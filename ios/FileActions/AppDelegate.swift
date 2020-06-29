//
//  AppDelegate.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 07/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit

import FileActionsCore

extension UIApplication {

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public let settings = Settings()

    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window?.tintColor = #colorLiteral(red: 1, green: 0.4940795302, blue: 0.4728332758, alpha: 1)
        return true
    }

    func instantiateViewController(identifier: StoryboardIdentifier) -> UIViewController? {
        guard
            let rootViewController = window?.rootViewController,
            let storyboard = rootViewController.storyboard else {
                return nil
        }
        return storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let rootViewController = window?.rootViewController else {
            print("Unable to get the root view controller")
            return false
        }
        guard let storyboard = rootViewController.storyboard else {
            rootViewController.present("Unable to get the storyboard")
            return false
        }
        guard let pickerViewController = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as? PickerViewController else {
            rootViewController.present("Unable to instantiate the picker view controller")
            return false
        }
        // TODO: Double check that this is a PDF!
        pickerViewController.manager = settings.manager!
        do {
            try url.prepareForSecureAccess()
        } catch {
			rootViewController.present(error: error, title: "Unable to prepare for secure access")
            return false
        }
        pickerViewController.documentUrl = url
        let navigationController = UINavigationController(rootViewController: pickerViewController)
        navigationController.modalPresentationStyle = .formSheet
        rootViewController.present(navigationController, animated: true, completion: nil)
        return true

//        // Example code showing how the move operation can be performed once a root has been set.
//        if let rootUrl = try? StorageManager.rootUrl() {
//            do {
//                try FileManager.default.copyItem(at: url, to: rootUrl.appendingPathComponent("Adobe").appendingPathComponent("Example.pdf"))
//            } catch let error {
//                print(error)
//            }
//        }
//        return true
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

