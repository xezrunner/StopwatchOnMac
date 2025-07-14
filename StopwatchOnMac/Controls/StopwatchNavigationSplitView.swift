// StopwatchOnMac::StopwatchSplitView.swift - 21.06.2025

import SwiftUI
import Combine

public struct StopwatchNavigationSplitView<Selection: Hashable, Sidebar: View, Content: View, Detail: View>: View {
    private var viewLinkageDetail  = SWNavigationViewLinkage()
    private var viewLinkageContent = SWNavigationViewLinkage()
    
    @StateObject var selectionStore: StopwatchNavigationSelectionStore<Selection>
    
    @State private var detailTitle: String?
    
    @Environment(\.stopwatchNavigationSplitViewDetailBackgroundTint) var detailBackgroundTint
    
    var sidebar: () -> Sidebar
    var content: () -> Content
    var detail:  () -> Detail
    
    public init(selection: Binding<Selection>? = nil,
                @ViewBuilder sidebar: @escaping () -> Sidebar,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail:  @escaping () -> Detail) {
        self.sidebar = sidebar
        self.content = content
        self.detail  = detail
        
        self._selectionStore = StateObject(
            wrappedValue: StopwatchNavigationSelectionStore(initialSelection: selection?.wrappedValue, binding: selection)
        )
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // TODO: do we want to force this list?
            VStack {
                sidebar()
                    .stopwatchButtonStyleConfiguration(.sidebar)
                    .stopwatchListStyleConfiguration(.sidebar)
                    .environmentObject(selectionStore)
            }
            .padding(12)
            .frame(maxWidth: 300, maxHeight: .infinity, alignment: .top)
            
            // TODO: Content!
            
            NavigationStack(root: viewLinkageDetail.view ?? { AnyView(detail()) })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    detailBackgroundTint?
                        .ignoresSafeArea()
                        .blendMode(.softLight)
                )
                .safeAreaInset(edge: .top) {
                    if let title = detailTitle {
                        Text(title)
                            .font(.system(size: 22, weight: .bold))
                            .padding(.vertical, 32)
                            .ignoresSafeArea(.all, edges: .top)
                    }
                }
                .onPreferenceChange(StopwatchNavigationTitlePreferenceKey.self) { title in
                    detailTitle = title
                }
        }
        .environment(viewLinkageDetail)
    }
}

extension StopwatchNavigationSplitView {
    // Without content:
//    #if FEATURE_NAVSPLITVIEW_SELECTION
    public init(selection: Binding<Selection>? = nil,
                @ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView {
        self.init(selection: selection, sidebar: sidebar, content: { EmptyView() }, detail: detail)
    }
//    #endif
    
    // MARK: - Without selection:
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail:  @escaping () -> Detail) where Selection == UUID {
        self.init(selection: nil, sidebar: sidebar, content: content, detail: detail)
    }
    
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView, Selection == UUID {
        self.init(selection: nil, sidebar: sidebar, content: { EmptyView() }, detail: detail)
    }
}

// MARK: - Environment keys / preference keys / modifiers:

struct StopwatchNavigationTitlePreferenceKey: PreferenceKey {
    static var defaultValue: String? = nil
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue() ?? value
    }
}

struct StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color? = .primary.opacity(0.70)
}

extension EnvironmentValues {
    var stopwatchNavigationSplitViewDetailBackgroundTint: Color? {
        get { self[StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey.self] }
        set { self[StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func stopwatchNavigationTitle(_ title: String?) -> some View {
        self.preference(key: StopwatchNavigationTitlePreferenceKey.self, value: title)
    }
    
    public func stopwatchNavigationSplitViewDetailBackgroundTint(color: Color) -> some View {
        self.environment(\.stopwatchNavigationSplitViewDetailBackgroundTint, color)
    }
}

// MARK: - Navigation links:

internal class StopwatchNavigationSelectionStore<Selection: Hashable>: ObservableObject {
    @Published var selection: Selection? {
        didSet {
            if let binding = selectionBinding, let selection = selection {
                binding.wrappedValue = selection
            }
        }
    }
    private var selectionBinding: Binding<Selection>?
    
    init(initialSelection: Selection? = nil, binding: Binding<Selection>? = nil) {
        self.selection = initialSelection
        self.selectionBinding = binding
    }
}

// When using a StopwatchNavigationLink inside a StopwatchNavigation... content part, it will navigate that
// part to whatever destination you provide in the link.
@Observable internal class SWNavigationViewLinkage {
    var view: (() -> AnyView)?
}

public struct StopwatchNavigationLink<Destination: View, Label: View, Value: Hashable>: View {
    @Environment(\.stopwatchButtonStyleConfiguration) private var buttonStyleConfigurationEnvironment

    @EnvironmentObject var selectionStore: StopwatchNavigationSelectionStore<Value>
    
    @Environment(SWNavigationViewLinkage.self) var viewLinkage
    var destination: (() -> Destination)?
    
    var label: () -> Label
    
    var value: Value?
    // If no value is given, generate a unique ID for each link and use it as selection:
    @State var _destinationImplicitID: Value?
    
    private func navigate() {
        if let destination = destination {
            viewLinkage.view = { AnyView(destination()) }
        } else { print("StopwatchNavigationLink: no destination, skipping navigation") }
        
        if let value = value ?? _destinationImplicitID { selectionStore.selection = value }
    }
    
    var isSelected: Bool {
        if let selection = selectionStore.selection, let value = value ?? _destinationImplicitID {
            return selection == value
        }
        return false
    }
    
    private var buttonStyleConfiguration: StopwatchButtonStyleConfiguration {
        buttonStyleConfigurationEnvironment ?? .navigationLinkInList
    }
    
    private var selectedStyleConfiguration: StopwatchButtonStyleConfiguration {
        var configuration: StopwatchButtonStyleConfiguration = buttonStyleConfiguration
        
        configuration.shapeIdleOpacity = 0.25
        
        return configuration
    }
    
    public var body: some View {
        Button(action: navigate, label: label)
            .stopwatchButtonStyleConfiguration(!isSelected ? buttonStyleConfiguration : selectedStyleConfiguration)
    }
}

extension StopwatchNavigationLink {
    // FIXME: these crash due to not having selectionStore<Never>!
    public init(_ titleKey: LocalizedStringKey) where Label == Text, Value == Never, Destination == Never {
        self.label = { Text(titleKey) }
    }
    
    public init(title: LocalizedStringKey, iconSystemName: String) where Label == SwiftUI.Label<Text, Image>, Value == Never, Destination == Never {
        self.label = { SwiftUI.Label(title, systemImage: iconSystemName) }
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(_ titleKey: S) where Label == Text, Value == Never, Destination == Never {
        self.label = { Text(titleKey) }
    }
    
    // MARK: - Destination-based:
    public init(@ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) where Value == UUID {
        self.destination = destination
        self._destinationImplicitID = UUID()
        self.label = label
    }
    
    @_disfavoredOverload // https://forums.swift.org/t/how-to-determine-if-a-passed-argument-is-a-string-literal/41651/6
    public init<S: StringProtocol>(_ titleKey: S, @ViewBuilder destination: @escaping () -> Destination) where Label == Text, Value == UUID {
        self.init(destination: destination, label: { Text(titleKey) })
    }
    
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: @escaping () -> Destination) where Label == Text, Value == UUID {
        self.init(destination: destination, label: { Text(titleKey) })
    }
    
    // MARK: - Value-based:
    public init(value: Value, @ViewBuilder label: @escaping () -> Label) where Destination == Never {
        self.value = value
        self.label = label
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(_ titleKey: S, value: Value) where Label == Text, Destination == Never {
        self.init(value: value, label: { Text(titleKey) })
    }
    
    public init(_ titleKey: LocalizedStringKey, value: Value) where Label == Text, Destination == Never {
        self.init(value: value, label: { Text(titleKey) })
    }
}

extension StopwatchButtonStyleConfiguration {
    public static var sidebar: StopwatchButtonStyleConfiguration {
        var styleConfig = transparent
        
        // TODO: unify roundness!
        styleConfig.shape = RoundedRectangle(cornerRadius: 12.0, style: .circular)
        styleConfig.shapeHoverOpacity = 0.1
        styleConfig.shapePressedOpacity = 0.25
        
        styleConfig.alignment = .leading
        styleConfig.maxWidth = .infinity
        styleConfig.padding = (20.0, 14.0)
        styleConfig.pressedScale = 1.0
        
        styleConfig.labelIconSize = 26.0
        
        return styleConfig
    }
    
    internal static var navigationLinkInList: StopwatchButtonStyleConfiguration {
        var styleConfig = sidebar
        
        styleConfig.shape = Rectangle()
        styleConfig.maxHeight = .infinity
        
        return styleConfig
    }
}
