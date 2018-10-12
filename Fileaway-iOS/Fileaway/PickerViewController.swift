//
//  PickerViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import FileawayCore
import QuickLook

enum ReuseIdentifier: String {
    case textCell = "TextCell"
    case previewCell = "PreviewCell"
}

class PickerViewController: UITableViewController {

    public var manager: Manager!
    var documentUrl: URL?

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

        if (indexPath.section == 0) {

            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.previewCell.rawValue, for: indexPath)
            let previewCell = cell as! PreviewTableViewCell
            previewCell.documentUrl = documentUrl
            return cell

        } else if (indexPath.section == 1) {

            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.textCell.rawValue, for: indexPath)
            cell.textLabel?.text = nil
            return cell

        } else if (indexPath.section == 2) {

            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.textCell.rawValue, for: indexPath)
            cell.textLabel?.text = manager.tasks[indexPath.row].name
            return cell
        }

        // TODO: This is inelegant; is there a better approach?
        return tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.textCell.rawValue, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 240.0
        }
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let previewController = QLPreviewController()
            previewController.dataSource = self
            navigationController?.pushViewController(previewController, animated: true)
        }
    }

}

extension PickerViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return (documentUrl as QLPreviewItem?)!
    }

}
