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
            pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        pdfView.pageShadowsEnabled = true
        pdfView.isUserInteractionEnabled = false
        self.contentView.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

}
