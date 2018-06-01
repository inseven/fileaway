//
//  ViewController.swift
//  OTTH
//
//  Created by Jason Barrie Morley on 01/06/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import Quartz

let DestinationsPath = "/Users/jbmorley/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/destinations.json"

struct Destination: Codable {
    enum CodingKeys: String, CodingKey {
        case path = "Path"
        case name = "Name"
    }
    let path: String
    let name: String
}

struct Task {
    let name: String
    let destination: Destination
}

class ViewController: NSViewController {

    static let DefaultIdentifier = "Cell"

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var fileTextField: NSTextField!
    @IBOutlet weak var pdfView: PDFView!
    
    var documentURL: URL? {
        didSet {
            fileTextField.stringValue = (documentURL?.absoluteString)!
            pdfView.document = PDFDocument(url: documentURL!)
        }
    }
    
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            tasks = try loadConfiguration()
        } catch {
            print("\(error)")
        }
    }

    func loadConfiguration() throws -> [Task] {
        let data = try Data.init(contentsOf: URL(fileURLWithPath: DestinationsPath))
        let decoder = JSONDecoder()
        let destinations = try decoder.decode([String: Destination].self, from: data)
        let tasks = destinations.map { (name, destination) -> Task in
            return Task(name: name, destination: destination)
            }.sorted { (task0, task1) -> Bool in
                return task0.name < task1.name
        }
        return tasks
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
        let name = "\(date) \(task.destination.name)"
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let destinationURL = homeDirectory.appendingPathComponent(task.destination.path).appendingPathComponent(name).appendingPathExtension("pdf")
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

}

