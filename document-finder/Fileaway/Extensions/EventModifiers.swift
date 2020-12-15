//
//  EventModifiers.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 12/12/2020.
//

import SwiftUI

extension EventModifiers {

    var modifierFlags: NSEvent.ModifierFlags {
        var modifierFlags = NSEvent.ModifierFlags()
        for eventModifier in Array(arrayLiteral: self) {
            switch eventModifier {
            case .capsLock:
                modifierFlags.insert(.capsLock)
            case .shift:
                modifierFlags.insert(.shift)
            case .control:
                modifierFlags.insert(.control)
            case .option:
                modifierFlags.insert(.option)
            case .command:
                modifierFlags.insert(.command)
            case .numericPad:
                modifierFlags.insert(.numericPad)
            case .function:
                modifierFlags.insert(.function)
            default:
                continue
            }
        }
        return modifierFlags
    }

}
