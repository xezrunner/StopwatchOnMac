// StopwatchOnMac::StopwatchSplitView.swift - 21.06.2025

import SwiftUI
import Combine

internal class StopwatchNavigationSelectionStore<Selection: Hashable>: ObservableObject {
    @Published var selection: Binding<Selection>?
    init(selectionBinding: Binding<Selection>? = nil) { self.selection = selectionBinding }
}

struct StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color? = .primary.opacity(0.30)
}

extension EnvironmentValues {
    var stopwatchNavigationSplitViewDetailBackgroundTint: Color? {
        get { self[StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey.self] }
        set { self[StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey.self] = newValue }
    }
}

extension View {
    func stopwatchNavigationSplitViewDetailBackgroundTint(color: Color) -> some View {
        self.environment(\.stopwatchNavigationSplitViewDetailBackgroundTint, color)
    }
}

public struct StopwatchNavigationSplitView<Selection: Hashable, Sidebar: View, Content: View, Detail: View>: View {
    private var viewLinkageDetail  = SWNavigationViewLinkage()
    private var viewLinkageContent = SWNavigationViewLinkage()
    
    @StateObject var selectionStore: StopwatchNavigationSelectionStore<Selection>
    
    @Environment(\.stopwatchNavigationSplitViewDetailBackgroundTint) var detailBackgroundTint
    
    @ViewBuilder var sidebar: Sidebar
    var content: () -> Content
    var detail:  () -> Detail
    
    public init(selection: Binding<Selection>? = nil,
                @ViewBuilder sidebar: @escaping () -> Sidebar,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail:  @escaping () -> Detail) {
        self.sidebar = sidebar()
        self.content = content
        self.detail  = detail
        
        self._selectionStore = StateObject(wrappedValue: StopwatchNavigationSelectionStore(selectionBinding: selection))
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // TODO: do we want to force this list?
            SWNavigationSidebarList<Sidebar, Selection>(content: sidebar)
                .frame(maxWidth: 300, maxHeight: .infinity)
                .environmentObject(selectionStore)
            
            // TODO: Content!
            
            NavigationStack(root: viewLinkageDetail.view ?? { AnyView(detail()) })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    detailBackgroundTint?
                        .ignoresSafeArea()
                        .blendMode(.softLight)
                )
        }
        .environment(viewLinkageDetail)
    }
}

extension StopwatchNavigationSplitView {
    // Without content:
    #if FEATURE_NAVSPLITVIEW_SELECTION
    public init(selection: Binding<Selection>? = nil,
                @ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView {
        self.init(selection: selection, sidebar: sidebar, content: { EmptyView() }, detail: detail)
    }
    #endif
    
    // MARK: - Without selection:
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail:  @escaping () -> Detail) where Selection == Never {
        self.init(selection: nil, sidebar: sidebar, content: content, detail: detail)
    }
    
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView, Selection == Never {
        self.init(selection: nil, sidebar: sidebar, content: { EmptyView() }, detail: detail)
    }
}

internal struct SWNavigationSidebarList<Content: View, Selection: Hashable>: View {
    @EnvironmentObject var selectionStore: StopwatchNavigationSelectionStore<Selection>
    
    var content: Content
    
    var body: some View {
        LazyVStack(spacing: 1) {
            content
                .listRowSeparator(.hidden)
                .environmentObject(selectionStore)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(14.0)
    }
}

// MARK: - Navigation links

// When using a StopwatchNavigationLink inside a StopwatchNavigation... content part, it will navigate that
// part to whatever destination you provide in the link.
@Observable internal class SWNavigationViewLinkage {
    var view: (() -> AnyView)?
}

public struct StopwatchNavigationLink<Destination: View, Label: View, Value: Hashable>: View {
    @EnvironmentObject var selectionStore: StopwatchNavigationSelectionStore<Value>
    
    @Environment(SWNavigationViewLinkage.self) var viewLinkage
    var destination: (() -> Destination)?
    
    var label: () -> Label
    
    var value: Value?
    
    private func navigate() {
        if let destination = destination {
            viewLinkage.view = { AnyView(destination()) }
        } else { print("StopwatchNavigationLink: no destination, skipping navigation") }
        
        if let value = value { selectionStore.selection?.wrappedValue = value }
    }
    
    public var body: some View {
        Button(action: navigate, label: label)
            .stopwatchButtonStyleConfiguration(.sidebar)
            .stopwatchButtonAlignment(.leading)
    }
}

extension StopwatchNavigationLink {
    public init(_ titleKey: LocalizedStringKey) where Label == Text, Value == Never, Destination == Never {
        self.label = { Text(titleKey) }
    }
    
    // MARK: - Destination-based:
    @_disfavoredOverload // https://forums.swift.org/t/how-to-determine-if-a-passed-argument-is-a-string-literal/41651/6
    public init<S: StringProtocol>(_ titleKey: S, @ViewBuilder destination: @escaping () -> Destination) where Label == Text, Value == Never {
        self.destination = destination
        self.label = { Text(titleKey) }
    }
    
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: @escaping () -> Destination) where Label == Text, Value == Never {
        self.destination = destination
        self.label = { Text(titleKey) }
    }
    
    public init(@ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) where Value == Never {
        self.destination = destination
        self.label = label
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(_ titleKey: S) where Label == Text, Value == Never, Destination == Never {
        self.label = { Text(titleKey) }
    }
    
    // MARK: - Value-based:
#if FEATURE_NAVSPLITVIEW_SELECTION
    @_disfavoredOverload
    public init<S: StringProtocol>(_ titleKey: S, value: Value) where Label == Text, Destination == Never {
        self.value = value
        self.label = { Text(titleKey) }
    }
    
    public init(_ titleKey: LocalizedStringKey, value: Value) where Label == Text, Destination == Never {
        self.value = value
        self.label = { Text(titleKey) }
    }
    
    public init(value: Value, @ViewBuilder label: @escaping () -> Label) where Destination == Never {
        self.value = value
        self.label = label
    }
#endif
}
