import SnapshotTesting
import SwiftUI

extension Snapshotting where Value: SwiftUI.View, Format == UIImage {

    /**
     * Allows for Snapshot testing for SwiftUI views.
     * https://github.com/V8tr/SnapshotTestingSwiftUI/blob/master/SnapshotTestingSwiftUITests/SnapshotTesting%2BSwiftUI.swift
     */
    static func image(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init()) -> Snapshotting {
        Snapshotting<UIViewController, UIImage>.image(
            drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
            precision: precision,
            size: size,
            traits: traits)
            .pullback(UIHostingController.init(rootView:))
    }
}
