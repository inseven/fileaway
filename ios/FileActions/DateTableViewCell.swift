//
//  DateTableViewCell.swift
//  File Actions
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import FileawayCore

protocol DateTableViewCellDelegate: class {
    func dateTableViewCellDidChange(_ dateTableViewCell: DateTableViewCell)
}

class DateTableViewCell: UITableViewCell {

    var variable: Variable?
    weak var delegate: DateTableViewCellDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(DateTableViewCell.datePickerDidChange), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc func datePickerDidChange(sender: UIDatePicker) {
        guard let delegate = delegate else {
            return
        }
        delegate.dateTableViewCellDidChange(self)
    }
}
