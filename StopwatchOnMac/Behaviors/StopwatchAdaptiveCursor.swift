// StopwatchOnMac::SWDynamicCursor.swift - 16.06.2025

import SwiftUI

internal struct SWAdaptiveCursorViewModifier: ViewModifier {
    @State public var enabled: Bool = true
    
    @State private var localMousePoint: UnitPoint = .zero
    @State private var currentSize: CGSize = .zero
    
    @State private var isHovering: Bool = false
    
    let adaptiveHoverMult: CGFloat = 3.0
    
    private var adaptiveHoverOffset: CGSize {
        var p = CGSize(width:  (localMousePoint.x / currentSize.width)  * 2 - 1,
                       height: (localMousePoint.y / currentSize.height) * 2 - 1)
        
        p.width *= adaptiveHoverMult; p.height *= adaptiveHoverMult
        return p
    }
    
    func body(content: Content) -> some View {
        if !enabled { content }
        else {
            content
                .onGeometryChange(for: CGSize.self) { return $0.size } action: { newValue in
                    currentSize = newValue
                }
                .onHover { hovering in
                    withAnimation(SWAnimationLibrary.buttonPressAnimation) { isHovering = hovering }
                }
                .onContinuousHover(coordinateSpace: .local, perform: { hoverPhase in
                    switch hoverPhase {
                    case .active(let location):
                        localMousePoint = UnitPoint(x: location.x, y: location.y)
                    case .ended: break
                    }
                })
            
                .offset(isHovering ? adaptiveHoverOffset : .zero)
        }
    }
}

extension View {
    func stopwatchWantsAdaptiveCursor(_ enabled: Bool = true) -> some View {
        self
            .modifier(SWAdaptiveCursorViewModifier(enabled: enabled))
    }
}
