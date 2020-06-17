//
//  TextTableViewCell.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import FileActionsCore

protocol TextTableViewCellDelegate: class {
    func textTableViewCellDidChange(_ textTableViewCell: TextTableViewCell)
}

class TextTableViewCell: UITableViewCell {

    weak var delegate: TextTableViewCellDelegate?
    var variable: Variable? {
        didSet {
            textField.placeholder = variable?.name
        }
    }

    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.addTarget(self, action: #selector(TextTableViewCell.textFieldDidChange), for: .allEditingEvents)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc func textFieldDidChange(sender: UITextField) {
        guard let delegate = delegate else {
            return
        }
        delegate.textTableViewCellDidChange(self)
    }
}
