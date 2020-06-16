//
//  DraggablePDFView.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 24/08/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa
import Quartz

protocol DragDelegate {
    func didDrop(url: URL)
}

class DraggablePDFView: PDFView {

    var dragDelegate : DragDelegate?

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let board = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }

        let url = URL(fileURLWithPath: path)
        if let dd = self.dragDelegate {
            dd.didDrop(url: url)
        }
        return true
    }

}
