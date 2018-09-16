//
//  ViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 01/06/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController, DragDelegate {

    static let DefaultIdentifier = "Cell"

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var pdfView: DraggablePDFView!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var nameTokenField: NSTokenField!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var targetTextField: NSTextField!

    var manager: Manager!

    var documentURL: URL? {
        didSet {
            pdfView.document = PDFDocument(url: documentURL!)
        }
    }

    var variableView: VariableView?

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
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = AppDelegate.shared.manager
        pdfView.dragDelegate = self
        updateState()
    }

    func didDrop(url: URL) {
        self.documentURL = url
    }

    func updateState() {
        let isRowSelected = tableView.selectedRow > -1
        let isComplete = variableView?.isComplete ?? false
        actionButton.isEnabled = isRowSelected && isComplete
        guard let variableView = variableView else {
            return
        }
        targetTextField.stringValue = DestinationURL(manager.task(forIndex: tableView.selectedRow), variableProvider: variableView).path
    }

    @IBAction func moveClicked(_ sender: Any) {

        guard
            let sourceURL: URL = documentURL,
            let variableView = variableView else {
                return
        }

        let task = manager.task(forIndex: tableView.selectedRow)
        let destinationURL = DestinationURL(task, variableProvider: variableView)

        print("\(destinationURL)")

        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            print("\(error)")
            return
        }

        self.view.window?.close()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else {
            return
        }

        switch (identifier) {
        case .preferences:
            guard let preferencesViewController = segue.destinationController as? PreferencesViewController else {
                return
            }
            preferencesViewController.manager = manager
            return
        default:
            return
        }
    }

}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return manager.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: ViewController.DefaultIdentifier)
        guard let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView else {
            return nil
        }
        cell.textField?.stringValue = manager.task(forIndex: row).name
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        task = manager.task(forIndex: tableView.selectedRow)
        updateState()
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
