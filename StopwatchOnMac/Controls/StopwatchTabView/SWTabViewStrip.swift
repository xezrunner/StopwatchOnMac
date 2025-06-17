// StopwatchOnMac::SWTabViewStrip.swift - 17.06.2025
import SwiftUI

internal struct SWTabViewStrip<Tab: StopwatchTab>: View {
    enum Orientation { case horizontal, vertical }
    @State var orientation: Orientation = .vertical
    
    public var allTabs: [Tab]
    
    @Binding public var selectedTab: Tab
    
    var isTabStripExpanded: Bool
    
    var body: some View {
        containerView
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.gray)
            }
    }
    
    var containerView: some View {
        Group {
            if orientation == .horizontal { HStack { tabControlsView } }
            else                          { VStack { tabControlsView } }
        }
    }
    
    var tabControlsView: some View {
        ForEach(allTabs) { tab in
            tabButton(tab: tab) {
                selectedTab = tab
            }
        }
    }
    
    func tabButton(tab: Tab, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: tab.icon)
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fit)
                
                Text(tab.rawValue)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: !isTabStripExpanded ? nil : 128, maxWidth: !isTabStripExpanded ? 24 : nil, alignment: .leading)
            .clipped()
        }
    }
}
