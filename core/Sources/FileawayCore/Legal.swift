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

import Diligence
import Interact

public struct Legal {

    public static let repository = "inseven/fileaway"

    public static let copyright = "Copyright © 2018-2024 Jason Morley"

    public static let actions = [
        Action("Website", url: URL(string: "https://fileaway.app")!),
        Action("Privacy", url: URL(string: "https://fileaway.app/privacy-policy")!),
        Action("GitHub", url: URL(string: "https://github.com/inseven/fileaway")!),
    ]

    public static let acknowledgements = [
        Acknowledgements("Developers") {
            Credit("Jason Morley", url: URL(string: "https://jbmorley.co.uk"))
        },
        Acknowledgements("Thanks") {
            Credit("Lukas Fittl")
            Credit("Michael Dales")
            Credit("Pascal Pfiffner")
            Credit("Sarah Barbour")
            Credit("Terrence Talbot")
        }
    ]

    public static let licenses = [
        License("DIFlowLayout", author: "Daniel Inoa", filename: "diflowlayout-license", bundle: .module),
        License("EonilFSEvents", author: "Hoon H., Eonil", filename: "eonilfsevents-license", bundle: .module),
        License("Fileaway", author: "Jason Morley", filename: "fileaway-license", bundle: .module),
        License("FilePicker", author: "Mark Renaud", filename: "filepicker-license", bundle: .module),
        License("HashRainbow", author: "Sarah Barbour", filename: "hashrainbow-license", bundle: .module),
        License(Interact.Package.name, author: Interact.Package.author, url: Interact.Package.licenseURL),
        License("Introspect", author: "Timber Software", filename: "introspect-license", bundle: .module),
    ]

}
