//
//  PreferencesViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/09/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import FileawayCore

extension NSStoryboardSegue.Identifier {

    static let preferences = NSStoryboardSegue.Identifier("Preferences")

}

class PreferencesViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    var manager: Manager? {
        didSet {
            guard let tableView = tableView else {
                return
            }
            tableView.reloadData()
        }
    }

    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = AppDelegate.shared.manager
    }

    @IBAction func doneClicked(_ sender: Any) {
        self.dismiss(self)
    }

}

extension PreferencesViewController: NSTableViewDataSource, NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let manager = manager else {
            return 0
        }
        return manager.tasks.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let manager = manager else {
            return nil
        }
        let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: ViewController.DefaultIdentifier)
        guard let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView else {
            return nil
        }
        cell.textField?.stringValue = manager.tasks[row].name
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let manager = manager else {
            task = nil
            return
        }
        task = manager.tasks[tableView.selectedRow]
    }

}
