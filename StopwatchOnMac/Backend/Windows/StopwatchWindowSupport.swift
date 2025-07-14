// StopwatchOnMacDemo::StopwatchWindowSupport.swift - 16.06.2025

import SwiftUI

public struct StopwatchWindow<Content: View>: Scene {
    public let id: String = ""
    @ViewBuilder public let content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public var body: some Scene {
        WindowGroup(id: id) {
            content
                .background {
                    SWGetWindow() { window in
                        // Window customizations:
                        StopwatchWindowSupport.SWCustomizeWindow(window: window)
                    }
                }
                ._StopwatchStyling()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

internal let STOPWATCH_WINDOW_CORNER_RADIUS = 48.0

private struct StopwatchWindowSupport {
    internal static func nudgeOrigin(_ point: CGPoint?, by: CGPoint) -> CGPoint {
        if let point = point { return .init(x: point.x + by.x, y: point.y + by.y) }
        return .zero
    }
    
    public static func SWCustomizeWindow(window: NSWindow?) {
        guard let window = window else { Log("no window, ignoring"); return }
        
        Log("customizing window: \(window.debugDescription)")
        
        window.isOpaque = false
        window.backgroundColor = .clear
        
        window.hasShadow = false
        
        // Rounded corners:
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = STOPWATCH_WINDOW_CORNER_RADIUS
        window.contentView?.layer?.masksToBounds = true
        
        // Move window controls:
        let nudge = CGPoint(x: 24, y: -10)
        
        let close = window.standardWindowButton(.closeButton)?.frame.origin
        window.standardWindowButton(.closeButton)?.frame.origin = nudgeOrigin(close, by: nudge)
        
        let min = window.standardWindowButton(.miniaturizeButton)?.frame.origin
        window.standardWindowButton(.miniaturizeButton)?.frame.origin = nudgeOrigin(min, by: nudge)
        
        let zoom = window.standardWindowButton(.zoomButton)?.frame.origin
        window.standardWindowButton(.zoomButton)?.frame.origin = nudgeOrigin(zoom, by: nudge)
    }
}

internal class _SWGetWindowHelperNSView: NSView {
    var onWindowAccessed: (NSWindow?) -> Void
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(onWindowAccessed: @escaping (NSWindow?) -> Void) {
        self.onWindowAccessed = onWindowAccessed
        super.init(frame: .zero)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        print("SWWindowCustomizationHelperNSView: viewDidMoveToWindow()!")
        print("  - \(self.window.debugDescription)")
        
        onWindowAccessed(self.window)
    }
}

internal struct SWGetWindow: NSViewRepresentable {
    var onWindowAccessed: ((NSWindow?) -> Void)
    
    func makeNSView(context: Context) -> _SWGetWindowHelperNSView {
        _SWGetWindowHelperNSView(onWindowAccessed: onWindowAccessed)
    }
    
    func updateNSView(_ nsView: _SWGetWindowHelperNSView, context: Context) {
    }
}
