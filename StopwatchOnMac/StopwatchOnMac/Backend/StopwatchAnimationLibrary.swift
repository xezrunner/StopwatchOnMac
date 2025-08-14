// StopwatchOnMac::StopwatchAnimationLibrary.swift - 17.06.2025

import SwiftUI

internal struct SWAnimationLibrary {
    static let buttonPress           = Animation.easeOut(duration: 0.2) // ported from XRPrototype
    
    static let toolbarItemTransition = Animation.smooth (duration: 0.3)
    
    static let navigationStackAnimation = Animation.easeInOut(duration: 0.3)
}
