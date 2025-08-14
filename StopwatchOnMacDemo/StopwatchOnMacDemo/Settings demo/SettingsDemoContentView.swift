// StopwatchOnMacDemo::SettingsDemoContentView.swift - 02.07.2025
import SwiftUI
import StopwatchOnMac

protocol SettingsDemoPageProtocol {
    var title:          String { get }
    var iconSystemName: String { get }
    
    var backgroundColor: Color  { get set }
    var foregroundColor: Color? { get set }
    
    var children: [SettingsDemoListSection]? { get }
}

struct SettingsDemoEmptyPage: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        StopwatchList {
            Section("") {
                NavigationLink(destination: {}, label: { Label("Test #1", systemImage: "gear") })
                NavigationLink(destination: {}, label: { Label("Test #2", systemImage: "gear") })
                NavigationLink(destination: {}, label: { Label("Test #3", systemImage: "gear") })
            }
            
            Section("Content") {
                Text("< page >")
            }
        }
        //            .toolbar {
        //                ToolbarItem(placement: .navigation) {
        //                    Button {
        //                        dismiss()
        //                    } label: {
        //                        Image(systemName: "chevron.left")
        //                    }
        //                }
        //            }
    }
}

struct SettingsDemoPage<Content: View>: SettingsDemoPageProtocol, Hashable, Identifiable {
    static func == (lhs: SettingsDemoPage<Content>, rhs: SettingsDemoPage<Content>) -> Bool {
        lhs.title == rhs.title
        && lhs.iconSystemName == rhs.iconSystemName
        && lhs.backgroundColor == rhs.backgroundColor
        && lhs.foregroundColor == rhs.foregroundColor
        && lhs.children == rhs.children
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(iconSystemName)
        hasher.combine(backgroundColor)
        hasher.combine(foregroundColor)
        if let children = children {
            hasher.combine(children)
        }
    }
    
    let id = UUID()
    
    var title:          String
    var iconSystemName: String
    
    var backgroundColor: Color  = .secondary
    var foregroundColor: Color? = .white
    
    var children: [SettingsDemoListSection]? = nil
    
    @ViewBuilder var content: Content
    
    var label: SettingsDemoEntryLabel {
        SettingsDemoEntryLabel(page: self)
    }
    
    init(title: String, iconSystemName: String, backgroundColor: Color = .secondary, foregroundColor: Color? = .white,
         children: [SettingsDemoListSection]? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.children = children
        self.content = content()
    }
    
    init(title: String, iconSystemName: String, backgroundColor: Color = .secondary, foregroundColor: Color? = .white,
         children: [SettingsDemoListSection]? = nil) where Content == EmptyView {
        self.title = title
        self.iconSystemName = iconSystemName
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.children = children
        self.content = EmptyView()
    }
    
    init(title: String, iconSystemName: String, backgroundColor: Color = .secondary, foregroundColor: Color? = .white,
         children: [SettingsDemoListSection]? = nil,
         @ViewBuilder content: @escaping () -> Content) where Content == AnyView {
        self.title = title
        self.iconSystemName = iconSystemName
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.children = children
        self.content = { AnyView(content()) }()
    }
    
    init(title: String, iconSystemName: String, backgroundColor: Color = .secondary, foregroundColor: Color? = .white,
         children: [SettingsDemoListSection]? = nil) where Content == AnyView {
        self.title = title
        self.iconSystemName = iconSystemName
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.children = children
        self.content = AnyView(SettingsDemoEmptyPage())
    }
}

struct SettingsDemoEntryLabel: View, Identifiable {
    let id = UUID()
    
    let page: SettingsDemoPageProtocol
    
    var body: some View {
        Label {
            Text(page.title)
        } icon: {
            Image(systemName: page.iconSystemName)
                .symbolRenderingMode(page.foregroundColor == nil ? .multicolor : .hierarchical)
            
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            //                .font(.system(size: 18))
                .padding(5)
            
                .foregroundStyle(page.foregroundColor ?? .primary)
                .background(page.backgroundColor, in: .circle)
            
        }
    }
}

struct SettingsDemoListSection: Identifiable, Hashable {
    let id = UUID()
    let title: String? = nil
    let pages: [SettingsDemoPage<AnyView>]
}

struct SettingsDemoEntries {
    static let sidebarEntries: [SettingsDemoListSection] = [
        .init(pages: [
            .init(title: "General", iconSystemName: "gear", children: SettingsDemoEntries.generalPageEntries),
            .init(title: "Wi-Fi", iconSystemName: "wifi", backgroundColor: .blue),
            .init(title: "Network", iconSystemName: "network", backgroundColor: .blue),
            .init(title: "Notifications", iconSystemName: "bell", backgroundColor: .red),
            .init(title: "Sounds & Haptics", iconSystemName: "speaker.wave.2", backgroundColor: .red)
        ]),
        
        .init(pages: [
            .init(title: "Test #1", iconSystemName: "gear"),
            .init(title: "Test #2", iconSystemName: "gear"),
            .init(title: "Test #3", iconSystemName: "gear"),
        ])
    ]
    
    static let generalPageEntries: [SettingsDemoListSection] = [
        .init(pages:[
            .init(title: "About", iconSystemName: "macbook.gen1"),
        ]),
        .init(pages: [
            .init(title: "AutoFill & Passwords", iconSystemName: "lock.square.stack"),
            .init(title: "Dictionary", iconSystemName: "character.book.closed.fill"),
            .init(title: "Fonts", iconSystemName: "textformat"),
            .init(title: "Keyboard", iconSystemName: "keyboard.fill"),
            .init(title: "Language & Region", iconSystemName: "globe"),
        ]),
        .init(pages:[
            .init(title: "VPN & Device Management", iconSystemName: "gear", foregroundColor: .white)
        ]),
    ]
}

struct SettingsDemoContentView: View {
    @State var sidebarSelection: SettingsDemoPage<AnyView> = SettingsDemoEntries.sidebarEntries.first!.pages.first!
    
    func updateSidebarSelection(sidebarPage: SettingsDemoPage<AnyView>) {
        sidebarSelection = sidebarPage
    }
    
    var body: some View {
        StopwatchNavigationSplitView {
            StopwatchTextField(title: "Search", iconSystemName: "magnifyingglass", text: .constant(""))
                .textFieldStyle(.stopwatchSearch)
                .padding(.bottom)
            
            StopwatchList(selection: $sidebarSelection) {
                ForEach(SettingsDemoEntries.sidebarEntries) { collection in
                    Section(content: {
                        ForEach(collection.pages) { page in
                            page.label
                                .tag(page)
                        }
                    }, header: {
                        if let title = collection.title {
                            Text(title)
                        }
                    })
                }
            }
        } detail: {
            VStack {
                if let children = sidebarSelection.children {
                    StopwatchList {
                        ForEach(children) { collection in
                            Section(collection.title ?? "") {
                                ForEach(collection.pages) { entry in
                                    // FIXME: should not highlight selection when navigation inferred!
                                    StopwatchNavigationLink(destination: { entry.content }, label: {entry.label})
                                }
                            }
                        }
                    }
                } else {
                    Text("⚠️")
                    Text("No entries")
                }
            }
            .stopwatchNavigationTitle(sidebarSelection.title)
        }
    }
}
