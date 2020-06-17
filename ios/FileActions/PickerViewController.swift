//
//  PickerViewController.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import QuickLook

import FileActionsCore

enum ReuseIdentifier: String {
    case textCell = "TextCell"
    case previewCell = "PreviewCell"
    case typeCell = "TypeCell"
    case dateCell = "DateCell"
}

class EditableSection: VariableProvider {

    let tableView: UITableView
    let task: Task
    var delegate: VariableProviderDelegate?
    var values: [String: Any] = [:]

    var isComplete: Bool {
        return true
    }

    init(tableView: UITableView, task: Task) {
        self.tableView = tableView
        self.task = task
    }

    func variable(forKey key: String) -> String? {
        let value = values[key]
        if let stringValue = value as? String {
            return stringValue
        } else if let dateValue = value as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            return dateFormatter.string(from: dateValue)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let variable = task.configuration.variables[indexPath.row]
        switch (variable.type) {
        case .string:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.textCell.rawValue, for: indexPath)
            guard let textCell = cell as? TextTableViewCell else {
                return cell
            }
            textCell.variable = task.configuration.variables[indexPath.row]
            textCell.textField.text = values[variable.name] as? String
            textCell.delegate = self
            return textCell
        case .date(hasDay: true), .date(hasDay: false):
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.dateCell.rawValue, for: indexPath)
            guard let dateCell = cell as? DateTableViewCell else {
                return cell
            }
            dateCell.variable = task.configuration.variables[indexPath.row]
            dateCell.datePicker.date = (values[variable.name] as? Date) ?? Date()
            dateCell.delegate = self
            return dateCell
        }

    }

    var count: Int {
        return task.configuration.variables.count
    }

}

extension EditableSection: TextTableViewCellDelegate {

    func textTableViewCellDidChange(_ textTableViewCell: TextTableViewCell) {
        guard let variable = textTableViewCell.variable else {
            print("No variable set on the text table view cell")
            return
        }
        values[variable.name] = textTableViewCell.textField.text
    }

}

extension EditableSection: DateTableViewCellDelegate {

    func dateTableViewCellDidChange(_ dateTableViewCell: DateTableViewCell) {
        guard let variable = dateTableViewCell.variable else {
            print("No variable set on the date table view cell")
            return
        }
        values[variable.name] = dateTableViewCell.datePicker.date
    }
}

class PickerViewController: UITableViewController {

    public var manager: Manager!
    var documentUrl: URL? {
        didSet {
            tableView.reloadSections([0], with: .fade)
        }
    }
    var editableSection: EditableSection? {
        didSet {
            tableView.reloadSections([2], with: .none)
        }
    }
    var task: Task? {
        didSet {
            guard let task = task else {
                editableSection = nil
                return
            }
            editableSection = EditableSection(tableView: tableView, task: task)
            tableView.reloadSections([1], with: .none)
        }
    }
    var selectedIndex: Int = 0 {
        didSet {
            task = manager.tasks[selectedIndex]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PickerViewController.dismissKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }

    @IBAction func saveTapped(_ sender: Any) {
        // TODO: There are way too many !s in this method.
        let rootUrl = try! StorageManager.rootUrl()
        let destinationUrl = manager.destinationUrl(task!, variableProvider: editableSection!, rootUrl: rootUrl)
        do {
            try FileManager.default.copyItem(at: documentUrl!, to: destinationUrl)
            try FileManager.default.removeItem(at: documentUrl!)
            self.navigationController?.dismiss(animated: true, completion: nil)
        } catch let error {
            let alertController = UIAlertController(title: "Errror", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            print(error)
        }
    }

    @objc func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = selectedIndex + 1 - 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Type") {
            guard let typeViewController = segue.destination as? TypeViewController else {
                return
            }
            typeViewController.tasks = manager.tasks
            typeViewController.selectedIndex = selectedIndex
            typeViewController.delegate = self
        }
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
            guard let editableSection = editableSection else {
                return 0;
            }
            return editableSection.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section == 0) {

            // Preview

            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.previewCell.rawValue, for: indexPath)
            let previewCell = cell as! PreviewTableViewCell
            previewCell.documentUrl = documentUrl
            return cell

        } else if (indexPath.section == 1) {

            // Document type picker

            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.typeCell.rawValue, for: indexPath)
            cell.textLabel?.text = manager.tasks[selectedIndex].name
            return cell

        } else if (indexPath.section == 2) {

            // Options

            return editableSection!.tableView(tableView, cellForRowAt:indexPath)

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

extension PickerViewController: TypeViewControllerDelegate {

    func typeViewController(_ typeViewController: TypeViewController, didSelectIndex index: Int) {
        self.navigationController?.popViewController(animated: true)
        selectedIndex = index
    }

}
