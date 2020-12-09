//
//  PageView.swift
//  Document Finder
//
//  Created by Jason Barrie Morley on 09/12/2020.
//

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
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    Spacer()
                }
                Text(title)
                    .font(.headline)
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
        .environment(\.pageViewStack, pageViewStack)
        .frame(width: 300)
        .clipped()
        .onPreferenceChange(PageViewTitleKey.self) { value in
            title = value
        }
    }

}
