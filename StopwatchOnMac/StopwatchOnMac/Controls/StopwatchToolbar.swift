// StopwatchOnMac::StopwatchToolbar.swift - 02.07.2025
import SwiftUI

internal struct StopwatchToolbarContentPreferenceKey: PreferenceKey {
    static var defaultValue: [SWToolbarContent] = []
    
    static func reduce(value: inout Value, nextValue: () -> [SWToolbarContent]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    public func stopwatchToolbar<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .preference(key: StopwatchToolbarContentPreferenceKey.self, value: [SWToolbarContent(view: AnyView(content()))])
    }
}

internal struct SWToolbarContent: Identifiable, Hashable, Equatable {
    static func == (lhs: SWToolbarContent, rhs: SWToolbarContent) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    var view: AnyView
}

//internal struct SWToolbarContentHost<Content: View>: View {
//    @ViewBuilder var content: Content
//    
//    var body: some View {
//        content
//            .background(.red)
//            .overlay { Text("SWToolbarContentHost!").background(.black) }
//    }
//}

//extension SWToolbarContentHost {
//    public init<Data, RowContent>(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent)
//    where Content == ForEach<Data, Data.Element.ID, RowContent>,
//          Data: RandomAccessCollection,
//          RowContent : View,
//          Data.Element : Identifiable {
//        self.init() {
//            // TODO: not entirely sure about this one, but it does work:
//            ForEach(data, id: \.id) { element in
//                rowContent(element)
//            }
//        }
//    }
//}
