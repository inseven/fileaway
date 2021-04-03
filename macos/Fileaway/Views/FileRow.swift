//
//  FileRow.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

import SwiftUI
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

class IconProvider: ObservableObject {

    let url: URL
    @Published var image: NSImage

    init(url: URL) {
        self.url = url
        self.image = NSWorkspace.shared.icon(forFile: url.path)
        DispatchQueue.global(qos: .userInteractive).async {
            guard let image = NSImage.previewForFile(path: url, ofSize: CGSize(width: 48, height: 48), asIcon: true) else {
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

struct FileRow: View {

    var file: FileInfo
    var isSelected: Bool

    @StateObject var iconProvider: IconProvider

    init(file: FileInfo, isSelected: Bool) {
        self.file = file
        self.isSelected = isSelected
        _iconProvider = StateObject(wrappedValue: IconProvider(url: file.url))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(nsImage: iconProvider.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(idealHeight: 48)
                VStack(spacing: 0) {
                    HStack {
                        Text(file.name)
                            .lineLimit(1)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        Spacer()
                        if let date = file.date {
                            DateView(date: date)
                                .foregroundColor(isSelected ? .white : .secondary)
                        }
                    }
                    HStack {
                        Text(file.directoryUrl.path)
                            .lineLimit(1)
                            .foregroundColor(isSelected ? .white : .secondary)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 6)
        }
        .padding(.leading)
        .padding(.trailing)
    }

}
