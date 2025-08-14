// StopwatchOnMac::StopwatchList.swift - 13/07/2025
import SwiftUI

// TODO: Move Selection Store related stuff to another file (?)
@Observable internal class SWSelectionStore {
    var isActive = false
    var selection: AnyHashable? = nil
    
    init(isActive: Bool = false, selection: AnyHashable? = nil) {
        self.isActive = isActive
        self.selection = selection
    }
}

extension EnvironmentValues {
    @Entry internal var stopwatchSelectionStore = SWSelectionStore()
    @Entry internal var stopwatchListSelectionEntry: AnyHashable?
}

public struct StopwatchList<Content: View, Selection: Hashable>: View {
    @Environment(\.stopwatchListStyleConfiguration) private var styleConfiguration
    
    @ViewBuilder public var content: Content
    
    @State private var selectionStoreEnvironment: SWSelectionStore = .init()
    var userSelectionBinding: Binding<Selection?>?
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(sections: content) { section in
                    StopwatchListSection(sectionConfiguration: section)
                }
                .environment(\.stopwatchButtonStyleConfiguration, styleConfiguration.buttonStyleConfiguration)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, styleConfiguration.padding.horizontal)
        .padding(.vertical,   styleConfiguration.padding.vertical)
        
        .onChange(of: selectionStoreEnvironment.selection) { oldValue, newValue in
            updateUserSelectionFromEnvironment(newValue: newValue)
        }
        .onAppear {
            if let binding = userSelectionBinding {
                selectionStoreEnvironment.isActive = true
                selectionStoreEnvironment.selection = binding.wrappedValue
            }
        }

        #if false
        .overlay {
            VStack(alignment: .leading) {
                Text("env selection : isActive: \(selectionStoreEnvironment.isActive.description)  selection: \(selectionStoreEnvironment.selection?.debugDescription ?? "")")
                Text("user selection: \(userSelectionBinding.debugDescription)")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .monospaced().font(.system(size: 10))
        }
        #endif
        
        .environment(selectionStoreEnvironment)
        .environment(\.stopwatchListStyleConfiguration, styleConfiguration)
    }
    
    func updateUserSelectionFromEnvironment(newValue: AnyHashable?) {
        if let binding = userSelectionBinding {
            guard let converted = newValue as? Selection else {
                Log("⚠️ Conversion from selection store to user selection binding failed.")
                return
            }
            binding.wrappedValue = converted
        }
    }
}

extension StopwatchList {
    public init(@ViewBuilder content: @escaping () -> Content) where Selection == Never {
        self.content = content()
    }
    
    // with Selection:
    // TODO: might not want to let you do this, since there isn't really a good way to infer the selection from the subviews given.
    // The use case wanted to be nested lists, but with a top-level selection within StopwatchList.
    #if true
    public init<UserContent: View>(selection: Binding<Selection>, @ViewBuilder content: @escaping () -> UserContent)
    where Content ==
    ForEach<ForEachSectionCollection<Section<SubviewsCollection, ForEach<ForEachSubviewCollection<_StopwatchListContentSelectionWrapper<Subview, Selection>>, Subview.ID, _StopwatchListContentSelectionWrapper<Subview, Selection>>, EmptyView>>, SectionConfiguration.ID, Section<SubviewsCollection, ForEach<ForEachSubviewCollection<_StopwatchListContentSelectionWrapper<Subview, Selection>>, Subview.ID, _StopwatchListContentSelectionWrapper<Subview, Selection>>, EmptyView>> // wow... (Xcode gave us this monstrosity)
    {
        self.content = {
            ForEach(sections: content()) { section in
                // We have to go through the sections ourselves, so that we both support Sections, as well as wrap entries for implicit selection:
                Section {
                    ForEach(subviews: section.content) { subview in
                        // ⚠️ The value for selection (view tag you provide) and the selection type have to be consistent
                        // (including whether it is optional or not) in order for selection wrapping with valueForSelection: to work!
                        // TODO: changing .tag(for:) here to Selection instead of Selection? made it work.
                        _StopwatchListContentSelectionWrapper(valueForSelection: subview.containerValues.tag(for: Selection.self)) {
                            subview
                        }
                    }
                } header: {
                    section.header
                }

            }
        }()
        
        // Convert the non-optional selection binding to one that's technically optional
        // This won't make the selection optional
        let selectionBinding = Binding(
            get: { selection.wrappedValue as Selection? },
            set: {
                if let newValue = $0 { selection.wrappedValue = newValue }
            }
        )
        self.userSelectionBinding = selectionBinding
    }
    
    //    public init(selection: Binding<Selection>, @ViewBuilder content: @escaping () -> Content) {
    //        //self.content = content()
    //
    //        // Convert the non-optional selection binding to one that's technically optional
    //        // This won't make the selection optional
    //        let selectionBinding = Binding(
    //            get: { selection.wrappedValue as Selection? },
    //            set: {
    //                if let newValue = $0 { selection.wrappedValue = newValue }
    //            }
    //        )
    //        self.userSelectionBinding = selectionBinding
    //    }
    #endif
    
    public init(selection: Binding<Selection?>?, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.userSelectionBinding = selection
    }
    
    // Collection-based:
    
    // Without selection:
    public init<Data, RowContent>(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent)
    where Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data: RandomAccessCollection,
    RowContent : View,
    Data.Element : Identifiable,
    Selection == Data.Element.ID {
        self.init() {
            ForEach(data, id: \.id) { element in
                rowContent(element)
            }
        }
    }
    
    // Inferred ID, with optional selection:
    public init<Data, RowContent>(_ data: Data, selection: Binding<Selection?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent)
    where Content == ForEach<Data, Data.Element.ID, _StopwatchListContentSelectionWrapper<RowContent, Selection>>,
    Data: RandomAccessCollection, Data.Element: Hashable,
    RowContent : View,
    Data.Element : Identifiable,
    Selection == Data.Element {
        self.init(selection: selection) {
            ForEach(data, id: \.id) { element in
                _StopwatchListContentSelectionWrapper(valueForSelection: element) {
                    rowContent(element)
                }
            }
        }
    }
    
    // Inferred ID, with non-optional selection:
    public init<Data, RowContent>(_ data: Data, selection: Binding<Selection>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent)
    where Content == ForEach<Data, Data.Element.ID, _StopwatchListContentSelectionWrapper<RowContent, Selection>>,
    Data: RandomAccessCollection, Data.Element: Hashable,
    RowContent : View,
    Data.Element : Identifiable,
    Selection == Data.Element {
        let selectionBinding = Binding(
            get: { selection.wrappedValue as Selection? },
            set: {
                if let newValue = $0 { selection.wrappedValue = newValue }
            }
        )
        
        self.init(selection: selectionBinding) {
            ForEach(data, id: \.id) { element in
                _StopwatchListContentSelectionWrapper(valueForSelection: element) {
                    rowContent(element)
                }
            }
        }
    }
    
    public init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        selection: Binding<Selection?>?,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    )
    where Content == ForEach<Data, ID, _StopwatchListContentSelectionWrapper<RowContent, Data.Element>>,
    Data : RandomAccessCollection, Data.Element: Hashable,
    ID : Hashable,
    RowContent : View {
        self.init(selection: selection) {
            ForEach(data, id: id) { element in
                _StopwatchListContentSelectionWrapper(valueForSelection: element) {
                    rowContent(element)
                }
            }
        }
    }
}

internal struct StopwatchListSection: View {
    @Environment(\.stopwatchListStyleConfiguration) var listStyleConfiguration
    
    var sectionConfiguration: SectionConfiguration
    
    public var body: some View {
        VStack(alignment: .leading) {
            if !sectionConfiguration.header.isEmpty {
                sectionConfiguration.header
                    .font(.title2).bold()
                    .padding(.horizontal, listStyleConfiguration.sectionLabelPadding.horizontal)
                    .padding(.vertical,   listStyleConfiguration.sectionLabelPadding.vertical)
            }
            
            StopwatchListSectionLayout {
                sectionConfiguration.content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: listStyleConfiguration.sectionCornerRadius))
        }
    }
}

internal struct StopwatchListSectionLayout<Content: View>: View {
    @Environment(\.stopwatchListStyleConfiguration) var listStyleConfiguration
    
    @ViewBuilder var content: Content
    
    @Environment(\.stopwatchSelectionStore) var selectionStore
    
    var body: some View {
        LazyVStack(spacing: 0) {
            Group(subviews: content) { subviews in
                let count  = subviews.count
                let lastID = subviews.last?.id
                
                ForEach(subviews: subviews) { subview in
                    let id = subview.id
                    
                    subview
                        .padding(.horizontal, listStyleConfiguration.sectionLabelPadding.horizontal)
                        .padding(.vertical,   listStyleConfiguration.sectionLabelPadding.vertical)
                        .frame(maxWidth: .infinity, minHeight: listStyleConfiguration.rowMinHeight, alignment: .leading)
                        .background(listStyleConfiguration.sectionBackgroundTint)
                    
                        .environment(selectionStore)
//                     .overlay { Text("last: \(lastID!.hashValue)  id: \(id.hashValue)").font(.callout) }
                    
                    if listStyleConfiguration.rowSeparatorEnabled && count > 1 && id != lastID {
                        Divider().foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

// This view acts as a wrapper for items within lists that facilitate selection.
// It will make every item into a Button that will change selection when tapped.
//
// FIXME: If buttons are put in as content, there will be two buttons in the containers.
// FIXME: This is bad in cases where StopwatchNavigationLinks are put in, as they are also
// buttons.
public struct _StopwatchListContentSelectionWrapper<Content: View, Selection: Hashable>: View {
    @Environment(\.stopwatchListStyleConfiguration) private var listStyleConfiguration
    @Environment(SWSelectionStore.self)             private var selectionStore
    
    public let valueForSelection: Selection?
    
    @ViewBuilder public var content: Content
    
    private let buttonWrapIgnoreTypeNameContainsList = ["Button", "NavigationLink"]
    private var shouldWrapInButton: Bool = true
    
    public init(valueForSelection: Selection?, @ViewBuilder content: @escaping () -> Content) {
        self.valueForSelection = valueForSelection
        self.content = content()
        
        // FIXME: there might be cases where the users intends to have an intentional nil selection for an entry...
        // We check for 'nil' here to not wrap Sections for implicit selection:
        if valueForSelection == nil {
            shouldWrapInButton = false; return
        }
        
        // Determine whether to wrap an entry into a selection button.
        // TODO: this is kind of jank... It might be more beneficial to wrap these controls as well,
        // perhaps with adjusted padding so that they look normal, or just wrap them regardless and only warn you.
        let typeName = "\(type(of: content))"
        for it in buttonWrapIgnoreTypeNameContainsList {
            if typeName.contains(it) {
                Log("""
                    ⚠️ Found a view of type `\(typeName)` in a StopwatchList that facilitates selection. This view will not be automatically transformed for implicit entry selection.
                    Use Text, Label or some other non-interactive view for StopwatchLists that facilitate selection.  
                    """)
                self.shouldWrapInButton = false
                break
            }
        }
    }
    
    var isSelected: Bool {
        selectionStore.selection as? Selection == valueForSelection
    }
    
    func select() {
        if !selectionStore.isActive { return }
        selectionStore.selection = valueForSelection
    }
    
    var buttonStyleConfigForFilledSelectionStyle: StopwatchButtonStyleConfiguration {
        var config = listStyleConfiguration.buttonStyleConfiguration
        
        if listStyleConfiguration.selectionIndicatorStyle.contains(.tint) {
            config.shapeIdleOpacity = isSelected ? 0.2 : 0
        }
        
        return config
    }
    
    public var body: some View {
        Group {
            if shouldWrapInButton {
                Button(action: select) {
                    HStack {
                        content
                        if listStyleConfiguration.selectionIndicatorStyle.contains(.checkmark) {
                            Spacer()
                            if isSelected { Image(systemName: "checkmark") }
                        }
                    }
                }
                .stopwatchButtonStyleConfiguration(buttonStyleConfigForFilledSelectionStyle)
            } else {
                content
            }
        }
    }
}

// MARK: - Miscellaneous

public struct StopwatchListSelectionIndicatorStyle: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public func contains(_ style: StopwatchListSelectionIndicatorStyle) -> Bool {
        return (self.rawValue & style.rawValue) == style.rawValue
    }
    
    public static let checkmark = StopwatchListSelectionIndicatorStyle(rawValue: 1 << 0)
    public static let tint      = StopwatchListSelectionIndicatorStyle(rawValue: 1 << 1)
}

public struct StopwatchListStyleConfiguration {
    public var buttonStyleConfiguration: StopwatchButtonStyleConfiguration = .list
    
    public var rowSeparatorEnabled: Bool    = true
    public var rowMinHeight:        CGFloat = 56.0 // Measured StopwtachNavigationLink (by padding, through .onGeometryChange)
    
    public var sectionCornerRadius:   CGFloat = 16.0
    public var sectionBackgroundTint: Color   = .black.opacity(0.3)
    public var sectionLabelPadding: (horizontal: CGFloat, vertical: CGFloat) = (18.0, 0.0) // TODO: naming
    
    public var selectionIndicatorStyle: StopwatchListSelectionIndicatorStyle = .checkmark
    
    public var spacing: CGFloat = 0.0
    public var padding: (horizontal: CGFloat, vertical: CGFloat) = (60.0, 0.0)
    
    public static var `default` = StopwatchListStyleConfiguration()
    
    public static var defaultWithTintSelection: Self {
        var styleConfig = `default`
        
        styleConfig.selectionIndicatorStyle = .tint
        
        return styleConfig
    }
    
    public static var sidebar: Self {
        var styleConfig = `default`
        
        styleConfig.buttonStyleConfiguration = .sidebar
        
        styleConfig.rowSeparatorEnabled = false
        styleConfig.sectionBackgroundTint = .clear
        styleConfig.sectionCornerRadius = 0
        styleConfig.sectionLabelPadding = (0.0, 0.0)
        
        styleConfig.padding = (0.0, 0.0)
        styleConfig.spacing = 4.0
        
        styleConfig.selectionIndicatorStyle = .tint
        
        return styleConfig
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
        
        styleConfig.font = .system(size: 16)
        styleConfig.labelIconSize = 26.0
        
        return styleConfig
    }
    
    public static var list: StopwatchButtonStyleConfiguration {
        var styleConfig = sidebar
        
        styleConfig.shape = Rectangle()
        styleConfig.maxHeight = .infinity
        // TODO: these should line up with listStyleConfiguration.sectionLabelPadding:
        styleConfig.padding = (18.0, 0) // HACK!
        styleConfig.outerPadding = (-18.0, 0) // HACK! negative padding to offset for automatic list section layout padding
        
        return styleConfig
    }
}

extension EnvironmentValues {
    @Entry var stopwatchListStyleConfiguration: StopwatchListStyleConfiguration = .default
}

extension View {
    public func stopwatchListStyleConfiguration(_ style: StopwatchListStyleConfiguration) -> some View {
        self.environment(\.stopwatchListStyleConfiguration, style)
    }
}

