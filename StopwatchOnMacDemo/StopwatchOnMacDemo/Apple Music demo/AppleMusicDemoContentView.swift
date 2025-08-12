// StopwatchOnMacDemo::AppleMusicDemoContentView.swift - 21.06.2025

import SwiftUI
import StopwatchOnMac

struct AppleMusicDemoContentView: View {
    enum Tabs: String, StopwatchTab {
        case home    = "Home"
        case new     = "New"
        case radio   = "Radio"
        case library = "Library"
        case search  = "Search"
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .library: AppleMusicDemoTabs.LibraryTab()
                
            default: Text("< \(self.rawValue) >").monospaced()
            }
        }
        
        var icon: String {
            switch self {
            case .home:    "house"
            case .new:     "square.grid.2x2.fill"
            case .radio:   "dot.radiowaves.left.and.right"
            case .library: "square.stack.fill"
            case .search:  "magnifyingglass"
            }
        }
    }
    
    @State var tabSelection: Tabs = .library
    
    var body: some View {
        StopwatchTabView(tabType: Tabs.self, tabSelection: $tabSelection)
    }
}
