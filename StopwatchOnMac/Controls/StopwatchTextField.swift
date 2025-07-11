// StopwatchOnMac::StopwatchTextField.swift - 11/07/2025
import SwiftUI

public struct StopwatchTextField<Icon: View, Title: View>: View {
    @ViewBuilder var icon:  () -> Icon
    @ViewBuilder var title: () -> Title
    @Binding var text:  String
    var isClearable:    Bool = false
    
    public var body: some View {
        TextField(text: _text) {
            Label(title: title, icon: icon)
        }
        .stopwatchTextFieldClearable(isClearable ? _text : nil)
    }
}

extension StopwatchTextField {
    public init(text: Binding<String>, isClearable: Bool = false, @ViewBuilder title: @escaping () -> Title, @ViewBuilder icon: @escaping () -> Icon) {
        self.icon  = icon
        self.title = title
        self._text  = text
        self.isClearable = isClearable
    }
    
    public init(title: String, iconSystemName: String, isClearable: Bool = false, text: Binding<String>) where Icon == Image, Title == Text {
        self.icon  = { Image(systemName: iconSystemName) }
        self.title = { Text(title) }
        self._text  = text
        self.isClearable = isClearable
    }
    
    public init(title: String, isClearable: Bool = false, text: Binding<String>) where Icon == EmptyView, Title == Text {
        self.icon  = { EmptyView() }
        self.title = { Text(title) }
        self._text  = text
        self.isClearable = isClearable
    }
}

public struct StopwatchTextFieldStyle: TextFieldStyle {
    @Environment(\.stopwatchTextFieldIcon)      var textFieldIcon
    @Environment(\.stopwatchTextFieldClearable) var textFieldClearableBinding
    
    @State      var isFocusable = false
    @FocusState var isFocused
    
    public init() {}
    
    func focusTextField() {
        isFocusable = true
        isFocused = true
    }
    
    func clearTextField() {
        if let textBinding = textFieldClearableBinding {
            textBinding.wrappedValue = ""
        } else { Log("No binding for clearable text field, yet we want to clear the TextField...") }
    }
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        Button(action: focusTextField) {
            HStack {
                // Icon:
                if let icon = textFieldIcon {
                    icon
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
                
                // TextField:
                configuration
                    // FIXME: plain style text field moves up when focused for some reason!
                    .textFieldStyle(.plain)
                    .padding(.leading, 4)
                
                    .focused($isFocused)
                    .focusable(isFocusable)
                    .onChange(of: isFocused, { _ , newValue in
                        if newValue == false { isFocusable = false }
                    })
                
                    .allowsHitTesting(isFocused)
                
                    .onKeyPress(.escape) {
                        _UnfocusAllViews()
                        return .handled
                    }
                
                // Clear button:
                if isFocused && textFieldClearableBinding != nil {
                    Button(action: clearTextField) {
                        Label(title: {}, icon: { Image(systemName: "xmark") })
                    }
                    .stopwatchButtonStyleConfiguration(.circularSmall)
                }
            }
        }
        .buttonStyle(StopwatchTextFieldRoundedButtonStyle(isTextFieldFocused: _isFocused))
    }
}

private struct StopwatchTextFieldRoundedButtonStyle: ButtonStyle {
    @FocusState var isTextFieldFocused
    @State      var isPressed = false
    
    func makeBody(configuration: Configuration) -> some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
            .overlay(border)
        
            .stopwatchHoverTarget(isPressed: $isPressed)
            .onChange(of: configuration.isPressed) { old, new in self.isPressed = new }
        
            .allowsHitTesting(!isTextFieldFocused)
        
            .overlay {
                // This is overlaid, so that the text field can be right-clicked and interacted with normally
                // once focused.
                
                configuration.label
                    .padding(.horizontal, 8)
            }
        
            .clipShape(.capsule)
        
            .padding(8)
    }
    
    var border: some View {
        let borderGradient = LinearGradient(colors: [
            .black.opacity(0.3),
            .white.opacity(1)
        ], startPoint: .top, endPoint: .bottom)
        
        let innerShadow = Color.white.shadow(
            .inner(color: .black.opacity(0.05), radius: 2, x: -1, y: 1.5)
        ).blendMode(.plusDarker) // plusDarker here makes the white disappear, while keeping the shadow
        
        return Capsule()
            .strokeBorder(borderGradient, lineWidth: 1.3)
            .background(innerShadow, in: .capsule)
            .blendMode(.softLight)
    }
}

internal struct StopwatchTextFieldIconEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Image? = nil
}

internal struct StopwatchTextFieldClearableEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Binding<String>? = nil
}

extension EnvironmentValues {
    public var stopwatchTextFieldIcon: Image? {
        get { self[StopwatchTextFieldIconEnvironmentKey.self] }
        set { self[StopwatchTextFieldIconEnvironmentKey.self] = newValue }
    }
    
    public var stopwatchTextFieldClearable: Binding<String>? {
        get { self[StopwatchTextFieldClearableEnvironmentKey.self] }
        set { self[StopwatchTextFieldClearableEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func stopwatchTextFieldIcon(systemName: String) -> some View {
        self.environment(\.stopwatchTextFieldIcon, Image(systemName: systemName))
    }
    
    public func stopwatchTextFieldIcon(image: Image) -> some View {
        self.environment(\.stopwatchTextFieldIcon, image)
    }
    
    public func stopwatchTextFieldClearable(_ text: Binding<String>?) -> some View {
        self.environment(\.stopwatchTextFieldClearable, text)
    }
}
