//
//  VariableView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

protocol VariableProviderDelegate {
    func variableProviderDidUpdate(variableProvider: VariableProvider)
}

protocol VariableProvider {
    func variable(forKey key: String) -> String?
    var isComplete: Bool { get }
    var delegate: VariableProviderDelegate? { get set }
}

class VariableView: NSView, VariableProvider {

    var textFields: [String: NSTextField]
    var delegate: VariableProviderDelegate?

    public var isComplete: Bool {
        get {
            return textFields.values.reduce(true, { (result, textField) -> Bool in
                return result && !textField.stringValue.isEmpty
            })
        }
    }

    public init(variables: [Variable]) {
        self.textFields = [:]
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        var currentTopAnchor = topAnchor

        for variable in variables {

            let labelTextField = NSTextField(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            labelTextField.translatesAutoresizingMaskIntoConstraints = false
            labelTextField.isEditable = false
            labelTextField.stringValue = variable.name
            labelTextField.isBordered = false

            let valueTextField = NSTextField(frame: CGRect(x: 50, y: 0, width: 50, height: 20))
            valueTextField.translatesAutoresizingMaskIntoConstraints = false
            valueTextField.delegate = self

            addSubview(labelTextField)
            addSubview(valueTextField)

            labelTextField.topAnchor.constraint(equalTo: currentTopAnchor).isActive = true
            valueTextField.topAnchor.constraint(equalTo: currentTopAnchor).isActive = true

            labelTextField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            labelTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
            valueTextField.leadingAnchor.constraint(equalTo: labelTextField.trailingAnchor).isActive = true
            valueTextField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

            textFields[variable.name] = valueTextField

            currentTopAnchor = labelTextField.bottomAnchor
        }
    }

    func variable(forKey key: String) -> String? {
        return textFields[key]?.stringValue
    }

    required init?(coder decoder: NSCoder) {
        self.textFields = [:]
        super.init(coder: decoder)
    }

}

extension VariableView: NSControlTextEditingDelegate, NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.delegate?.variableProviderDidUpdate(variableProvider: self)
    }

}
