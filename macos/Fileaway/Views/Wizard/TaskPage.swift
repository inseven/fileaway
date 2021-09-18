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

import SwiftUI

import Interact

struct TaskPage: View {

    enum FocusableField: Hashable {
        case search
    }

    var manager: Manager
    var url: URL

    @StateObject var filter: LazyFilter<Rule>
    @StateObject var tracker: SelectionTracker<Rule>

    @State var activeRule: Rule? = nil
    @State var firstResponder: Bool = true

    @FocusState private var focus: FocusableField?

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    init(manager: Manager, url: URL) {
        self.manager = manager
        self.url = url
        let filter = Deferred(LazyFilter(items: manager.$allRules, test: { filter, item in
            [item.rootUrl.displayName, item.name].joined(separator: " ").localizedSearchMatches(string: filter)
        }, initialSortDescriptor: { lhs, rhs in lhs.name.lexicographicallyPrecedes(rhs.name) }))
        self._filter = StateObject(wrappedValue: filter.get())
        self._tracker = StateObject(wrappedValue: SelectionTracker(items: filter.get().$items))
    }

    func binding(for rule: Rule) -> Binding<Bool> {
        Binding {
            self.activeRule == rule
        } set: { value in
            if value {
                self.activeRule = rule
            } else if self.activeRule == rule {
                self.activeRule = nil
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $filter.filter)
                    .font(.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($focus, equals: .search)
                    .onSubmit {
                        if tracker.items.count == 1 {
                            activeRule = tracker.items.first
                        }
                    }
                if !filter.filter.isEmpty {
                    Button {
                        filter.filter = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(tracker.items) { rule in
                        PageLink(destination: DetailsPage(url: url, rule: rule), isActive: binding(for: rule)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(rule.name)
                                    Text(rule.rootUrl.displayName)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.forward")
                            }
                            .padding()
                            .contentShape(Rectangle())
                            .modifier(Highlight(tracker: tracker, item: rule))
                        }
                        Divider()
                            .padding(.leading)
                            .padding(.trailing)
                    }
                }
            }
        }
        .padding()
        .acceptsFirstResponder(isFirstResponder: $firstResponder)
        .modifier(TrackerInput(tracker: tracker))
        .pageTitle("Select Rule")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focus = .search
            }
        }
    }

}
