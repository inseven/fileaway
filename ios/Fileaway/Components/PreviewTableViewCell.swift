// Copyright (c) 2018-2022 InSeven Limited
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
