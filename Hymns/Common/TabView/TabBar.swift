import SwiftUI

/**
 * Custom tab bar that has draws an accented indicator bar below each tab.
 * https://www.objc.io/blog/2020/02/25/swiftui-tab-bar/
 */
struct TabBar<TabItemType: TabItem>: View {

    @Binding var currentTab: TabItemType
    let geometry: GeometryProxy
    let tabItems: [TabItemType]

    @State private var isCalcuating = true
    @State private var width: CGFloat = 0

    var body: some View {
        if isCalcuating {
            return
                ZStack {
                    ForEach(tabItems) { tabItem in
                        Spacer()
                        Button(
                            action: {},
                            label: {
                                Group {
                                    if self.isSelected(tabItem) {
                                        tabItem.selectedLabel
                                    } else {
                                        tabItem.unselectedLabel
                                    }
                                }.accessibility(label: tabItem.a11yLabel).padding().anchorPreference(key: WidthPreferenceKey.self, value: .bounds) { anchor in
                                    self.geometry[anchor].width
                                }
                        })
                            .accentColor(self.isSelected(tabItem) ? .accentColor : .primary)
                            .anchorPreference(
                                key: FirstNonNilPreferenceKey<Anchor<CGRect>>.self,
                                value: .bounds,
                                transform: { anchor in self.isSelected(tabItem) ? .some(anchor) : nil }
                        )
                    }
                }.onPreferenceChange(WidthPreferenceKey.self) { width in
                    self.width = width
                }.onAppear {
                    self.isCalcuating = false
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
                            },
                                label: {
                                    Group {
                                        if self.isSelected(tabItem) {
                                            tabItem.selectedLabel
                                        } else {
                                            tabItem.unselectedLabel
                                        }
                                    }.accessibility(label: tabItem.a11yLabel).padding()
                            })
                                .accentColor(self.isSelected(tabItem) ? .accentColor : .primary)
                                .anchorPreference(
                                    key: FirstNonNilPreferenceKey<Anchor<CGRect>>.self,
                                    value: .bounds,
                                    transform: { anchor in self.isSelected(tabItem) ? .some(anchor) : nil }
                            )
                            Spacer()
                        }
                    }
                    .frame(width: getWidth())
                }.backgroundPreferenceValue(FirstNonNilPreferenceKey<Anchor<CGRect>>.self) { boundsAnchor in
                    GeometryReader { proxy in
                        boundsAnchor.map { anchor in
                            indicator(
                                width: proxy[anchor].width,
                                offset: .init(
                                    width: proxy[anchor].minX,
                                    height: proxy[anchor].height - 4 // Make the indicator a little higher
                                )
                            )
                        }
                    }
                }
                .background(Color(.systemBackground)).eraseToAnyView()
        }
    }

    private func getWidth() -> CGFloat? {
        let width = self.width
        let geoWidth = geometry.size.width
        let greater = width > geoWidth
        print("booyah3 width: \(width), geoWidth: \(geoWidth), greater: \(greater)")
        return width > geoWidth ? nil : geoWidth
    }

    private func isSelected(_ tabItem: TabItemType) -> Bool {
        tabItem == currentTab
    }
}

struct FirstNonNilPreferenceKey<T>: PreferenceKey {
    static var defaultValue: T? { nil }

    static func reduce(value: inout T?, nextValue: () -> T?) {
        value = value ?? nextValue()
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        print("booyah reducing... value: \(value), diff: \(nextValue()), newValue: \(value + nextValue())")
        value += nextValue()
    }
}

private func indicator(width: CGFloat, offset: CGSize) -> some View {
    Rectangle()
        .foregroundColor(.accentColor)
        .frame(width: width, height: 3, alignment: .bottom)
        .offset(offset)
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
