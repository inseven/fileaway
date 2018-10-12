//
//  TypeViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import FileawayCore

protocol TypeViewControllerDelegate: class {
    func typeViewController(_ typeViewController: TypeViewController, didSelectIndex index: Int)
}

class TypeViewController: UITableViewController {

    var tasks: [Task]!
    var selectedIndex: Int = 0
    weak var delegate: TypeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].name
        if (indexPath.row == selectedIndex) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        selectedIndex = indexPath.row
        tableView.reloadRows(at: [IndexPath(row: selectedIndex, section: 0), indexPath], with: .fade)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate.typeViewController(self, didSelectIndex: indexPath.row)
    }

}
