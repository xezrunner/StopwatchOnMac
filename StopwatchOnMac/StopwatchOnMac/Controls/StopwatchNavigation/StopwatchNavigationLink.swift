// StopwatchOnMacDemo::StopwatchNavigationLink.swift - 14/07/2025
import SwiftUI

public struct SWNavigationImplicitDestinationID: RawRepresentable, Hashable, Identifiable {
    public let rawValue: UUID
    public var id: UUID { rawValue }

    public init() { rawValue = .init() }
    public init(rawValue: UUID) { self.rawValue = rawValue }
}

internal struct SWNavigationAnyViewPathWrapper: Hashable {
    public let id = SWNavigationImplicitDestinationID()
    
    static var Registry = [SWNavigationImplicitDestinationID: () -> AnyView]()
    
    init<V: View>(_ view: @escaping () -> V) {
        SWNavigationAnyViewPathWrapper.Registry[id] = { AnyView(view()) }
    }
}

public struct StopwatchNavigationLink<Destination: View, Label: View, Value: Hashable>: View {
    @Environment(\.stopwatchNavigationPath)           private var navigationPath
    @Environment(\.stopwatchButtonStyleConfiguration) private var buttonStyleConfigurationEnvironment

    @Environment(SWSelectionStore.self) private var selectionStore
    
    @Environment(SWNavigationViewLinkage.self) var viewLinkage
    var destination: (() -> Destination)?
    
    var label: () -> Label
    
    var value: Value?
    // If no value is given, generate a unique ID for each link and use it as selection:
    @State var _destinationImplicitID: Value?
    
    public var body: some View {
        Button(action: navigate) {
            HStack {
                label()
                
                if (value != nil || _destinationImplicitID != nil) {
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                }
            }
        }
            .stopwatchButtonStyleConfiguration(!isSelected ? buttonStyleConfiguration : selectedStyleConfiguration)
    }
    
    var isSelected: Bool {
        if !selectionStore.isActive { return false }
        
        // TODO: edge cases!
        if let value = value ?? _destinationImplicitID {
            let selection = selectionStore.selection as? Value ?? nil
            return selection == value
        }
        return false
    }
    
    private func navigate() {
        if let destination = destination {
            let wrapper = SWNavigationAnyViewPathWrapper(destination)
            navigationPath?.wrappedValue.append(wrapper.id)
        } else { print("StopwatchNavigationLink: no destination, skipping navigation") }
        
        if let value = value ?? _destinationImplicitID {
            selectionStore.selection = value
        }
    }
    
    private var buttonStyleConfiguration: StopwatchButtonStyleConfiguration {
        buttonStyleConfigurationEnvironment ?? .list
    }
    
    private var selectedStyleConfiguration: StopwatchButtonStyleConfiguration {
        var configuration: StopwatchButtonStyleConfiguration = buttonStyleConfiguration
        
        configuration.shapeIdleOpacity = 0.25
        
        return configuration
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
    public init(@ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: @escaping () -> Label) where Value == SWNavigationImplicitDestinationID {
        self.destination = destination
        self._destinationImplicitID = .init()
        self.label = label
    }
    
    @_disfavoredOverload // https://forums.swift.org/t/how-to-determine-if-a-passed-argument-is-a-string-literal/41651/6
    public init<S: StringProtocol>(_ titleKey: S, @ViewBuilder destination: @escaping () -> Destination) where Label == Text, Value == SWNavigationImplicitDestinationID {
        self.init(destination: destination, label: { Text(titleKey) })
    }
    
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: @escaping () -> Destination) where Label == Text, Value == SWNavigationImplicitDestinationID {
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
