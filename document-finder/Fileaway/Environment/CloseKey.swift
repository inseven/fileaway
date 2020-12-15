//
//  CloseKey.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 14/12/2020.
//

import SwiftUI

struct CloseKey: EnvironmentKey {
    static var defaultValue: () -> Void = {
        NSApplication.shared.keyWindow?.close()
    }
}

extension EnvironmentValues {

    var close: () -> Void {
        get { self[CloseKey.self] }
        set { self[CloseKey.self] = newValue }
    }

}
