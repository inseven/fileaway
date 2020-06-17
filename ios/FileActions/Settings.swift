//
//  Settings.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 17/06/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import Foundation

class Settings: ObservableObject {

    @Published var destination: URL? {
        didSet {
            guard let url = destination else {
                return
            }
            do {
                try StorageManager.setRootUrl(url)
            } catch {
                print("Failed to set destination to \(url).")
            }
        }
    }

    init() {
        destination = try? StorageManager.rootUrl()
    }

}
