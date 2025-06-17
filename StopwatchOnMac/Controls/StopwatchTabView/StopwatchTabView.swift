// StopwatchOnMac::StopwatchTabView.swift - 17.06.2025

import SwiftUI



public struct StopwatchTabView<Tab: StopwatchTab>: View {
    private let allTabs: [Tab]
    
    @State private var _internalSelection: Tab
    private var _externalSelection: Binding<Tab>? = nil
    private var _selectionBinding: Binding<Tab> { _externalSelection ?? $_internalSelection }
    
    var selection: Tab {
        get { _selectionBinding.wrappedValue }
        set { _selectionBinding.wrappedValue = newValue }
    }
    
    public init(tabType: Tab.Type, tabSelection: Binding<Tab>? = nil) {
        allTabs = tabType.allCases
        assert(allTabs.count > 0)
        
        __internalSelection = State(initialValue: allTabs.first!)
        _externalSelection = tabSelection
    }
    
    @State var isExpanded: Bool = true
    var expandAnimation: Animation { !isExpanded ? .smooth : .linear(duration: 0.25) }
    
    public var body: some View {
        VStack {
            Button("Toggle expanded") {
                withAnimation(expandAnimation) { isExpanded = !isExpanded }
            }
            
            TabView(selection: _selectionBinding) {
                ForEach(allTabs) { tab in
                    tab.view()
                }
            }
            // This is odd, but it does hide just the tab bar. Hiding .windowToolbar would also hide the window controls / toolbar!
            .toolbar(.hidden, for: .automatic)
            
            SWTabViewStrip(allTabs: allTabs, selectedTab: _selectionBinding, isTabStripExpanded: isExpanded)
        }
    }
}

