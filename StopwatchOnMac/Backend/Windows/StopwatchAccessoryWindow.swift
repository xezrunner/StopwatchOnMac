// StopwatchOnMac::StopwatchAccessoryWindow.swift - 17.06.2025

import SwiftUI

fileprivate class ResizeObserver {
    init(window: NSWindow, handler: @escaping () -> Void) {
        NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: window, queue: .main) { notification in
            handler()
        }
    }
}

internal class SWAccessoryWindow<WindowContent: View>: NSWindow {
    private var _parentWindow: NSWindow
    private var resizeObserver: ResizeObserver?
    
    private var offset: NSPoint
    
    init(parentWindow: NSWindow, content: WindowContent, id: String? = nil, offset: NSPoint = .zero) {
        self._parentWindow = parentWindow
        self.offset = offset
        
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered, defer: true
        )
        
        if let id = id { self.title = id }
        
        self.hasShadow = false
        self.isOpaque = false
        self.backgroundColor = .clear
        
        let rootView = content
            ._StopwatchStyling()
        let hostingView = NSHostingView(rootView: rootView)
        self.contentView = hostingView
        self.setContentSize(hostingView.fittingSize)
        
        // The resize handler should be called on startup automatically. If not, manually perform updateOrigin() here!
        resizeObserver = ResizeObserver(window: parentWindow, handler: updateOrigin)
    }
    
    func updateOrigin() {
        let parentFrame = _parentWindow.frame
        
        let contentSize = self.contentView?.fittingSize ?? .zero
        let position = NSPoint(x: (parentFrame.origin.x - contentSize.width) + offset.x,
                               y: (parentFrame.origin.y + (parentFrame.size.height - contentSize.height) / 2) + offset.y)
        
        self.setFrameOrigin(position)
    }
    
    deinit {
        if let observer = resizeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

