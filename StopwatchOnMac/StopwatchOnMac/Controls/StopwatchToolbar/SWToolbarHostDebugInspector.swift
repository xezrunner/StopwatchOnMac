// StopwatchOnMacDemo::SWToolbarHostDebugInspector.swift - 14/08/2025
import SwiftUI

struct SWToolbarHostDebugInspector: View {
    let toolbarController: SWToolbarController?
    
    var body: some View {
        ScrollView {
#if DEBUG
            VStack {
                commonInfoView
                    .padding(.bottom)
                
                HStack {
                    itemsSidebar
                        .frame(maxWidth: 250)
                    
                    itemsContent
                        .frame(minWidth: 500, maxWidth: 1000)
                }
                .frame(minHeight: 400)
            }
            .monospaced()
#else
            Text("< SWToolbarHost Debug Inspector is unavailable in Release builds. >")
#endif
        }
        .padding(18)
        .buttonStyle(StopwatchButtonStyle())
    }
    
#if DEBUG
    var commonInfoView: some View {
        VStack(alignment: .leading) {
            Text("SWToolbarHost Debug").bold()
        }
    }
    
    @Binding var itemSelection: SWToolbarItemData?
    var itemsSidebar: some View {
        StopwatchList(selection: $itemSelection) {
            ForEach(StopwatchToolbarPlacement.allCases, id: \.rawValue) { placement in
                let items = toolbarController?.items.values.filter { $0.placement == placement } ?? []
                if !items.isEmpty {
                    Section(placement.rawValue) {
                        ForEach(items) { item in
                            Text(item.id.debugDescription)
                                .monospaced()
                                .tag(item)
                        }
                    }
                }
            }
        }
        .stopwatchListStyleConfiguration(.sidebar)
    }
    
    var itemsContent: some View {
        var validSelection: SWToolbarItemData? {
            guard let id = itemSelection?.id else { return nil }
            return toolbarController?.items[id]
        }
        
        return VStack(alignment: .leading) {
            if let item = validSelection, let toolbarController {
                Text("id: \(item.id)")
                HStack {
                    let binding = Binding<String>(
                        get: { item.placement.rawValue },
                        set: {
                            guard let newPlacement = StopwatchToolbarPlacement(rawValue: $0) else { return }
                            var updatedItem = item
                            updatedItem.placement = newPlacement
                            toolbarController.items[item.id] = updatedItem
                        }
                    )
                    Picker("placement:", selection: binding) {
                        ForEach(StopwatchToolbarPlacement.allCases, id: \.rawValue) { Text($0.rawValue) }
                    }
                }
                Group {
                    let binding = Binding(get: { item.animate }, set: {
                        var updatedItem = item
                        updatedItem.animate = $0
                        toolbarController.items[item.id] = updatedItem
                    })
                    Toggle("animate", isOn: binding)
                }
                Text("view: \(toolbarController.items[item.id]?.view.debugDescription ?? "nil")")
                    .font(.system(size: 12))
                    .border(.gray)
                Button("Remove") {
                    itemSelection = nil
                    toolbarController.items.removeValue(forKey: item.id)
                }
            } else {
                Text("No item selected.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
#endif
}
