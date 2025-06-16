// StopwatchOnMac::StopwatchOnMac.swift - 16.06.2025

import Foundation

// Logs as "functionName(): message"
internal func Log(_ format: String, _ functionName: String = #function, _ args: any CVarArg...) {
    Foundation.NSLog("\(functionName)(): \(format)", args)
}
