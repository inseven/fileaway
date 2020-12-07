//
//  QuickLookCoordinator.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 07/12/2020.
//

import Foundation
import Quartz

class QuickLookCoordinator: NSObject, QLPreviewPanelDataSource {

    static var shared: QuickLookCoordinator = {
        QuickLookCoordinator()
    }()

    var url: URL?

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return url! as QLPreviewItem
    }

    func numberOfPreviewItems(in controller: QLPreviewPanel) -> Int {
        return 1
    }

    func show(url: URL?) {
        self.url = url
        guard let panel = QLPreviewPanel.shared() else {
            return
        }
        if self.url != nil {
            panel.center()
            panel.dataSource = self
            panel.updateController()
            panel.makeKeyAndOrderFront(nil)
        } else {
            panel.orderOut(nil)
        }
    }
}
