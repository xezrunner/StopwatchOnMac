// StopwatchOnMac::StopwatchButton.swift - 16.06.2025

import SwiftUI

private struct StopwatchButtonTintKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

private struct StopwatchButtonStyleConfigurationKey: EnvironmentKey {
    static let defaultValue: StopwatchButtonStyleConfiguration? = nil
}

extension EnvironmentValues {
    var stopwatchButtonTint: Color? {
        get { self[StopwatchButtonTintKey.self] }
        set { self[StopwatchButtonTintKey.self] = newValue }
    }
    
    var stopwatchButtonStyleConfiguration: StopwatchButtonStyleConfiguration? {
        get { self[StopwatchButtonStyleConfigurationKey.self] }
        set { self[StopwatchButtonStyleConfigurationKey.self] = newValue }
    }
}

extension View {
    func stopwatchButtonTint(_ color: Color) -> some View {
        environment(\.stopwatchButtonTint, Color(color))
    }
    
    func stopwatchButtonStyleConfiguration(_ configuration: StopwatchButtonStyleConfiguration) -> some View {
        environment(\.stopwatchButtonStyleConfiguration, configuration)
    }
}


public struct StopwatchButtonStyle: ButtonStyle {
    @Environment(\.colorScheme)         private var colorScheme
    
    @Environment(\.stopwatchButtonTint)               private var buttonTint
    @Environment(\.stopwatchButtonStyleConfiguration) private var styleConfiguration
    
    @State private var isHovering: Bool = false
    @State private var isPressed:  Bool = false
    
    var maxWidth: CGFloat? = nil
    
    private var buttonState: ButtonInteractionState {
        return isPressed ? .pressed : (isHovering ? .hovering : .idle)
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let styleConfiguration: StopwatchButtonStyleConfiguration = styleConfiguration ?? .auto(colorScheme: colorScheme)
        
        configuration.label
            .labelStyle(StopwatchButtonLabelStyle())
        
            .frame(maxWidth: maxWidth)
        
            .padding(.horizontal, styleConfiguration.padding.horizontal)
            .padding(.vertical,   styleConfiguration.padding.vertical)
        
            .fontWeight(.medium)
            .background((buttonTint ?? .primary).opacity(styleConfiguration.shapeIdleOpacity))

            .stopwatchHoverTarget(isPressed: $isPressed)
        
            .clipShape(.capsule)
            .scaleEffect(isPressed ? styleConfiguration.pressedScale : 1.0)
        
            .stopwatchWantsAdaptiveCursor(false)
        
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(SWAnimationLibrary.buttonPressAnimation) { isPressed = newValue }
            }
    }
}

private struct StopwatchButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.system(size: 17))
            
            configuration.title
        }
    }
}

struct StopwatchButtonStyleConfiguration {
    @Environment(\.colorScheme) static var colorScheme
    
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
    
    var padding: (horizontal: CGFloat, vertical: CGFloat) = (18.0, 10.0)
    var pressedScale: CGFloat = 0.95
}

extension StopwatchButtonStyleConfiguration {
    static func auto(colorScheme: ColorScheme) -> StopwatchButtonStyleConfiguration {
        colorScheme == .light ? .light : .dark
    }
    
    static let light = StopwatchButtonStyleConfiguration(
        shapeIdleOpacity: 0.1,
        shapeHoverOpacity: 0.15,
        shapePressedOpacity: 0.2,
    )
    
    static let dark = StopwatchButtonStyleConfiguration(
        shapeIdleOpacity: 0.2,
        shapeHoverOpacity: 0.25,
        shapePressedOpacity: 0.3,
    )
}

