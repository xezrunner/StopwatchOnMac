// StopwatchOnMac::StopwatchTab.swift - 17.06.2025
import SwiftUI

public protocol StopwatchTab: CaseIterable, Identifiable, Hashable, Equatable, RawRepresentable
where AllCases == [Self], RawValue: StringProtocol {
    var id: Self { get }
    
    associatedtype Content: View
    @ViewBuilder func view() -> Content
    
    var icon:     String { get }
}

public extension StopwatchTab {
    var id: Self { self }
    var icon: String { get { return "gear" } }
}
