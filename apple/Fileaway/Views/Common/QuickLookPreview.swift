// Copyright (c) 2018-2025 Jason Morley
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

import SwiftUI

#if os(macOS)

import Quartz

struct QuickLookPreview: NSViewRepresentable {

    var url: URL

    func makeNSView(context: NSViewRepresentableContext<QuickLookPreview>) -> QLPreviewView {
        let preview = QLPreviewView(frame: .zero, style: .compact)
        preview?.autostarts = true
        // TODO: Ensure the QLPreviewView instances are not leaking #100
        //       https://github.com/jbmorley/fileaway/issues/100
        preview?.shouldCloseWithWindow = false
        preview?.previewItem = url as QLPreviewItem
        return preview ?? QLPreviewView()
    }

    func updateNSView(_ preview: QLPreviewView, context: NSViewRepresentableContext<QuickLookPreview>) {
        preview.previewItem = url as QLPreviewItem
    }

    typealias NSViewType = QLPreviewView

}

#else

struct QuickLookPreview: View {

    var url: URL

    var body: some View {
        Text(url.path)
    }

}

#endif
