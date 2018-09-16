//
//  Configuration.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

struct Configuration: Codable {
    let variables: [Variable]
    let destination: [Component]
}

enum ComponentType: String, Codable {
    case text = "text"
    case variable = "variable"
}

struct Component: Codable {
    let type: ComponentType
    let value: String
}

enum VariableType: String, Codable {
    case string = "string"
}

struct Variable: Codable {
    let name: String
    let type: VariableType
}

struct Task {
    let name: String
    let configuration: Configuration
}

func DestinationURL(_ task: Task, variableProvider: VariableProvider) -> URL {
    let destination = task.configuration.destination.reduce("") { (result, component) -> String in
        switch component.type {
        case .text:
            return result.appending(component.value)
        case .variable:
            guard let value = variableProvider.variable(forKey: component.value) else {
                return result
            }
            return result.appending(value)
        }
    }
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
    let documentsDirectory = homeDirectory.appendingPathComponent("Documents")
    let destinationURL = documentsDirectory.appendingPathComponent(destination).appendingPathExtension("pdf")
    return destinationURL
}
