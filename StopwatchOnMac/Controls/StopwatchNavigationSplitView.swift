// StopwatchOnMac::StopwatchSplitView.swift - 21.06.2025

import SwiftUI

public struct StopwatchNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {
    private var viewLinkageDetail  = SWNavigationViewLinkage<Detail>()
    private var viewLinkageContent = SWNavigationViewLinkage<Content>()
    
    @ViewBuilder var sidebar: Sidebar
    var content: () -> Content
    var detail:  () -> Detail
    
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail:  @escaping () -> Detail) {
        self.sidebar = sidebar()
        self.content = content
        self.detail  = detail
    }
    
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView {
        self.init(sidebar: sidebar, content: { EmptyView() }, detail: detail)
    }
    
    public var body: some View {
        HStack {
            SWNavigationSidebarList(content: sidebar)
                .frame(maxWidth: 300, maxHeight: .infinity)
            
            // TODO: Content!
            
            NavigationStack(root: viewLinkageDetail.view ?? detail)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(viewLinkageDetail)
    }
}

internal struct SWNavigationSidebarList<Content: View>: View {
    var content: Content
    
    var body: some View {
        List {
            content
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

// MARK: - Navigation links

// When using a StopwatchNavigationLink inside a StopwatchNavigation... content part, it will navigate that
// part to whatever destination you provide in the link.
@Observable internal class SWNavigationViewLinkage<T: View> {
    var view: (() -> T)?
    
    init(view: (() -> T)? = nil) {
        self.view = view
    }
}

public struct StopwatchNavigationLink<Destination: View, Label: View>: View {
    @Environment(SWNavigationViewLinkage<Destination>.self) var viewLinkage
    @ViewBuilder var destination: () -> Destination
    
    @ViewBuilder var label: () -> Label
    
    @_disfavoredOverload // https://forums.swift.org/t/how-to-determine-if-a-passed-argument-is-a-string-literal/41651/6
    public init<S: StringProtocol>(_ titleKey: S, @ViewBuilder destination: @escaping () -> Destination) where Label == Text {
        self.destination = destination
        self.label = { Text(titleKey) }
    }
    
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: @escaping () -> Destination) where Label == Text {
        self.destination = destination
        self.label = { Text(titleKey) }
    }
    
    public init(@ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }
    
    private func navigate() {
        viewLinkage.view = destination
    }
    
    public var body: some View {
        Button(action: navigate, label: label)
        .stopwatchButtonStyleConfiguration(.sidebar)
        .stopwatchButtonAlignment(.leading)
    }
}
