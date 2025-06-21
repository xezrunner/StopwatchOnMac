// StopwatchOnMac::StopwatchAccessoryWindow.swift - 17.06.2025

import SwiftUI

fileprivate class WindowTransformObserver {
    enum WindowTransformType {
        case resize, move, screenChange
    }
    
    init(window: NSWindow, handler: @escaping (_ transformType: WindowTransformType) -> Void) {
        NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: window, queue: .main) { notification in
            handler(.resize)
        }
        NotificationCenter.default.addObserver(forName: NSWindow.didMoveNotification, object: window, queue: .main) { notification in
            handler(.move)
        }
        NotificationCenter.default.addObserver(forName: NSWindow.didChangeScreenNotification, object: window, queue: .main) { notification in
            handler(.screenChange)
        }
    }
}

internal class SWAccessoryWindow<WindowContent: View>: NSWindow {
    private var _parentWindow: NSWindow
    private var transformObserver: WindowTransformObserver?
    
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
        transformObserver = WindowTransformObserver(window: parentWindow, handler: updateOrigin)
    }
    
    var isOffScreen: Bool = false
    let windowSpacing: CGFloat = 10
    
    // TODO: support different alignments (leading, trailing, top/bottom)
    fileprivate func updateOrigin(transformType: WindowTransformObserver.WindowTransformType) {
        let parentFrame = _parentWindow.frame
        let contentSize = self.contentView?.fittingSize ?? .zero
        
        let position: NSPoint
        
        // This is mainly for when we zoom/fullscreen the window:
        // TODO: might want to make the TabView handle this, so that the content would adapt properly, instead of forcing
        // a floating window. That said, we could also adapt with invisible spacers for now.
        let willBeOffScreen = parentFrame.origin.x < (contentSize.width + offset.x + windowSpacing)
        
        // FIXME: what direction should offset go when willBeOffScreen?
        if !willBeOffScreen {
            position = NSPoint(x: parentFrame.origin.x - contentSize.width - offset.x - windowSpacing,
                               y: (parentFrame.origin.y + (parentFrame.size.height - contentSize.height) / 2) + offset.y)
        } else {
            position = NSPoint(x: parentFrame.origin.x + windowSpacing + offset.x,
                               y: (parentFrame.origin.y + (parentFrame.size.height - contentSize.height) / 2) + offset.y)
        }
        
        // We only need to explicitly move the window ourselves if:
        // - we resized, as being a child window only links movement to parent
        // - when the accessory window would go off-screen
        // TODO: can we somehow animate the off-screen position changes as well?
        // Tried this (self.animator().setFrame()) but it would desync from the user moving the parent window while animating.
        if transformType == .resize || isOffScreen != willBeOffScreen {
            self.setFrameOrigin(position)
        }
        
        // Store new state late, so that we can respond to changes above:
        isOffScreen = willBeOffScreen
    }
    
    deinit {
        if let observer = transformObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

