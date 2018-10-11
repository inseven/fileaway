//
//  PickerViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import FileawayCore

class PickerViewController: UITableViewController {

    public var manager: Manager!
    var documentUrl: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Document"
        } else if (section == 1) {
            return "Kind"
        } else if (section == 2) {
            return "Details"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return manager.tasks.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if (indexPath.section == 2) {
            cell.textLabel?.text = manager.tasks[indexPath.row].name
        }

        return cell
    }

}
