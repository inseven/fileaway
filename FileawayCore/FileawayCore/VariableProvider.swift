//
//  VariableProvider.swift
//  FileawayCore
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Foundation

public protocol VariableProviderDelegate {
    func variableProviderDidUpdate(variableProvider: VariableProvider)
}

public protocol VariableProvider {
    func variable(forKey key: String) -> String?
    var isComplete: Bool { get }
    var delegate: VariableProviderDelegate? { get set }
}
