import SwiftUI

/**
 * Custom tab bar that has draws an accented indicator bar below each tab.
 * https://www.objc.io/blog/2020/02/25/swiftui-tab-bar/
 */
struct TabBar<TabItemType: TabItem>: View {

    @Binding var currentTab: TabItemType
    let geometry: GeometryProxy
    let tabItems: [TabItemType]

    @State private var width: CGFloat = 0

    var body: some View {
        if width <= 0 {
            return
                // First we calculate the width of all the tabs by putting them into a ZStack. We do this in order to
                // set the width of the eventual HStack appropriately. If the total width is less than then width of
                // the containing GeometryProxy, then we should set the width to the width of the geometry proxy so
                // that the tabs take up the entire width and are equaly spaced. However, if the total width is greater
                // than or equal to the width of the containing GeometryProxy, then we should set the frame's width to
                // nil to allow it to scroll offscreen.
                ZStack {
                    ForEach(tabItems) { tabItem in
                        Button(
                            action: {},
                            label: {
                                Group {
                                    if self.isSelected(tabItem) {
                                        tabItem.selectedLabel
                                    } else {
                                        tabItem.unselectedLabel
                                    }
                                }.accessibility(label: tabItem.a11yLabel).padding()
                                    .anchorPreference(key: WidthPreferenceKey.self, value: .bounds) { anchor in
                                        self.geometry[anchor].width
                                }
                        })
                    }
                }.onPreferenceChange(WidthPreferenceKey.self) { width in
                    self.width = width
                }.eraseToAnyView()
        } else {
            return
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tabItems) { tabItem in
                            Spacer()
                            Button(
                                action: {
                                    withAnimation(.default) {
                                        self.currentTab = tabItem
                                    }
                            }, label: {
                                Group {
                                    if self.isSelected(tabItem) {
                                        tabItem.selectedLabel
                                    } else {
                                        tabItem.unselectedLabel
                                    }
                                }.accessibility(label: tabItem.a11yLabel).padding()
                            }).accentColor(self.isSelected(tabItem) ? .accentColor : .primary)
                                .anchorPreference(
                                    key: FirstNonNilPreferenceKey<Anchor<CGRect>>.self,
                                    value: .bounds,
                                    transform: { anchor in
                                        // Find the anchor where the current tab item is selected.
                                        self.isSelected(tabItem) ? .some(anchor) : nil
                                }
                            )
                            Spacer()
                        }
                    }.frame(width: self.width > geometry.size.width ? nil : geometry.size.width)
                }.backgroundPreferenceValue(FirstNonNilPreferenceKey<Anchor<CGRect>>.self) { boundsAnchor in
                    // Create the indicator.
                    GeometryReader { proxy in
                        boundsAnchor.map { anchor in
                            Rectangle()
                                .foregroundColor(.accentColor)
                                .frame(width: proxy[anchor].width, height: 3, alignment: .bottom)
                                .offset(.init(
                                    width: proxy[anchor].minX,
                                    height: proxy[anchor].height - 4)) // Make the indicator a little higher
                        }
                    }
                }.background(Color(.systemBackground)).eraseToAnyView()
        }
    }

    private func isSelected(_ tabItem: TabItemType) -> Bool {
        tabItem == currentTab
    }
}

/**
 * Finds the first non-nil preference key.
 *
 * This is used for finding the first selected tab item so we can draw the indicator.
 */
struct FirstNonNilPreferenceKey<T>: PreferenceKey {
    static var defaultValue: T? { nil }

    static func reduce(value: inout T?, nextValue: () -> T?) {
        value = value ?? nextValue()
    }
}

/**
 * Preference key to calculate the cumulative width of all the views.
 *
 * This is used to determine if we need to scroll off-screen or not and is used to set the frame width for the tab's HStack.
 */
struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

#if DEBUG
struct TabBar_Previews: PreviewProvider {

    static var previews: some View {
        var home: HomeTab = .home
        var browse: HomeTab = .browse
        var lyricsTab: HymnLyricsTab = .lyrics(EmptyView().eraseToAnyView())
        return Group {
            GeometryReader { geometry in
                TabBar(
                    currentTab: Binding<HymnLyricsTab>(
                        get: {lyricsTab},
                        set: {lyricsTab = $0}),
                    geometry: geometry,
                    tabItems: [lyricsTab,
                               .chords(EmptyView().eraseToAnyView()),
                               .guitar(EmptyView().eraseToAnyView()),
                               .piano(EmptyView().eraseToAnyView())])
            }
            GeometryReader { geometry in
                TabBar(
                    currentTab: Binding<HomeTab>(
                        get: {home},
                        set: {home = $0}),
                    geometry: geometry,
                    tabItems: [
                        .home,
                        .browse,
                        .favorites,
                        .settings
                ]).previewDisplayName("home tab selected")
            }
            GeometryReader { geometry in
                TabBar(
                    currentTab: Binding<HomeTab>(
                        get: {browse},
                        set: {browse = $0}),
                    geometry: geometry,
                    tabItems: [
                        .home,
                        .browse,
                        .favorites,
                        .settings
                ]).previewLayout(.sizeThatFits).previewDisplayName("browse tab selected")
            }
        }.previewLayout(.fixed(width: 350, height: 50))
    }
}
#endif
