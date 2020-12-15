//
//  FileActions.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 03/12/2020.
//

import AppKit
import Foundation

class FileActions {

    static func open(urls: [URL]) {
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open(urls,
                                withApplicationAt: URL(fileURLWithPath: "/Applications/File Actions.app"),
                                configuration: configuration) { (application, error) in
            if let error = error {
                print(error)
            }
        }
    }

    static func open() {
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "/Applications/File Actions.app"),
                                           configuration: NSWorkspace.OpenConfiguration()) { (application, error) in
            if let error = error {
                print(error)
            }
        }
    }

    static func openiOS() {
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "/Applications/File Actions for iOS.app"),
                                           configuration: NSWorkspace.OpenConfiguration()) { (application, error) in
            if let error = error {
                print(error)
            }
        }
    }

}
