// StopwatchOnMac::SWTabViewStrip.swift - 17.06.2025
import SwiftUI

internal struct SWTabViewStrip<Tab: StopwatchTab>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    enum Orientation { case horizontal, vertical }
    @State var orientation: Orientation = .vertical
    
    public var allTabs: [Tab]
    
    @Binding public var selectedTab: Tab
    
    @Binding var isTabStripExpanded: Bool
    var hoverSeconds: Double = 0.6
    @State private var hoverExpandTask: DispatchWorkItem? = nil
    
    var expandAnimation: Animation { !isTabStripExpanded ? .smooth : .linear(duration: 0.25) }
    
    var body: some View {
        containerView
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Material.ultraThin)
            }
        
            // Prevent clipping when part of an accessory window and unhovering:
            .frame(maxWidth: .infinity, alignment: .leading)
        
            .onHover { hover in
                if hover {
                    let task = DispatchWorkItem { isTabStripExpanded = true }
                    hoverExpandTask = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + hoverSeconds, execute: task)
                } else {
                    hoverExpandTask?.cancel()
                    isTabStripExpanded = false
                }
            }
        
            .animation(expandAnimation, value: isTabStripExpanded)
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
    
    private var tabViewStripButtonStyleConfiguration: StopwatchButtonStyleConfiguration {
        var base = StopwatchButtonStyleConfiguration.auto(colorScheme: colorScheme)
        base.padding = (8, 8)
        return base
    }
    
    func tabButton(tab: Tab, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(tab.rawValue, systemImage: tab.icon)
                .labelStyle(SWTabViewStripTabButtonLabelStyle())
            // FIXME: refactor?
//            HStack {
//                Image(systemName: tab.icon)
//                    .frame(width: 24, height: 24)
//                    .aspectRatio(contentMode: .fit)
//                
//                Text(tab.rawValue)
//                    .fixedSize(horizontal: true, vertical: false)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
            .frame(minWidth: !isTabStripExpanded ? nil : 128, maxWidth: !isTabStripExpanded ? 24 : nil, alignment: .leading)
            .clipped()
        }
        .stopwatchButtonTint(tab == selectedTab ? .primary : .clear)
        .stopwatchButtonStyleConfiguration(tabViewStripButtonStyleConfiguration)
    }

    private struct SWTabViewStripTabButtonLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 17)) // TODO: tweak/verify!
                
                // TODO: is this going to cause trouble elsewhere? I brought this over from tab strip buttons.
                configuration.title
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
