// StopwatchOnMac::StopwatchButton.swift - 16.06.2025

import SwiftUI

struct StopwatchButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    @State var isHovering: Bool = false
    @State var isPressed:  Bool = false
    
    private var buttonState: ButtonInteractionState {
        return isPressed ? .pressed : (isHovering ? .hovering : .idle)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let styleConfiguration: StopwatchButtonStyleConfiguration = .auto(colorScheme: colorScheme)
        
        configuration.label
            .padding(.horizontal, styleConfiguration.padding.horizontal)
            .padding(.vertical,   styleConfiguration.padding.vertical)
        
            .fontWeight(.medium)
            .background(.primary.opacity(styleConfiguration.shapeIdleOpacity))

            .stopwatchHoverTarget(isPressed: $isPressed)
        
            .clipShape(.capsule)
            .scaleEffect(isPressed ? styleConfiguration.pressedScale : 1.0)
        
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(SWAnimationLibrary.buttonPressAnimation) { isPressed = newValue }
            }
    }
}

struct StopwatchButtonStyleConfiguration {
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
    
    var padding: (horizontal: CGFloat, vertical: CGFloat) = (18.0, 8.0)
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
