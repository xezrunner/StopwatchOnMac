// StopwatchOnMac::StopwatchOnMac.swift - 16.06.2025

import Foundation
import SwiftUI

// MARK: - Miscellaneous

// Logs as "functionName(): message"
internal func Log(_ format: String, _ functionName: String = #function, _ args: any CVarArg...) {
    Foundation.NSLog("\(functionName)(): \(format)", args)
}

internal enum ButtonInteractionState { case idle, hovering, pressed }

extension View {
    // https://stackoverflow.com/a/77735876/3589698
    func backcompat<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

// Styling:

internal struct StopwatchWindowBorder: View {
    var body: some View {
        let endRadius = 700.0
        
        let randomX = CGFloat.random(in: -endRadius...endRadius) / endRadius
        let randomY = CGFloat.random(in: -endRadius...endRadius) / endRadius
        let gradient = RadialGradient(stops: [
            Gradient.Stop(color: .white, location: 1),
            Gradient.Stop(color: .clear, location: 0),
        ], center: UnitPoint(x: randomX, y: randomY), startRadius: 0, endRadius: endRadius)
        
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(gradient, lineWidth: 0.8)
//            .strokeBorder(gradient, lineWidth: 240)
            .ignoresSafeArea()
            .compositingGroup()
            .blendMode(.plusLighter)
            .blur(radius: 1.3)
    }
}

extension View {
    public func _StopwatchStyling() -> some View {
        self
            .preferredColorScheme(.dark) // TODO: we don't necessarily want to force dark mode, but visionOS does seem more like dark mode
        
            .containerBackground(.thinMaterial, for: .window)
            .overlay { StopwatchWindowBorder() }
        
            .buttonStyle(StopwatchButtonStyle())
            .environment(\.font, Font.system(size: 15))
    }
}
