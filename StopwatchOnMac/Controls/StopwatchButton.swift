// StopwatchOnMac::StopwatchButton.swift - 16.06.2025

import SwiftUI

public struct StopwatchButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
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
            .labelStyle(StopwatchButtonLabelStyle())
        
            .frame(maxWidth: styleConfiguration.maxWidth, alignment: buttonAlignment)
        
            .padding(.horizontal, styleConfiguration.padding.horizontal)
            .padding(.vertical,   styleConfiguration.padding.vertical)
        
            .fontWeight(.medium)
            .background((buttonTint ?? .primary).opacity(styleConfiguration.shapeIdleOpacity))

            .stopwatchHoverTarget(isPressed: $isPressed)
        
            .clipShape(AnyShape(styleConfiguration.shape))
        
            .compositingGroup()
            .scaleEffect(isPressed ? styleConfiguration.pressedScale : 1.0)
        
//            .stopwatchWantsAdaptiveCursor(false)
        
            .onChange(of: configuration.isPressed) { _, newValue in
                 withAnimation(SWAnimationLibrary.buttonPressAnimation) { isPressed = newValue }
            }
            .animation(SWAnimationLibrary.buttonPressAnimation, value: isPressed)
    }
}

private struct StopwatchButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.system(size: 17))
            
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
    
    var shapeIdleOpacity:    CGFloat
    var shapeHoverOpacity:   CGFloat
    var shapePressedOpacity: CGFloat
    
    func shapeOpacityForState(state: ButtonInteractionState) -> CGFloat {
        switch state {
        case .idle:     shapeIdleOpacity
        case .hovering: shapeHoverOpacity
        case .pressed:  shapePressedOpacity
        }
    }
    
    var maxWidth: CGFloat? = nil
    var padding: (horizontal: CGFloat, vertical: CGFloat) = (18.0, 10.0)
    var pressedScale: CGFloat = 0.95
    
    var shape: any Shape = Capsule()
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
    
    public static let `default` = StopwatchButtonStyleConfiguration(
        shapeIdleOpacity: 0.2,
        shapeHoverOpacity: 0.25,
        shapePressedOpacity: 0.3,
    )
    
    public static var transparent: StopwatchButtonStyleConfiguration {
        var styleConfig = `default`
        
        styleConfig.shapeIdleOpacity = 0.0
        
        return styleConfig
    }
    
    public static var sidebar: StopwatchButtonStyleConfiguration {
        var styleConfig = transparent
        
        styleConfig.shape = RoundedRectangle(cornerRadius: 10.0, style: .continuous)
        styleConfig.maxWidth = .infinity
        styleConfig.padding = (12.0, 12.0)
        
        return styleConfig
    }
}

// MARK: - Environment values / modifiers

private struct StopwatchButtonStyleConfigurationKey: EnvironmentKey { static let defaultValue: StopwatchButtonStyleConfiguration? = nil }

private struct StopwatchButtonTintKey:      EnvironmentKey { static let defaultValue: Color? = nil }
private struct StopwatchButtonAlignmentKey: EnvironmentKey { static let defaultValue: Alignment = .center }

extension EnvironmentValues {
    var stopwatchButtonStyleConfiguration: StopwatchButtonStyleConfiguration? {
        get { self[StopwatchButtonStyleConfigurationKey.self] }
        set { self[StopwatchButtonStyleConfigurationKey.self] = newValue }
    }
    
    var stopwatchButtonTint: Color? {
        get { self[StopwatchButtonTintKey.self] }
        set { self[StopwatchButtonTintKey.self] = newValue }
    }
    
    var stopwatchButtonAlignment: Alignment {
        get { self[StopwatchButtonAlignmentKey.self] }
        set { self[StopwatchButtonAlignmentKey.self] = newValue }
    }
}

extension View {
    func stopwatchButtonStyleConfiguration(_ configuration: StopwatchButtonStyleConfiguration) -> some View {
        environment(\.stopwatchButtonStyleConfiguration, configuration)
    }
    
    func stopwatchButtonTint(_ color: Color) -> some View {
        environment(\.stopwatchButtonTint, Color(color))
    }
    
    func stopwatchButtonAlignment(_ alignment: Alignment) -> some View {
        environment(\.stopwatchButtonAlignment, alignment)
    }
}
