//
//  VariableProvider.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 10/12/2020.
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
