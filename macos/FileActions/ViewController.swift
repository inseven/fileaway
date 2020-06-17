//
//  ViewController.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 01/06/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import Quartz

import FileActionsCore

class ViewController: NSViewController, DragDelegate {

    static let DefaultIdentifier = "Cell"

    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var pdfView: DraggablePDFView!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var nameTokenField: NSTokenField!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var targetTextField: NSTextField!
    @IBOutlet weak var popUpButton: NSPopUpButton!

    var manager: Manager!

    var documentURL: URL? {
        didSet {
            pdfView.document = PDFDocument(url: documentURL!)
            let attributes = try! FileManager.default.attributesOfItem(atPath: documentURL!.path)
            date = attributes[FileAttributeKey.creationDate]! as? Date
            updateState()
        }
    }

    var date: Date? {
        didSet {
            guard let date = date else {
                return
            }
            if let variableView = self.variableView {
                variableView.setDate(date: date)
            }
        }
    }

    var rootURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    var variableView: VariableView? {
        didSet {
            guard let variableView = variableView, let date = date else {
                return
            }
            variableView.setDate(date: date)
        }
    }

    var task: Task? {
        didSet {
            // Remove the existing variable view.
            if let variableView = self.variableView {
                variableView.removeFromSuperview()
                self.variableView = nil
            }
            // Guard against an empty selection.
            guard let task = task else {
                return
            }
            // Add a new one if a task has been selected.
            nameTokenField.objectValue = task.configuration.destination
            let variablesView = VariableView(variables: task.configuration.variables)
            variablesView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            variablesView.delegate = self
            variablesView.frame = containerView.bounds
            containerView.addSubview(variablesView)
            self.variableView = variablesView

            updateState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = AppDelegate.shared.manager
        popUpButton.removeAllItems()
        popUpButton.addItems(withTitles: manager.tasks.map({ $0.name }))
        pdfView.dragDelegate = self
        updateState()
    }

    func didDrop(url: URL) {
        self.documentURL = url
    }

    func updateState() {

        // Update the button selection state.
        let isTaskSelected = task != nil
        let isComplete = variableView?.isComplete ?? false
        let isFile = pdfView.document != nil
        actionButton.isEnabled = isTaskSelected && isComplete && isFile

        // Update the detail destination string.
        guard let variableView = variableView, let task = task else {
            targetTextField.stringValue = ""
                return
        }
        targetTextField.stringValue = manager.destinationUrl(task, variableProvider: variableView, rootUrl: self.rootURL).path
    }

    @IBAction func popUpButtonAction(_ sender: Any) {
        guard let manager = manager else {
            return
        }
        task = manager.tasks[popUpButton.indexOfSelectedItem]
    }

    @IBAction func moveClicked(_ sender: Any) {

        guard
            let sourceURL: URL = documentURL,
            let variableView = variableView,
            let task = task else {
                return
        }

        let destinationURL = manager.destinationUrl(task, variableProvider: variableView, rootUrl: self.rootURL)
        print("\(destinationURL)")

        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
            print("\(error)")
            return
        }

        self.view.window?.close()
    }

}

extension ViewController: NSControlTextEditingDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        updateState()
    }

}

extension ViewController: NSTokenFieldDelegate {

    func tokenField(_ tokenField: NSTokenField, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
        guard let component = representedObject as? Component else {
            return .none
        }
        switch component.type {
        case .text:
            return .none
        case .variable:
            return .squared
        }
    }

    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        guard let component = representedObject as? Component else {
            return ""
        }
        return component.value
    }

}

extension ViewController: VariableProviderDelegate {

    func variableProviderDidUpdate(variableProvider: VariableProvider) {
        updateState()
    }

}
