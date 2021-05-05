// Copyright (c) 2018-2021 InSeven Limited
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

import AppKit
import QuickLook

extension NSImage {

    static func previewForFile(path fileURL: URL, ofSize size: CGSize, asIcon: Bool) -> NSImage? {

        let dict = [
            kQLThumbnailOptionIconModeKey: NSNumber(booleanLiteral: asIcon),
            kQLThumbnailOptionScaleFactorKey: 2,
        ] as CFDictionary

        let ref = QLThumbnailImageCreate(kCFAllocatorDefault, fileURL as CFURL, size, dict)
        if let cgImage = ref?.takeUnretainedValue() {
            let bitmapImageRep = NSBitmapImageRep.init(cgImage: cgImage)
            let newImage = NSImage.init(size: bitmapImageRep.size)
            newImage.addRepresentation(bitmapImageRep)
            ref?.release()
            return newImage
        } else {
            let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
            icon.size = size
            return icon
        }

    }

}
