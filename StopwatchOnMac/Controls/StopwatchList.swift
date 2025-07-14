// StopwatchOnMac::StopwatchList.swift - 13/07/2025
import SwiftUI

// Variadic views based on this article: https://movingparts.io/variadic-views-in-swiftui

public struct StopwatchList<Content: View, Selection: Hashable>: View {
    @Environment(\.stopwatchListStyleConfiguration) var styleConfiguration
    
    @ObservedObject var selectionStore: StopwatchNavigationSelectionStore<Selection>
    
    internal init(selectionStore: StopwatchNavigationSelectionStore<Selection>? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.selectionStore = selectionStore ?? StopwatchNavigationSelectionStore<Selection>()
        self.content = content()
    }
    
    var content: Content
    
    public var body: some View {
        ScrollView {
            _VariadicView.Tree(StopwatchListSectionLayout()) {
                content
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, styleConfiguration.padding.horizontal)
        .padding(.vertical,   styleConfiguration.padding.vertical)
        
        .stopwatchButtonStyleConfiguration(styleConfiguration.buttonStyleConfiguration)
        
        .environment(\.stopwatchListStyleConfiguration, styleConfiguration)
        .environmentObject(selectionStore)
    }
}

extension StopwatchList {
    public init(@ViewBuilder content: @escaping () -> Content) where Selection == UUID {
        self.init(selectionStore: nil, content: content)
    }
    
    // TODO: other List initializers?
    
    public init<Data, RowContent>(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent)
    where Content == ForEach<Data, Data.Element.ID, RowContent>,
          Data: RandomAccessCollection,
          RowContent : View,
          Data.Element : Identifiable,
          Selection == Data.Element.ID {
        self.init(selectionStore: nil) {
            // TODO: not entirely sure about this one, but it does work:
            ForEach(data, id: \.id) { element in
                rowContent(element)
            }
        }
    }
}

// This identifies sections specifically, so that the list layouts will not give them entry backgrounds:
internal struct StopwatchListSectionID: Hashable, Codable, Sendable {
    let rawValue: UUID
    
    init() { self.rawValue = UUID() }
}

public struct StopwatchListSection<Label: View, Content: View>: View {
    @Environment(\.stopwatchListStyleConfiguration) var styleConfiguration
    
    let id = StopwatchListSectionID()
    var label: Label?
    var content: Content
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let label = label {
                label
                    .font(.title2).bold()
                    .padding(.horizontal, styleConfiguration.sectionLabelPadding.horizontal)
                    .padding(.vertical, styleConfiguration.sectionLabelPadding.vertical)
            }
            
            _VariadicView.Tree(StopwatchListSectionLayout()) { content }
        }
        .padding(.bottom)
        .id(id) // This acts as a special identifier for sections, so that they get no background!
    }
}

extension StopwatchListSection {
    public init(@ViewBuilder content: @escaping () -> Content) where Label == Never {
        self.content = content()
    }
    
    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.content = content()
        self.label = label()
    }
    
    // TODO: LocalizedStringKey variants!
    
    // TODO: is it a good idea to re-use the above initializer, using a { } ViewBuilder to create the Text instead of
    // directly doing `label: Text(...)`? Is there a difference?
    public init(_ title: String, @ViewBuilder content: @escaping () -> Content) where Label == Text {
        self.init(content: content, label: { Text(title) })
    }
}

internal struct StopwatchListSectionLayout: _VariadicView_MultiViewRoot {
    @Environment(\.stopwatchListStyleConfiguration) var styleConfiguration
    
    @ViewBuilder func body(children: _VariadicView.Children) -> some View {
        let last  = children.last?.id
        
        LazyVStack(spacing: 0) {
            ForEach(children) { child in
                let isSection = child.id as? StopwatchListSectionID != nil // Don't give section containers backgrounds!
                
                child
                    .frame(minHeight: styleConfiguration.rowMinHeight)
                    .background(isSection ? .clear : styleConfiguration.sectionBackgroundTint)
                
                if styleConfiguration.rowSeparatorEnabled &&
                    !isSection && // Don't draw a divider between sections!
                    child.id != last {
                    Divider()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: styleConfiguration.sectionCornerRadius))
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.bottom, 4)
        
    }
}

public struct StopwatchListStyleConfiguration {
    var buttonStyleConfiguration: StopwatchButtonStyleConfiguration = .navigationLinkInList
    
    var rowSeparatorEnabled: Bool    = true
    var rowMinHeight:        CGFloat = 56.0 // Measured StopwtachNavigationLink (by padding, through .onGeometryChange)
    
    var sectionCornerRadius:   CGFloat = 16.0
    var sectionBackgroundTint: Color   = .black.opacity(0.3)
    var sectionLabelPadding: (horizontal: CGFloat, vertical: CGFloat) = (18.0, 4.0)
    
    var spacing: CGFloat = 0.0
    var padding: (horizontal: CGFloat, vertical: CGFloat) = (64.0, 0.0)
}

extension StopwatchListStyleConfiguration {
    public static var `default` = StopwatchListStyleConfiguration()
    
    public static var sidebar: Self {
        var styleConfig = `default`
        
        styleConfig.buttonStyleConfiguration = .sidebar
        styleConfig.rowSeparatorEnabled = false
        styleConfig.sectionBackgroundTint = .clear
        styleConfig.sectionCornerRadius = 0
        styleConfig.padding = (0.0, 0.0)
        styleConfig.spacing = 4.0
        
        return styleConfig
    }
}

public struct StopwatchListStyleConfigurationEnvironmentKey: EnvironmentKey {
    public static var defaultValue: StopwatchListStyleConfiguration = .default
}

extension EnvironmentValues {
    var stopwatchListStyleConfiguration: StopwatchListStyleConfiguration {
        get { self[StopwatchListStyleConfigurationEnvironmentKey.self] }
        set { self[StopwatchListStyleConfigurationEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func stopwatchListStyleConfiguration(_ style: StopwatchListStyleConfiguration) -> some View {
        self.environment(\.stopwatchListStyleConfiguration, style)
    }
}
