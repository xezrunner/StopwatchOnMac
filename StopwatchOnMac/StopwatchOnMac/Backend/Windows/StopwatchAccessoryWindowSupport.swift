// StopwatchOnMac::StopwatchAccessoryWindows.swift - 17.06.2025

import SwiftUI

fileprivate struct SWAccessoryWindowViewModifier<WindowContent: View>: ViewModifier {
    @ViewBuilder var content: WindowContent
    
    var id: String?
    var offset: NSPoint = .zero
    
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
        
        let accessoryWindow = SWAccessoryWindow(parentWindow: window, content: content, id: id, offset: offset)
        window.addChildWindow(accessoryWindow, ordered: .above)
    }
}

// TODO: Properties like positioning (leading, trailing etc..)

extension View {
    func stopwatchAccessoryWindow<WindowContent: View>(id: String? = nil, offset: NSPoint = .zero, @ViewBuilder content: @escaping () -> WindowContent) -> some View {
        self.modifier(SWAccessoryWindowViewModifier(content: content, id: id, offset: offset))
    }
}
