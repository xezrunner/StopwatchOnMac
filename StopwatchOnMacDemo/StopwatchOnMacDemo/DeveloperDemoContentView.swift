// StopwatchOnMacDemo::ContentView.swift - 16.06.2025

import SwiftUI
import StopwatchOnMac

struct DeveloperDemoContentView: View {
    enum TestTabs: String, StopwatchTab {
        case home     = "Home"
        case search   = "Search"
        case settings = "Settings"
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .home:
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world! Stopwatch!")
                    
                    Button("Test", systemImage: "gear", action: {})
                }
                .padding()
            default: VStack {
                Text("< \(self.rawValue) >").monospaced()
            }
            }
        }
        
        var icon: String {
            switch self {
            case .home:     "house"
            case .search:   "magnifyingglass"
            case .settings: "gear"
            }
        }
    }
    
    var body: some View {
        StopwatchTabView(tabType: TestTabs.self)
    }
}

#Preview {
    DeveloperDemoContentView()
        ._StopwatchStyling()
}
