//
//  PreviewTableViewCell.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 11/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit
import PDFKit

class PreviewTableViewCell: UITableViewCell {

    var pdfView: PDFView!
    var documentUrl: URL? {
        didSet {
            guard let documentUrl = documentUrl else {
                return
            }
            pdfView.document = PDFDocument(url: documentUrl)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.contentView.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pdfView.backgroundColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
