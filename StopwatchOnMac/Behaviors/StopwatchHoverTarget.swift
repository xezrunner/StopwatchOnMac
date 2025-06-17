// StopwatchOnMac::StopwatchHoverTarget.swift - 17.06.2025

import SwiftUI

internal struct SWHoverTargetViewModifier: ViewModifier {
    @State private var localMousePoint: UnitPoint = .zero
    @State private var currentSize: CGSize = .zero
    
    @State   var isHovering: Bool = false
    @Binding var isPressed:  Bool
    
    // TODO: style configuration!
    // TODO: animations!
    
    var hoverLightView: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    stops: [
                        Gradient.Stop(color: .white.opacity(!isPressed ? (!isHovering ? 0.0 : 0.3) : 0.5), location: 0),
                        Gradient.Stop(color: .clear, location: 1)
                    ],
                    center: UnitPoint(x: localMousePoint.x / currentSize.width, y: localMousePoint.y / currentSize.height),
                    startRadius: 0,
                    endRadius: /*!isHovering ? 0 :*/
                    max(100, ((currentSize.width + currentSize.height) / 2) * 4))
            )
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                hoverLightView
            }
        
            .onGeometryChange(for: CGSize.self) { return $0.size } action: { newValue in
                currentSize = newValue
            }
            .onContinuousHover(coordinateSpace: .local, perform: { hoverPhase in
                switch hoverPhase {
                case .active(let location):
                    localMousePoint = UnitPoint(x: location.x, y: location.y)
                case .ended: break
                }
            })
            .onHover { hovering in
                withAnimation(SWAnimationLibrary.buttonPressAnimation) { isHovering = hovering }
                hovering ? NSCursor.hide() : NSCursor.unhide()
            }
            // FIXME: cursor position doesn't update during long press!
            // This hasn't worked in XRPrototype either.
    }
}

extension View {
    func stopwatchHoverTarget(isPressed: Binding<Bool>) -> some View {
        self
            .modifier(SWHoverTargetViewModifier(isPressed: isPressed))
    }
}
