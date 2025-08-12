// StopwatchOnMacDemo::AppleMusicPlaylistTabView.swift - 21.06.2025

import SwiftUI
import StopwatchOnMac

struct AppleMusicDemoTabs {
    
    struct LibraryTab: View {
        var body: some View {
#if false
            NavigationSplitView {
                NavigationLink("Test", destination: destination)
                NavigationLink("Test", destination: destination)
                NavigationLink("Test", destination: destination)
            } detail: {
                Text("< Content >")
            }
#else
            StopwatchNavigationSplitView {
                ForEach(0..<5, id: \.self) { i in
                    StopwatchNavigationLink(String(i), destination: { Text(String(i)) })
                }
            } detail: {
                Text("< Content >")
                
                Button("Test", action: {})
                    .stopwatchButtonStyleConfiguration(.sidebar)
            }

#endif
            
        }
        
        var destination: some View {
            Text("< Content >")
        }
    }
    
}
