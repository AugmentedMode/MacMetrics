import SwiftUI
import UserNotifications
import AppKit

class NotificationManager: ObservableObject {
    // Published properties for UI binding
    @Published var showCPUAlert = false
    @Published var showMemoryAlert = false
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var notificationHistory: [SystemAlert] = []
    
    // Thresholds (can be set via settings)
    @Published var cpuThreshold: Double = 85
    @Published var memoryThreshold: Double = 80
    
    // Cooldown management to prevent alert spam
    private var lastCPUAlertTime: Date?
    private var lastMemoryAlertTime: Date?
    private let cooldownPeriod: TimeInterval = 300 // 5 minutes
    
    // Sound effect options
    let soundOptions = ["None", "Subtle", "Ping", "Warning"]
    @Published var selectedSoundOption = "Ping"
    
    // Reference to popover for positioning custom alerts
    weak var popoverController: NSPopover?
    
    init() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkResourceUsage(systemMonitor: SystemMonitor) {
        // Update current values
        self.cpuUsage = systemMonitor.cpuUsage
        self.memoryUsage = systemMonitor.memoryUsage
        
        // Check CPU threshold
        if systemMonitor.cpuUsage > cpuThreshold {
            if shouldSendCPUAlert() {
                triggerCPUAlert(usage: systemMonitor.cpuUsage)
            }
        }
        
        // Check memory threshold
        if systemMonitor.memoryUsage > memoryThreshold {
            if shouldSendMemoryAlert() {
                triggerMemoryAlert(usage: systemMonitor.memoryUsage)
            }
        }
    }
    
    private func shouldSendCPUAlert() -> Bool {
        if let lastAlert = lastCPUAlertTime {
            return Date().timeIntervalSince(lastAlert) > cooldownPeriod
        }
        return true
    }
    
    private func shouldSendMemoryAlert() -> Bool {
        if let lastAlert = lastMemoryAlertTime {
            return Date().timeIntervalSince(lastAlert) > cooldownPeriod
        }
        return true
    }
    
    private func triggerCPUAlert(usage: Double) {
        // Update last alert time
        lastCPUAlertTime = Date()
        
        // Create alert record
        let alert = SystemAlert(
            type: .cpu,
            value: usage,
            timestamp: Date(),
            threshold: cpuThreshold
        )
        
        // Add to history
        DispatchQueue.main.async {
            self.notificationHistory.insert(alert, at: 0)
            self.showCPUAlert = true
            
            // Auto hide after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.showCPUAlert = false
            }
        }
        
        // Send system notification
        sendSystemNotification(
            title: "High CPU Usage Alert",
            body: "CPU usage has reached \(Int(usage))%, exceeding your \(Int(cpuThreshold))% threshold.",
            type: .cpu
        )
        
        // Play sound if enabled
        playAlertSound()
    }
    
    private func triggerMemoryAlert(usage: Double) {
        // Update last alert time
        lastMemoryAlertTime = Date()
        
        // Create alert record
        let alert = SystemAlert(
            type: .memory,
            value: usage,
            timestamp: Date(),
            threshold: memoryThreshold
        )
        
        // Add to history
        DispatchQueue.main.async {
            self.notificationHistory.insert(alert, at: 0)
            self.showMemoryAlert = true
            
            // Auto hide after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.showMemoryAlert = false
            }
        }
        
        // Send system notification
        sendSystemNotification(
            title: "High Memory Usage Alert",
            body: "Memory usage has reached \(Int(usage))%, exceeding your \(Int(memoryThreshold))% threshold.",
            type: .memory
        )
        
        // Play sound if enabled
        playAlertSound()
    }
    
    private func sendSystemNotification(title: String, body: String, type: AlertType) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Set sound based on preference
        if selectedSoundOption != "None" {
            content.sound = UNNotificationSound.default
        }
        
        // Setup actions
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Details",
            options: .foreground
        )
        
        let optimizeAction = UNNotificationAction(
            identifier: "OPTIMIZE_ACTION",
            title: "Optimize",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: type == .cpu ? "CPU_ALERT" : "MEMORY_ALERT",
            actions: [viewAction, optimizeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = type == .cpu ? "CPU_ALERT" : "MEMORY_ALERT"
        
        // Create trigger and request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        // Add request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func playAlertSound() {
        guard selectedSoundOption != "None" else { return }
        
        var soundName: NSSound.Name?
        
        switch selectedSoundOption {
        case "Subtle":
            soundName = NSSound.Name("Pop")
        case "Ping":
            soundName = NSSound.Name("Ping")
        case "Warning":
            soundName = NSSound.Name("Basso")
        default:
            soundName = NSSound.Name("Ping")
        }
        
        if let soundName = soundName {
            NSSound(named: soundName)?.play()
        }
    }
}

// Alert type enum
enum AlertType {
    case cpu
    case memory
    case network
    
    var icon: String {
        switch self {
        case .cpu:
            return "cpu"
        case .memory:
            return "memorychip"
        case .network:
            return "network"
        }
    }
    
    var color: Color {
        switch self {
        case .cpu:
            return AppTheme.Colors.cpu
        case .memory:
            return AppTheme.Colors.memory
        case .network:
            return AppTheme.Colors.network
        }
    }
}

// Alert record struct
struct SystemAlert: Identifiable {
    let id = UUID()
    let type: AlertType
    let value: Double
    let timestamp: Date
    let threshold: Double
    
    var isHigh: Bool {
        return value >= 95
    }
    
    var isCritical: Bool {
        return value >= 98
    }
} 