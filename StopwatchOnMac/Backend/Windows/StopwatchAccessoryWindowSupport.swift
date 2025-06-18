// StopwatchOnMac::StopwatchAccessoryWindows.swift - 17.06.2025

import SwiftUI

fileprivate struct SWAccessoryWindowViewModifier<WindowContent: View>: ViewModifier {
    @ViewBuilder var content: WindowContent
    
    func body(content: Content) -> some View {
        content
            .background {
                SWGetWindow { window in
                    addNewAccessoryWindowTo(window: window)
                }
            }
    }
    
    func addNewAccessoryWindowTo(window: NSWindow?) {
        guard let window = window else { Log("no window"); return }
        
        
    }
}

extension View {
    func stopwatchAccessoryWindow<WindowContent: View>(@ViewBuilder content: @escaping () -> WindowContent) -> some View {
        self.modifier(SWAccessoryWindowViewModifier(content: content))
    }
}
