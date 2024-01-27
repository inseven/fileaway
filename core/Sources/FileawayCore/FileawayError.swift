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

public enum FileawayError: Error {
    case directoryNotFound
    case fileOpenError
    case duplicateRuleName
    case accessError
    case pathError
    case bookmarkError
    case corruptSettings
}

extension FileawayError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "Directory not found."
        case .fileOpenError:
            return "File open error."
        case .duplicateRuleName:
            return "Name already exists in Rule Set."
        case .accessError:
            return "Failed access inbox url with security scope."
        case .pathError:
            return "Unable to read directory at path."
        case .bookmarkError:
            return "Unable to get bookmark url."
        case .corruptSettings:
            return "Settings corrupt."
        }
    }

}
