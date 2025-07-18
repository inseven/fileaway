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

import FileawayCore

public struct DateField: View {

    enum PickerDate: Double {
        case today = 1
        case custom = 0
    }

    @ObservedObject var dateFieldModel: DateFieldModel
    @State var selection: Double = PickerDate.today.rawValue

    let creationDate: Date?
    let options: [Date]

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()

    public init(dateFieldModel: DateFieldModel, creationDate: Date?, options: [Date]) {
        self.dateFieldModel = dateFieldModel
        self.creationDate = creationDate
        self.options = options
    }

    public var body: some View {
        VStack {
            Picker(selection: $selection) {
                Text("Today")
                    .tag(PickerDate.today.rawValue)
                if let creationDate = creationDate {
                    Divider()
                    Text("\(dateFormatter.string(from: creationDate)) – Created")
                        .tag(creationDate.timeIntervalSince1970 as Double)
                }
                Divider()
                Text("Custom")
                    .tag(PickerDate.custom.rawValue)
                if options.count > 0 {
                    Divider()
                    ForEach(options, id: \.timeIntervalSince1970) { date in
                        Text(dateFormatter.string(from: date))
                            .tag(date.timeIntervalSince1970 as Double)
                    }
                }
            } label: {
                HStack {
                    VariableMarker(variable: dateFieldModel.variable)
                    Text(dateFieldModel.name)
                }
            }
            if selection == PickerDate.custom.rawValue {
                DatePicker("", selection: $dateFieldModel.date, displayedComponents: [.date])
            }
        }
        .onChange(of: selection) { _, selection in
            guard let tag = PickerDate(rawValue: selection) else {
                let date = Date(timeIntervalSince1970: selection)
                $dateFieldModel.date.wrappedValue = date
                return
            }
            switch tag {
            case .custom:
                break
            case .today:
                $dateFieldModel.date.wrappedValue = Date()
            }
        }
    }

}
