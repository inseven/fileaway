//
//  Component.swift
//  FileawayCore
//
//  Created by Jason Barrie Morley on 18/05/2021.
//  Copyright © 2021 InSeven Limited. All rights reserved.
//

import Foundation

public struct Component: Codable {
    public let type: ComponentType
    public let value: String

    public init(type: ComponentType, value: String) {
        self.type = type
        self.value = value
    }
}
