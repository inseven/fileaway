//
//  ViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 01/06/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import Quartz

let DestinationsPath = "/Users/jbmorley/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/destinations.json"

class ViewController: NSViewController, DragDelegate {

    static let DefaultIdentifier = "Cell"

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var pdfView: DraggablePDFView!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var nameTokenField: NSTokenField!

    var documentURL: URL? {
        didSet {
            pdfView.document = PDFDocument(url: documentURL!)
        }
    }
    
    var tasks: [Task] = []
    var variablesView: VariablesView?
    var task: Task? {
        didSet {
            // Remove the existing variable view.
            if let variablesView = self.variablesView {
                variablesView.removeFromSuperview()
                self.variablesView = nil
            }
            // Add a new one if a task has been selected.
            guard let task = task else {
                return
            }
            nameTokenField.objectValue = task.configuration.destination.map({ $0.value })
            let variablesView = VariablesView(variables: task.configuration.variables)
            variablesView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            variablesView.delegate = self
            view.addSubview(variablesView)
            self.variablesView = variablesView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.dragDelegate = self
        do {
            tasks = try Task.load(DestinationsPath)
        } catch {
            print("\(error)")
        }
        updateState()
    }

    func didDrop(url: URL) {
        self.documentURL = url
    }

    func updateState() {
        let isRowSelected = tableView.selectedRow > -1
        let isComplete = variablesView?.isComplete ?? false
        actionButton.isEnabled = isRowSelected && isComplete
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func moveClicked(_ sender: Any) {

        guard let sourceURL: URL = documentURL else {
            return
        }

        let task = tasks[tableView.selectedRow]
        let destination = task.configuration.destination.reduce("") { (result, component) -> String in
            switch component.type {
            case .text:
                return result.appending(component.value)
            case .variable:
                guard let value = variablesView?.variable(forKey: component.value) else {
                    return result
                }
                return result.appending(value)
            }
        }

        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let documentsDirectory = homeDirectory.appendingPathComponent("Documents")
        let destinationURL = documentsDirectory.appendingPathComponent(destination).appendingPathExtension("pdf")
        print("\(destinationURL)")

        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            print("\(error)")
        }

        self.view.window?.close()
    }

}

extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return tasks.count
    }

}

extension ViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: ViewController.DefaultIdentifier)
        guard let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView else {
            return nil
        }

        cell.textField?.stringValue = tasks[row].name
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        task = tasks[tableView.selectedRow]
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
        guard let stringObject = representedObject as? String else {
            return .none
        }
        if stringObject == "Date" {
            return .squared
        }
        return .none
    }

}

extension ViewController: VariableProviderDelegate {

    func variableProviderDidUpdate(variableProvider: VariableProvider) {
        updateState()
    }
}
