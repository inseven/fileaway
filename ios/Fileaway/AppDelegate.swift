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

import UIKit

import FileawayCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public let settings = Settings()

    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

