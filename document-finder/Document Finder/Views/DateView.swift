//
//  DateView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 04/12/2020.
//

import SwiftUI

struct DateView: View {

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()

    let date: Date

    var body: some View {
        Text(Self.dateFormatter.string(from: date))
    }
}
