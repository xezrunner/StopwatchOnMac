// StopwatchOnMac::StopwatchSplitView.swift - 21.06.2025

import SwiftUI

// Sidebar: lets users choose a main category or list
// Content (only in 3‑column): intermediate level—shows items within the sidebar selection
// Detail: final view—displays full details of the selected content (applies in both 2‑column and 3‑column setups)
public struct StopwatchNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {
    @ViewBuilder public var sidebar: Sidebar
    @ViewBuilder public var content: Content
    @ViewBuilder public var detail:  Detail
    
    // Without Content:
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView {
        self.sidebar = sidebar()
        self.detail = detail()
        self.content = EmptyView()
    }
    
    public var body: some View {
        HStack {
            sidebar
                .frame(maxWidth: 300) // TODO: sizing
            
            content
                .frame(maxWidth: 300) // TODO: sizing
            
            detail
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
