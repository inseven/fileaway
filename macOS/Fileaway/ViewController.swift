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

    override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.dragDelegate = self
        do {
            tasks = try loadConfiguration()
        } catch {
            print("\(error)")
        }
        updateState()
    }

    func didDrop(url: URL) {
        self.documentURL = url
    }

    func loadConfiguration() throws -> [Task] {
        let data = try Data.init(contentsOf: URL(fileURLWithPath: DestinationsPath))
        let decoder = JSONDecoder()
        let configurations = try decoder.decode([String: Configuration].self, from: data)
        let tasks = configurations.map { (name, configuration) -> Task in
            return Task(name: name, configuration: configuration)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
    }

    func updateState() {
        let isRowSelected = tableView.selectedRow > -1
        let isDateSet = !dateTextField.stringValue.isEmpty
        actionButton.isEnabled = isRowSelected && isDateSet

        if isRowSelected {
            let task = tasks[tableView.selectedRow]
            nameTokenField.objectValue = task.configuration.destination.map({ $0.value })
        }
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
        let date = dateTextField.stringValue

        let destination = task.configuration.destination.reduce("") { (result, component) -> String in
            switch component.type {
            case .text:
                return result.appending(component.value)
            case .variable:
                return result.appending(date)
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

