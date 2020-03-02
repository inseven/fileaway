//
//  VariableView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 14/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import FileawayCore

let StandardSpacing: CGFloat = 8.0

protocol VariableControl {
    func componentValue() -> String
}

extension NSTextField: VariableControl {

    func componentValue() -> String {
        return stringValue
    }

}

extension NSDatePicker: VariableControl {

    func componentValue() -> String {
        if datePickerElements == .yearMonthDatePickerElementFlag {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM"
            return dateFormatter.string(from: dateValue)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: dateValue)
    }

}

class VariableView: NSView, VariableProvider {

    var textFields: [String: NSControl & VariableControl]
    var delegate: VariableProviderDelegate?

    public var isComplete: Bool {
        get {
            return textFields.values.reduce(true, { (result, textField) -> Bool in
                return result && !textField.stringValue.isEmpty
            })
        }
    }

    static func label(name: String) -> NSTextField {
        let labelTextField = NSTextField(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        labelTextField.translatesAutoresizingMaskIntoConstraints = false
        labelTextField.isEditable = false
        labelTextField.stringValue = name.appending(":")
        labelTextField.isBordered = false
        labelTextField.drawsBackground = false
        labelTextField.isSelectable = false
        labelTextField.alignment = .right
        return labelTextField
    }

    func textControl() -> NSTextField {
        let textField = NSTextField(frame: CGRect(x: 50, y: 0, width: 50, height: 20))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }

    func dateControl(hasDay: Bool) -> NSDatePicker {
        let datePicker = NSDatePicker(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerStyle = .textFieldAndStepperDatePickerStyle
        datePicker.datePickerElements = hasDay
            ? .yearMonthDayDatePickerElementFlag
            : .yearMonthDatePickerElementFlag
        datePicker.dateValue = Date()
        datePicker.target = self
        datePicker.action = #selector(VariableView.didChange(_:))
        return datePicker
    }

    @objc func didChange(_ sender: Any) {
        updateDelegate()
    }

    public init(variables: [Variable]) {
        self.textFields = [:]
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        var currentTopAnchor = topAnchor
        var previousLabelTextField: NSTextField? = nil
        var previousValueTextField: NSControl? = nil

        for variable in variables {

            // Create the appropriate controls.
            let labelTextField = VariableView.label(name: variable.name)
            var valueControl: (NSControl & VariableControl)?
            switch variable.type {
            case .string:
                valueControl = textControl()
                break
            case .date(let hasDay):
                valueControl = dateControl(hasDay: hasDay)
                break
            }
            guard let control = valueControl else {
                print("Unable to create control for variable \(variable).")
                return
            }

            // Add the views.
            addSubview(labelTextField)
            addSubview(control)

            // Set up the constraints.
            labelTextField.topAnchor.constraint(equalTo: currentTopAnchor, constant: StandardSpacing).isActive = true
            control.topAnchor.constraint(equalTo: currentTopAnchor, constant: StandardSpacing).isActive = true
            if let previousLabelTextField = previousLabelTextField {
                labelTextField.widthAnchor.constraint(equalTo: previousLabelTextField.widthAnchor).isActive = true
            }
            labelTextField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            control.leadingAnchor.constraint(equalTo: labelTextField.trailingAnchor, constant: StandardSpacing).isActive = true
            control.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

            textFields[variable.name] = control

            currentTopAnchor = labelTextField.bottomAnchor

            // Fix up the responder chain.
            if let previousValueTextField = previousValueTextField {
                previousValueTextField.nextKeyView = valueControl
            }

            previousLabelTextField = labelTextField
            previousValueTextField = control
            
        }
    }

    func variable(forKey key: String) -> String? {
        return textFields[key]?.componentValue()
    }

    required init?(coder decoder: NSCoder) {
        self.textFields = [:]
        super.init(coder: decoder)
    }

    func updateDelegate() {
        self.delegate?.variableProviderDidUpdate(variableProvider: self)
    }

    func setDate(date: Date) {
        for (_, control) in self.textFields {
            if let datePicker = control as? NSDatePicker {
                datePicker.dateValue = date
            }
        }
    }

}

extension VariableView: NSControlTextEditingDelegate, NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        updateDelegate()
    }

}
