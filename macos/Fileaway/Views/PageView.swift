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

struct PageViewTitleKey: PreferenceKey {
    typealias Value = String

    static var defaultValue: String = ""

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension View {

    func pageTitle(_ title: String) -> some View {
        preference(key: PageViewTitleKey.self, value: title)
    }

}

class ViewContainer: Identifiable {

    public let id = UUID()
    let content: AnyView

    init(_ content: AnyView) {
        self.content = content
    }

}

class PageViewStack: ObservableObject {

    @Published var pages: [ViewContainer] = []

}

struct PageViewStackKey: EnvironmentKey {
    static var defaultValue: PageViewStack = PageViewStack()
}

extension EnvironmentValues {

    var pageViewStack: PageViewStack {
        get { self[PageViewStackKey.self] }
        set { self[PageViewStackKey.self] = newValue }
    }

}

struct PageStack: View {

    var items: [ViewContainer]

    var body: some View {
        HStack {
            if items.count < 1 {
                EmptyView()
            } else if items.count == 1 {
                items.first!.content
                    .transition(AnyTransition.asymmetric(insertion:.move(edge: .leading), removal: .move(edge: .trailing)))
            } else {
                PageStack(items: Array(items[1...]))
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

}

struct PageView<Content>: View where Content: View {

    @ObservedObject var pageViewStack = PageViewStack()
    @State var title: String = ""

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    HStack {
                        if pageViewStack.pages.count > 0 {
                            Button {
                                withAnimation {
                                    guard pageViewStack.pages.count > 0 else {
                                        return
                                    }
                                    pageViewStack.pages.removeLast()
                                }
                            } label: {
                                Image(systemName: "chevron.backward")
                            }
                        }
                        Spacer()
                    }
                    Text(title)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .frame(maxWidth: geometry.size.width - 80)
                }
                if pageViewStack.pages.count > 0 {
                    PageStack(items: pageViewStack.pages)
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    content
                        .transition(AnyTransition.asymmetric(insertion:.move(edge: .leading), removal: .move(edge: .trailing)))
                }
                Spacer()
            }
        }
        .environment(\.pageViewStack, pageViewStack)
        .frame(width: 300)
        .clipped()
        .onPreferenceChange(PageViewTitleKey.self) { value in
            title = value
        }
    }

}
