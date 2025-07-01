// StopwatchOnMac::StopwatchSplitView.swift - 21.06.2025

import SwiftUI

public struct StopwatchNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {
    private var inferredDetailInfo  = SWNavigationInferredInfo<Detail>()
    private var inferredContentInfo = SWNavigationInferredInfo<Content>()
    
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
            
            NavigationStack(root: inferredDetailInfo.view ?? detail)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(inferredDetailInfo)
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

// FIXME: naming!
@Observable internal class SWNavigationInferredInfo<T: View> {
    var view: (() -> T)?
    
    init(view: (() -> T)? = nil) {
        self.view = view
    }
}

public struct StopwatchNavigationLink<Destination: View>: View {
    @Environment(SWNavigationInferredInfo<Destination>.self) var observable
    @ViewBuilder var destination: () -> Destination
    
    public init(@ViewBuilder destination: @escaping () -> Destination) {
        self.destination = destination
    }
    
    public var body: some View {
        Button("StopwatchNavigationLink") { observable.view = destination }
            .buttonStyle(StopwatchButtonStyle(maxWidth: .infinity))
    }
}
