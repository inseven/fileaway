// Copyright (c) 2018-2024 Jason Morley
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

import Foundation

public struct Rule: Codable {

    enum CodingKeys: CodingKey {
        case id
        case name
        case variables
        case destination
    }

    public let id: UUID
    public let name: String
    public let variables: [VariableModel]
    public let destination: [Component]

    public init() {
        self.id = UUID()
        self.name = ""
        self.variables = []
        self.destination = []
    }

    public init(id: UUID, name: String, variables: [VariableModel], destination: [Component]) {
        self.id = id
        self.name = name
        self.variables = variables
        self.destination = destination
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.variables, forKey: .variables)
        try container.encode(self.destination, forKey: .destination)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.id) {
            self.id = try container.decode(UUID.self, forKey: .id)
        } else {
            self.id = UUID()
        }
        if container.contains(.name) {
            self.name = try container.decode(String.self, forKey: .name)
        } else {
            self.name = ""
        }
        self.variables = try container.decode([VariableModel].self, forKey: .variables)
        self.destination = try container.decode([Component].self, forKey: .destination)
    }
    
}
