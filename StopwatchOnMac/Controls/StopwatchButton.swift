// StopwatchOnMac::StopwatchButton.swift - 16.06.2025

import SwiftUI

public struct StopwatchButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.font)        private var fontEnvironment
    
    @Environment(\.stopwatchButtonStyleConfiguration) private var styleConfiguration
    fileprivate var styleConfigurationOverride: StopwatchButtonStyleConfiguration?
    
    @Environment(\.stopwatchButtonTint)      private var buttonTint
    @Environment(\.stopwatchButtonAlignment) private var buttonAlignment
    
    @State private var isHovering: Bool = false
    @State private var isPressed:  Bool = false
    
    private var buttonState: ButtonInteractionState {
        return isPressed ? .pressed : (isHovering ? .hovering : .idle)
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let styleConfiguration = (styleConfiguration ?? styleConfigurationOverride) ?? .default
        
        configuration.label
            .labelStyle(StopwatchButtonLabelStyle(styleConfiguration: styleConfiguration))
        
            .frame(maxWidth: styleConfiguration.maxWidth, maxHeight: styleConfiguration.maxHeight, alignment: buttonAlignment ?? styleConfiguration.alignment)
        
            .padding(.horizontal, styleConfiguration.padding.horizontal)
            .padding(.vertical,   styleConfiguration.padding.vertical)
        
            .font(styleConfiguration.font ?? fontEnvironment?.weight(.medium) ?? .body)
            .background((buttonTint ?? styleConfiguration.buttonTint).opacity(styleConfiguration.shapeIdleOpacity))

            .stopwatchHoverTarget(buttonStyleConfiguration: styleConfiguration, isPressed: $isPressed)
        
            // FIXME: use shapes correctly!
            .clipShape(AnyShape(styleConfiguration.shape))
        
            .compositingGroup()
            .scaleEffect(isPressed ? styleConfiguration.pressedScale : 1.0)
        
            .padding(.horizontal, styleConfiguration.outerPadding.horizontal)
            .padding(.vertical,   styleConfiguration.outerPadding.vertical)
        
//            .stopwatchWantsAdaptiveCursor(false)
        
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

private struct StopwatchButtonLabelStyle: LabelStyle {
    var styleConfiguration: StopwatchButtonStyleConfiguration
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.system(size: styleConfiguration.labelIconSize, weight: .bold)) // 17
            
            configuration.title
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

public struct StopwatchButtonStyleConfiguration {
    #if false
    // :AutomaticTheming
    // TODO: Initially, the idea was that style configurations could grab an "auto" configuration
    // that would return the appropriate light/dark configuration.
    // However, we can't get the colorScheme from the environment from outside a View or Style...
    // @Environment(\.colorScheme) static var colorScheme
    #endif
    
    var buttonTint: Color = .primary
    
    var shape: any Shape = Capsule()
    
    var shapeIdleOpacity:    CGFloat = 0.2
    var shapeHoverOpacity:   CGFloat = 0.25
    var shapePressedOpacity: CGFloat = 0.3
    
    func shapeOpacityForState(state: ButtonInteractionState) -> CGFloat {
        switch state {
        case .idle:     shapeIdleOpacity
        case .hovering: shapeHoverOpacity
        case .pressed:  shapePressedOpacity
        }
    }
    
    var alignment: Alignment = .center
    
    var font: Font?
    
    var maxWidth:  CGFloat? = nil
    var maxHeight: CGFloat? = nil
    var padding:      (horizontal: CGFloat, vertical: CGFloat) = (18.0, 10.0)
    var outerPadding: (horizontal: CGFloat, vertical: CGFloat) = (0.0, 0.0)
    
    var pressedScale: CGFloat = 0.95
    
    var labelIconSize: CGFloat = 17.0 // font size for icon Image
}

extension StopwatchButtonStyleConfiguration {
    #if false
    // :AutomaticTheming
    public static var auto: StopwatchButtonStyleConfiguration {
        colorScheme == .light ? .light : .dark
    }
    
    public static let light = StopwatchButtonStyleConfiguration(
        shapeIdleOpacity: 0.1,
        shapeHoverOpacity: 0.15,
        shapePressedOpacity: 0.2,
    )
    
    public static let dark = StopwatchButtonStyleConfiguration(
        shapeIdleOpacity: 0.2,
        shapeHoverOpacity: 0.25,
        shapePressedOpacity: 0.3,
    )
    #endif
    
    public static let `default` = StopwatchButtonStyleConfiguration()
    
    public static var transparent: StopwatchButtonStyleConfiguration {
        var styleConfig = `default`
        
        styleConfig.shapeIdleOpacity = 0.0
        
        return styleConfig
    }
    
    public static var circular: StopwatchButtonStyleConfiguration {
        var styleConfig = `default`
        
        // TODO: icon only label from here?
        styleConfig.shape     = Circle()
        styleConfig.padding   = (8, 8)
        styleConfig.maxWidth  = 24
        styleConfig.maxHeight = 24
        
        return styleConfig
    }
    
    public static var circularSmall: StopwatchButtonStyleConfiguration {
        var styleConfig = `default`
        
        // TODO: icon only label from here?
        styleConfig.shape     = Circle()
        styleConfig.padding   = (4, 4)
        styleConfig.maxWidth  = 18
        styleConfig.maxHeight = 18
        styleConfig.labelIconSize = 12.0
        
        return styleConfig
    }
}

// MARK: - Environment values / modifiers

private struct StopwatchButtonStyleConfigurationKey: EnvironmentKey { static let defaultValue: StopwatchButtonStyleConfiguration? = nil }

private struct StopwatchButtonTintKey:      EnvironmentKey { static let defaultValue: Color? = nil }
private struct StopwatchButtonAlignmentKey: EnvironmentKey { static let defaultValue: Alignment? = nil }

extension EnvironmentValues {
    var stopwatchButtonStyleConfiguration: StopwatchButtonStyleConfiguration? {
        get { self[StopwatchButtonStyleConfigurationKey.self] }
        set { self[StopwatchButtonStyleConfigurationKey.self] = newValue }
    }
    
    var stopwatchButtonTint: Color? {
        get { self[StopwatchButtonTintKey.self] }
        set { self[StopwatchButtonTintKey.self] = newValue }
    }
    
    var stopwatchButtonAlignment: Alignment? {
        get { self[StopwatchButtonAlignmentKey.self] }
        set { self[StopwatchButtonAlignmentKey.self] = newValue }
    }
}

extension View {
    public func stopwatchButtonStyleConfiguration(_ configuration: StopwatchButtonStyleConfiguration) -> some View {
        environment(\.stopwatchButtonStyleConfiguration, configuration)
    }
    
    public func stopwatchButtonTint(_ color: Color) -> some View {
        environment(\.stopwatchButtonTint, Color(color))
    }
    
    public func stopwatchButtonAlignment(_ alignment: Alignment) -> some View {
        environment(\.stopwatchButtonAlignment, alignment)
    }
}
