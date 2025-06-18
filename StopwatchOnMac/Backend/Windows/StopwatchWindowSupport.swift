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

private struct StopwatchWindowSupport {
    public static func SWCustomizeWindow(window: NSWindow?) {
        guard let window = window else { Log("no window, ignoring"); return }
        
        Log("customizing window: \(window.debugDescription)")
        
        window.isOpaque = false
        window.backgroundColor = .clear
        
        window.hasShadow = false
    }
}

internal class _SWGetWindowHelperNSView: NSView {
    var onWindowAccessed: ((NSWindow?) -> Void)? = nil
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(onWindowAccessed: ((NSWindow?) -> Void)?) {
        self.onWindowAccessed = onWindowAccessed
        super.init(frame: .zero)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        print("SWWindowCustomizationHelperNSView: viewDidMoveToWindow()!")
        print("  - \(self.window.debugDescription)")
        
        onWindowAccessed?(self.window)
    }
}

internal struct SWGetWindow: NSViewRepresentable {
    var onWindowAccessed: ((NSWindow?) -> Void)? = nil
    
    func makeNSView(context: Context) -> _SWGetWindowHelperNSView {
        _SWGetWindowHelperNSView(onWindowAccessed: onWindowAccessed)
    }
    
    func updateNSView(_ nsView: _SWGetWindowHelperNSView, context: Context) {
    }
}
