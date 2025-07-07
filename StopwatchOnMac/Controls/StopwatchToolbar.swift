// StopwatchOnMac::StopwatchToolbar.swift - 02.07.2025
import SwiftUI

// MARK: - Environment Values and Keys
// TODO: we might want to use environment keys, if we decide that we want custom toolbar presentations
#if false
private struct StopwatchToolbarContentKey: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    var stopwatchToolbarContent: AnyView? {
        get { self[StopwatchToolbarContentKey.self] }
        set { self[StopwatchToolbarContentKey.self] = newValue }
    }
}
#endif

public extension View {
    func stopwatchToolbar<Content: ToolbarContent>(@ViewBuilder content: @escaping () -> Content) -> some View {
        self.toolbar(content: content)
    }
}

public struct StopwatchToolbarItem<Content: View>: ToolbarContent {
    @ViewBuilder let content: () -> Content
    
    var placement: ToolbarItemPlacement = .automatic
    
    public init(placement: ToolbarItemPlacement = .automatic, @ViewBuilder content: @escaping () -> Content) {
        self.placement = placement
        self.content = content
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement, content: content)
            .sharedBackgroundVisibility(.hidden)
    }
}

public struct StopwatchToolbarItemGroup<Content: View>: ToolbarContent {
    @ViewBuilder let content: () -> Content
    
    var placement: ToolbarItemPlacement = .automatic
    
    public init(placement: ToolbarItemPlacement = .automatic, @ViewBuilder content: @escaping () -> Content) {
        self.placement = placement
        self.content = content
    }
    
    public var body: some ToolbarContent {
        ToolbarItemGroup(placement: placement, content: content)
            .sharedBackgroundVisibility(.hidden)
    }
}
