//
//  QuickLookPreview.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

import Quartz
import SwiftUI

struct QuickLookPreview: NSViewRepresentable {

    var url: URL

    func makeNSView(context: NSViewRepresentableContext<QuickLookPreview>) -> QLPreviewView {
        let preview = QLPreviewView(frame: .zero, style: .compact)
        preview?.autostarts = true
        preview?.previewItem = url as QLPreviewItem
        return preview ?? QLPreviewView()
    }

    func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<QuickLookPreview>) {
    }

    typealias NSViewType = QLPreviewView

}
