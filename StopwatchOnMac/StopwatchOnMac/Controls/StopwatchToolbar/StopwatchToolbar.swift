// StopwatchOnMac::StopwatchToolbar.swift - 02.07.2025
import SwiftUI

public enum StopwatchToolbarPlacement: String, CaseIterable {
    case leading, center, trailing
}

internal struct SWToolbarItemData: Identifiable, Hashable, Equatable {
    let id: UUID = UUID()
    var placement: StopwatchToolbarPlacement
    var animate: Bool = true
    var view: AnyView?
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: SWToolbarItemData, rhs: SWToolbarItemData) -> Bool { lhs.id == rhs.id }
}

@Observable internal class SWToolbarController {
    var items: [UUID:SWToolbarItemData] = [:]
    
    func getItems(for placement: StopwatchToolbarPlacement) -> [SWToolbarItemData] {
        items.values.filter( { $0.placement == placement } )
    }
}

public struct StopwatchToolbarItem<Content: View>: View {
    @Environment(SWToolbarController.self) var toolbarController
    @State var data: SWToolbarItemData
    
    var content: () -> Content
    
    init(placement: StopwatchToolbarPlacement, animate: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        data = SWToolbarItemData(placement: placement, animate: animate, view: AnyView(content()))
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.init(placement: .trailing, content: content)
    }
    
    public var body: some View {
        content()
            // HACK: this is super bad, as we'll effectively have doubles of toolbar items in the view tree,
            // but this is pretty much the only way to have them be properly reactive (conditional views)
            // with the public SwiftUI APIs.
            .hidden()
        
            .onAppear {
                withAnimation(!data.animate ? nil : SWAnimationLibrary.toolbarItemTransition) {
                    toolbarController.items[data.id] = data
                }
            }
            .onDisappear {
                withAnimation(!data.animate ? nil : SWAnimationLibrary.toolbarItemTransition) {
                    _ = toolbarController.items.removeValue(forKey: data.id)
                }
            }
    }
}

internal struct SWToolbarHost: View {
    @Environment(SWToolbarController.self) var toolbarController: SWToolbarController?
    
    @State var debugInspector = false
#if DEBUG
    @State var debugSizeInfo: CGSize = .zero
    @State var debugItemSelection: SWToolbarItemData?
#endif
    
    func makeToolbarItemView(itemData: SWToolbarItemData, transition: AnyTransition = SWToolbarHost.ToolbarItemTransition) -> some View {
        itemData.view?
            .transition(itemData.animate ? transition : .identity)
            .transaction { t in
                // Disable unwanted layout animations:
                // We do appear/disappear transitions ourselves with withAnimation {} within StopwatchToolbarItem.
                t.animation = nil
            }
            .border(debugInspector && debugItemSelection == itemData ? .yellow : .clear)
    }
    
    static var ToolbarItemTransition: AnyTransition {
        .scale(scale: 0.9)
        .combined(with: .opacity)
    }
    
    var body: some View {
        Group {
            if let toolbarController = toolbarController {
                VStack {
                    HStack {
                        // TODO: different animations for different placements?
                        ForEach(toolbarController.getItems(for: .leading)) { item in
                            makeToolbarItemView(itemData: item)
                        }
                        
                        HStack {
                            ForEach(toolbarController.getItems(for: .center)) { item in
                                makeToolbarItemView(itemData: item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
#if DEBUG
                        .background(!debugInspector ? .clear : .green.opacity(0.25))
#endif
                        
                        ForEach(toolbarController.getItems(for: .trailing)) { item in
                            makeToolbarItemView(itemData: item)
                        }
                    }
                    .stopwatchButtonStyleConfiguration(.circular)
                }
            } else {
                Text("⚠️ No SWToolbarController in environment!")
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        
#if DEBUG
        .onTapGesture {
            if NSEvent.modifierFlags == [.control, .option] { debugInspector.toggle() }
        }
        .popover(isPresented: $debugInspector, arrowEdge: .bottom) {
            SWToolbarHostDebugInspector(toolbarController: toolbarController, itemSelection: $debugItemSelection)
        }
        .background(BackgroundStyle.background.opacity(!debugInspector ? 0.0 : 1))
        .border(!debugInspector ? .clear : .red)
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { debugSizeInfo = $0 })
        .animation(.smooth, value: debugInspector)
#endif
    }
}



extension View {
    func stopwatchToolbar<C: View>(@ViewBuilder content: () -> C) -> some View {
        return self.overlay { content() }
    }
}
