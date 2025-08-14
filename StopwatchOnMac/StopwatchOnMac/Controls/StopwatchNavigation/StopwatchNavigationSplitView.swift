// StopwatchOnMac::StopwatchSplitView.swift - 21.06.2025

import SwiftUI
import Combine

public struct StopwatchNavigationSplitView<Selection: Hashable, Sidebar: View, Content: View, Detail: View>: View {
    private var viewLinkageDetail  = SWNavigationViewLinkage()
    private var viewLinkageContent = SWNavigationViewLinkage()
    
    @State var toolbarController = SWToolbarController()
    
    @State var sidebarSelectionStore = SWSelectionStore()
    
    @State private var detailTitle: String?
    
    @Environment(\.stopwatchNavigationSplitViewDetailBackgroundTint) var detailBackgroundTint
    
    var sidebar: () -> Sidebar
    var content: () -> Content
    var detail:  () -> Detail
    
    @State var detailNavigationPath: NavigationPath = .init()
    
    public init(selection: Binding<Selection>? = nil,
                @ViewBuilder sidebar: @escaping () -> Sidebar,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail:  @escaping () -> Detail) {
        self.sidebar = sidebar
        self.content = content
        self.detail  = detail
        
        self._sidebarSelectionStore = State(
            wrappedValue: SWSelectionStore(isActive: selection != nil, selection: selection?.wrappedValue)
        )
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // TODO: do we want to force this list?
            VStack {
                sidebar()
                    .stopwatchListStyleConfiguration(.sidebar)
                    .environment(sidebarSelectionStore)
            }
            .padding(12)
            .frame(maxWidth: 315, maxHeight: .infinity, alignment: .top)
            
            // TODO: Content!
            
            let detailNavigationStackRoot = {
                Group {
                    if let view = viewLinkageDetail.view {
                        view()
                    } else {
                        AnyView(detail())
                    }
                }
                .navigationBarBackButtonHidden()
                .navigationDestination(for: SWNavigationImplicitDestinationID.self) { item in
                    SWNavigationAnyViewPathWrapper.Registry[item]?() // Implicit destination
                }
            }
                
            NavigationStack(path: $detailNavigationPath, root: detailNavigationStackRoot)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    detailBackgroundTint?
                        .ignoresSafeArea()
                        .blendMode(.softLight)
                )
            
                .safeAreaInset(edge: .top) {
                    ZStack {
                        if let title = detailTitle {
                            Text(title)
                                .font(.system(size: 22, weight: .semibold))
                        }
                        
                        SWToolbarHost()
                    }
                    .ignoresSafeArea(.all, edges: .top)
                    .frame(height: 50) // FIXME: height!
                }
                .onPreferenceChange(StopwatchNavigationTitlePreferenceKey.self) { title in
                    detailTitle = title
                }
            
                .stopwatchToolbar {
                    if !detailNavigationPath.isEmpty {
                        StopwatchToolbarItem(placement: .leading) {
                            Button {
                                if !detailNavigationPath.isEmpty { detailNavigationPath.removeLast() }
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                        }
                    }
                }
                .environment(\.stopwatchNavigationPath, $detailNavigationPath)
        }
        .environment(viewLinkageDetail)
        .environment(toolbarController)
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
                @ViewBuilder detail:  @escaping () -> Detail) where Selection == SWNavigationImplicitDestinationID {
        self.init(selection: nil, sidebar: sidebar, content: content, detail: detail)
    }
    
    public init(@ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) where Content == EmptyView, Selection == SWNavigationImplicitDestinationID {
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

struct StopwatchNavigationPathEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<NavigationPath>? = nil
}

extension EnvironmentValues {
    var stopwatchNavigationSplitViewDetailBackgroundTint: Color? {
        get { self[StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey.self] }
        set { self[StopwatchNavigationSplitViewDetailBackgroundTintEnvironmentKey.self] = newValue }
    }
    
    var stopwatchNavigationPath: Binding<NavigationPath>? {
        get { self[StopwatchNavigationPathEnvironmentKey.self] }
        set { self[StopwatchNavigationPathEnvironmentKey.self] = newValue }
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

// MARK: - Miscellaneous:

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
