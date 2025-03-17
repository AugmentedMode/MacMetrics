import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var systemMonitor = SystemMonitor()
    private var statusItemHostingView: NSHostingView<StatusBarView>?
    private var eventMonitor: EventMonitor?
    private var autoHideTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the system monitor and start it
        systemMonitor.startMonitoring()
        
        // Create the popover for our content
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 600)
        popover.behavior = .transient
        popover.animates = true
        
        // Apply popover appearance
        popover.appearance = NSAppearance(named: .vibrantDark)
        
        // Create main content view with animation
        let contentView = ContentView(systemMonitor: systemMonitor)
            .environmentObject(systemMonitor)
        
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status bar item
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create hosting view for status bar
        let statusBarView = StatusBarView(systemMonitor: systemMonitor)
        let hostingView = NSHostingView(rootView: statusBarView)
        
        if let button = statusItem.button {
            // Configure size
            hostingView.frame = NSRect(x: 0, y: 0, width: 96, height: 22)
            hostingView.autoresizingMask = [.width, .height]
            
            // Remove default button styling
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.clear.cgColor
            
            // Add custom view
            button.addSubview(hostingView)
            button.frame = hostingView.frame
            button.action = #selector(togglePopover)
        }
        
        self.statusItem = statusItem
        self.statusItemHostingView = hostingView
        
        // Setup event monitor to detect clicks outside the popover
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let popover = self.popover else { return }
            if popover.isShown {
                self.closePopoverWithAnimation()
            }
        }
        eventMonitor?.start()
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                closePopoverWithAnimation()
            } else {
                showPopoverWithAnimation(relativeTo: button.bounds, of: button)
            }
        }
    }
    
    private func showPopoverWithAnimation(relativeTo rect: NSRect, of view: NSView) {
        // Ensure the popover is ready
        guard let popover = self.popover else { return }
        
        // Cancel auto-hide timer if it's running
        autoHideTimer?.invalidate()
        
        // Set initial transparency
        popover.contentViewController?.view.alphaValue = 0.0
        
        // Show the popover
        popover.show(relativeTo: rect, of: view, preferredEdge: .minY)
        
        // Animate appearance
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            popover.contentViewController?.view.animator().alphaValue = 1.0
        }
    }
    
    private func closePopoverWithAnimation() {
        guard let popover = self.popover, popover.isShown else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            popover.contentViewController?.view.animator().alphaValue = 0.0
        }) {
            popover.performClose(nil)
        }
    }
}

// Event monitoring for detecting clicks outside the popover
class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

@main
struct MacMetricsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
} 