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

import SwiftUI

import HashRainbow

public class VariableModel: ObservableObject, Identifiable, Codable, Hashable {

    struct DateParams: Codable {
        let hasDay: Bool

        init(hasDay: Bool = true) {
            self.hasDay = hasDay
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case dateParams
    }

    enum RawType: String, Codable {
        case string
        case date
    }

    public static func == (lhs: VariableModel, rhs: VariableModel) -> Bool {
        return lhs.id == rhs.id
    }

    public var id = UUID()

    @Published public var name: String
    @Published public var type: VariableType

    public var color: Color {
        return HashRainbow.colorForString(name, colors: HashRainbow.NeonColors)
    }

    public init(name: String, type: VariableType) {
        self.name = name
        self.type = type
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let type = try container.decode(RawType.self, forKey: .type)

        switch type {
        case .string:
            self.name = name
            self.type = .string
        case .date:
            let dateParams = try container.decodeIfPresent(DateParams.self, forKey: .dateParams)
                ?? DateParams()
            self.name = name
            self.type = .date(hasDay: dateParams.hasDay)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        switch type {
        case .string:
            try container.encode(RawType.string, forKey: .type)
        case .date(let hasDay):
            try container.encode(RawType.date, forKey: .type)
            try container.encode(DateParams(hasDay: hasDay), forKey: .dateParams)
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
