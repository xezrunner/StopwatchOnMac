// StopwatchOnMac::StopwatchOnMac.swift - 16.06.2025

import Foundation
import SwiftUI

// Logs as "functionName(): message"
internal func Log(_ format: String, _ functionName: String = #function, _ args: any CVarArg...) {
    Foundation.NSLog("\(functionName)(): \(format)", args)
}

extension View {
    public func _StopwatchStyling() -> some View {
        self
            .containerBackground(.thinMaterial, for: .window)
        
            .buttonStyle(StopwatchButtonStyle())
            .environment(\.font, Font.system(size: 15))
    }
}

// MARK: - Miscellaneous

internal enum ButtonInteractionState { case idle, hovering, pressed }
