import SwiftUI

struct ContentView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    private let tabs = ["Overview", "CPU", "Memory", "Battery", "Network"]
    
    init(systemMonitor: SystemMonitor) {
        self.systemMonitor = systemMonitor
        
        // Set the accent color for the app
        NSApp.appearance = NSAppearance(named: .vibrantDark)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.windowBackgroundColor).opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab bar
                tabBarView
                
                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case 0: overviewTabView
                        case 1: cpuTabView
                        case 2: memoryTabView
                        case 3: batteryTabView
                        case 4: networkTabView
                        default: EmptyView()
                        }
                    }
                    .padding(16)
                }
                .animation(.easeInOut, value: selectedTab)
                
                // Footer
                footerView
            }
        }
        .frame(minWidth: 420, minHeight: 600)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // App logo and title
            HStack(spacing: 8) {
                Image(systemName: "speedometer")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.purple)
                
                Text("MacMetrics")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            
            Spacer()
            
            // Settings button
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(6)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Circle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Tab Bar View
    
    private var tabBarView: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                CustomTabButton(
                    title: tabs[index],
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .overlay(
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Footer View
    
    private var footerView: some View {
        HStack {
            // System uptime
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                
                Text("Uptime: 3d 5h 23m")
                    .font(.system(size: 10))
            }
            .foregroundColor(.secondary)
            
            Spacer()
            
            // Quit button
            Button(action: { NSApp.terminate(nil) }) {
                Text("Quit")
                    .font(.system(size: 10))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.windowBackgroundColor).opacity(0.95))
        .overlay(
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1),
            alignment: .top
        )
    }
    
    // MARK: - Tab Content Views
    
    // Overview Tab
    private var overviewTabView: some View {
        VStack(spacing: 20) {
            // CPU & Memory row
            HStack(spacing: 16) {
                MetricCard(
                    title: "CPU Usage",
                    icon: "cpu",
                    content: AnyView(
                        VStack(spacing: 12) {
                            // CPU Donut Chart
                            DonutChartView(
                                value: systemMonitor.cpuUsage,
                                lineWidth: 12,
                                size: 120,
                                color: .purple,
                                label: "Current Load"
                            )
                            .padding(.bottom, 4)
                            
                            // CPU Temperature
                            HStack {
                                Image(systemName: "thermometer")
                                    .foregroundColor(.red.opacity(0.8))
                                
                                Text("\(Int(systemMonitor.cpuTemperature))°C")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                            }
                        }
                    ),
                    color: .purple
                )
                
                MetricCard(
                    title: "Memory",
                    icon: "memorychip",
                    content: AnyView(
                        VStack(spacing: 12) {
                            // Memory Donut Chart
                            DonutChartView(
                                value: systemMonitor.memoryUsage,
                                lineWidth: 12,
                                size: 120,
                                color: .orange,
                                label: "Usage"
                            )
                            .padding(.bottom, 4)
                            
                            // Memory Details
                            HStack {
                                Image(systemName: "memorychip")
                                    .foregroundColor(.orange.opacity(0.8))
                                
                                Text("\(systemMonitor.memoryUsed.formatBytes()) / \(systemMonitor.memoryTotal.formatBytes())")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                            }
                        }
                    ),
                    color: .orange
                )
            }
            
            // History Charts row
            MetricCard(
                title: "Performance History",
                icon: "chart.xyaxis.line",
                content: AnyView(
                    VStack(spacing: 24) {
                        AnimatedChartView(
                            values: systemMonitor.cpuHistory,
                            color: .purple,
                            height: 80,
                            showLabels: false,
                            title: "CPU Usage"
                        )
                        
                        AnimatedChartView(
                            values: systemMonitor.memoryHistory,
                            color: .orange,
                            height: 80,
                            showLabels: false,
                            title: "Memory Usage"
                        )
                    }
                ),
                color: .blue
            )
            
            // Battery & Network row
            HStack(spacing: 16) {
                MetricCard(
                    title: "Battery",
                    icon: "battery.100",
                    content: AnyView(
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: systemMonitor.batteryIsCharging ? "battery.100.bolt" : "battery.100")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                                
                                Text("\(Int(systemMonitor.batteryCharge))%")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                            }
                            
                            Text(systemMonitor.batteryIsCharging ? "Charging" : "On Battery")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            AnimatedProgressView(value: systemMonitor.batteryCharge, color: .green)
                                .padding(.vertical, 8)
                        }
                    ),
                    color: .green
                )
                
                MetricCard(
                    title: "Network",
                    icon: "network",
                    content: AnyView(
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Today:")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(systemMonitor.networkUsageToday.formatBytes())
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Week:")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(systemMonitor.networkUsageWeek.formatBytes())
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Month:")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(systemMonitor.networkUsageMonth.formatBytes())
                                    .fontWeight(.semibold)
                            }
                        }
                    ),
                    color: .blue
                )
            }
        }
    }
    
    // CPU Tab
    private var cpuTabView: some View {
        VStack(spacing: 20) {
            // CPU Usage Card
            MetricCard(
                title: "CPU Performance",
                icon: "cpu",
                content: AnyView(
                    VStack(spacing: 20) {
                        // CPU gauge and temperature
                        HStack(spacing: 40) {
                            // CPU Gauge
                            DonutChartView(
                                value: systemMonitor.cpuUsage,
                                lineWidth: 16,
                                size: 150,
                                color: .purple,
                                label: "Current Load"
                            )
                            
                            // Temperature
                            VStack(alignment: .leading, spacing: 16) {
                                DetailRow(
                                    title: "Temperature",
                                    value: "\(Int(systemMonitor.cpuTemperature))°C",
                                    icon: "thermometer",
                                    color: .red
                                )
                                
                                // Activity Level
                                DetailRow(
                                    title: "Activity",
                                    value: activityLevel(for: systemMonitor.cpuUsage),
                                    icon: "gauge",
                                    color: activityColor(for: systemMonitor.cpuUsage)
                                )
                                
                                // Core Count
                                DetailRow(
                                    title: "Cores",
                                    value: "8 Cores",
                                    icon: "cpu",
                                    color: .purple
                                )
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // CPU History Chart
                        AnimatedChartView(
                            values: systemMonitor.cpuHistory,
                            color: .purple,
                            height: 100,
                            showLabels: true,
                            title: "Usage History"
                        )
                    }
                ),
                color: .purple
            )
            
            // Top Processes Card
            MetricCard(
                title: "Top Processes",
                icon: "list.bullet",
                content: AnyView(
                    VStack(spacing: 12) {
                        // Process list
                        ProcessRow(name: "Google Chrome", usage: 15.2, memory: "1.2 GB")
                        ProcessRow(name: "Xcode", usage: 12.8, memory: "3.4 GB")
                        ProcessRow(name: "MacMetrics", usage: 2.3, memory: "128 MB")
                        ProcessRow(name: "Finder", usage: 0.5, memory: "256 MB")
                        ProcessRow(name: "Mail", usage: 0.2, memory: "160 MB")
                    }
                ),
                color: .gray
            )
        }
    }
    
    // Memory Tab
    private var memoryTabView: some View {
        VStack(spacing: 20) {
            // Memory Overview Card
            MetricCard(
                title: "Memory Overview",
                icon: "memorychip",
                content: AnyView(
                    VStack(spacing: 20) {
                        // Memory gauge and details
                        HStack(spacing: 40) {
                            // Memory Gauge
                            DonutChartView(
                                value: systemMonitor.memoryUsage,
                                lineWidth: 16,
                                size: 150,
                                color: .orange,
                                label: "Usage"
                            )
                            
                            // Memory Details
                            VStack(alignment: .leading, spacing: 16) {
                                DetailRow(
                                    title: "Used",
                                    value: systemMonitor.memoryUsed.formatBytes(),
                                    icon: "memorychip",
                                    color: .orange
                                )
                                
                                DetailRow(
                                    title: "Available",
                                    value: (systemMonitor.memoryTotal - systemMonitor.memoryUsed).formatBytes(),
                                    icon: "plus.circle",
                                    color: .green
                                )
                                
                                DetailRow(
                                    title: "Total",
                                    value: systemMonitor.memoryTotal.formatBytes(),
                                    icon: "server.rack",
                                    color: .blue
                                )
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Memory History Chart
                        AnimatedChartView(
                            values: systemMonitor.memoryHistory,
                            color: .orange,
                            height: 100,
                            showLabels: true,
                            title: "Usage History"
                        )
                    }
                ),
                color: .orange
            )
            
            // Memory Breakdown Card
            MetricCard(
                title: "Memory Allocation",
                icon: "chart.pie",
                content: AnyView(
                    VStack(spacing: 16) {
                        // Memory breakdown pie chart simulation
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.orange, lineWidth: 20)
                                    .opacity(0.3)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: 0.35)
                                    .stroke(Color.orange, lineWidth: 20)
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                Circle()
                                    .trim(from: 0.35, to: 0.65)
                                    .stroke(Color.blue, lineWidth: 20)
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                Circle()
                                    .trim(from: 0.65, to: 0.85)
                                    .stroke(Color.green, lineWidth: 20)
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                Circle()
                                    .trim(from: 0.85, to: 1.0)
                                    .stroke(Color.purple, lineWidth: 20)
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                LegendItem(color: .orange, label: "App Memory", value: "4.2 GB")
                                LegendItem(color: .blue, label: "Wired Memory", value: "3.8 GB")
                                LegendItem(color: .green, label: "Compressed", value: "1.2 GB")
                                LegendItem(color: .purple, label: "Other", value: "0.8 GB")
                            }
                        }
                        .padding(.vertical, 10)
                    }
                ),
                color: .orange
            )
        }
    }
    
    // Battery Tab
    private var batteryTabView: some View {
        VStack(spacing: 20) {
            // Battery Status Card
            MetricCard(
                title: "Battery Status",
                icon: "battery.100",
                content: AnyView(
                    VStack(spacing: 20) {
                        // Battery gauge
                        HStack(spacing: 40) {
                            // Battery percentage donut
                            DonutChartView(
                                value: systemMonitor.batteryCharge,
                                lineWidth: 16,
                                size: 150,
                                color: .green,
                                label: systemMonitor.batteryIsCharging ? "Charging" : "Remaining"
                            )
                            
                            // Battery details
                            VStack(alignment: .leading, spacing: 16) {
                                DetailRow(
                                    title: "Status",
                                    value: systemMonitor.batteryIsCharging ? "Charging" : "Discharging",
                                    icon: systemMonitor.batteryIsCharging ? "battery.100.bolt" : "battery.100",
                                    color: .green
                                )
                                
                                DetailRow(
                                    title: "Capacity",
                                    value: "\(systemMonitor.batteryCapacity) mAh",
                                    icon: "powerplug",
                                    color: .blue
                                )
                                
                                DetailRow(
                                    title: "Health",
                                    value: "\(Int(systemMonitor.batteryHealth))%",
                                    icon: "heart.fill",
                                    color: .red
                                )
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Battery History Chart
                        AnimatedChartView(
                            values: systemMonitor.batteryHistory,
                            color: .green,
                            height: 100,
                            showLabels: true,
                            title: "Battery History"
                        )
                    }
                ),
                color: .green
            )
            
            // Power Usage Card
            MetricCard(
                title: "Power Consumption",
                icon: "bolt.fill",
                content: AnyView(
                    VStack(spacing: 16) {
                        // Power consumption details
                        HStack(spacing: 40) {
                            // Current power usage icon
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                            }
                            
                            // Power usage details
                            VStack(alignment: .leading, spacing: 12) {
                                DetailRow(
                                    title: "Current Usage",
                                    value: "12.5W",
                                    icon: "bolt",
                                    color: .green
                                )
                                
                                DetailRow(
                                    title: "Time Remaining",
                                    value: "5h 23m",
                                    icon: "clock",
                                    color: .blue
                                )
                                
                                DetailRow(
                                    title: "Cycles",
                                    value: "234",
                                    icon: "arrow.triangle.2.circlepath",
                                    color: .orange
                                )
                            }
                        }
                        .padding(.vertical, 10)
                    }
                ),
                color: .green
            )
        }
    }
    
    // Network Tab
    private var networkTabView: some View {
        VStack(spacing: 20) {
            // Network Usage Card
            MetricCard(
                title: "Network Usage",
                icon: "network",
                content: AnyView(
                    VStack(spacing: 20) {
                        // Network gauges
                        HStack(spacing: 40) {
                            // Upload
                            VStack {
                                Text("Upload")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 10)
                                        .frame(width: 100, height: 100)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.35)
                                        .stroke(Color.blue, lineWidth: 10)
                                        .frame(width: 100, height: 100)
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack {
                                        Text("1.2")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                        
                                        Text("MB/s")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Download
                            VStack {
                                Text("Download")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.purple.opacity(0.2), lineWidth: 10)
                                        .frame(width: 100, height: 100)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.65)
                                        .stroke(Color.purple, lineWidth: 10)
                                        .frame(width: 100, height: 100)
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack {
                                        Text("5.8")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                        
                                        Text("MB/s")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Network History Chart
                        AnimatedChartView(
                            values: systemMonitor.cpuHistory.map { $0 * 0.7 }, // Using CPU history as a placeholder
                            color: .blue,
                            height: 100,
                            showLabels: true,
                            title: "Network History"
                        )
                    }
                ),
                color: .blue
            )
            
            // Network Details Card
            MetricCard(
                title: "Network Details",
                icon: "wifi",
                content: AnyView(
                    VStack(spacing: 16) {
                        DetailRow(
                            title: "Interface",
                            value: "Wi-Fi (en0)",
                            icon: "wifi",
                            color: .blue
                        )
                        
                        DetailRow(
                            title: "IP Address",
                            value: "192.168.1.10",
                            icon: "network",
                            color: .green
                        )
                        
                        DetailRow(
                            title: "MAC Address",
                            value: "XX:XX:XX:XX:XX:XX",
                            icon: "lock.shield",
                            color: .orange
                        )
                        
                        Divider()
                        
                        HStack {
                            Text("Data Usage")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Today")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(systemMonitor.networkUsageToday.formatBytes())
                                    .fontWeight(.semibold)
                            }
                            
                            AnimatedProgressView(
                                value: Double(systemMonitor.networkUsageToday) / Double(systemMonitor.networkUsageWeek) * 100,
                                color: .blue
                            )
                            
                            HStack {
                                Text("This Week")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(systemMonitor.networkUsageWeek.formatBytes())
                                    .fontWeight(.semibold)
                            }
                            
                            AnimatedProgressView(
                                value: Double(systemMonitor.networkUsageWeek) / Double(systemMonitor.networkUsageMonth) * 100,
                                color: .blue
                            )
                            
                            HStack {
                                Text("This Month")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(systemMonitor.networkUsageMonth.formatBytes())
                                    .fontWeight(.semibold)
                            }
                            
                            AnimatedProgressView(value: 40, color: .blue)
                        }
                    }
                ),
                color: .blue
            )
        }
    }
    
    // MARK: - Helper Functions
    
    private func activityLevel(for value: Double) -> String {
        switch value {
        case 0..<20:
            return "Low"
        case 20..<60:
            return "Moderate"
        case 60..<85:
            return "High"
        default:
            return "Very High"
        }
    }
    
    private func activityColor(for value: Double) -> Color {
        switch value {
        case 0..<20:
            return .green
        case 20..<60:
            return .blue
        case 60..<85:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Supporting Views

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct ProcessRow: View {
    let name: String
    let usage: Double
    let memory: String
    
    var body: some View {
        HStack {
            // App icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Text(String(name.prefix(1)))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Process name
            Text(name)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            // CPU usage
            HStack(spacing: 4) {
                Text("\(String(format: "%.1f", usage))%")
                    .frame(width: 50, alignment: .trailing)
                
                // Mini bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 40, height: 6)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.purple)
                        .frame(width: 40 * CGFloat(usage) / 100, height: 6)
                }
            }
            
            // Memory usage
            Text(memory)
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(.secondary)
        }
        .font(.system(size: 12))
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var updateFrequency = 2.0
    @State private var startAtLogin = true
    @State private var showInDock = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
            }
            .padding()
            
            Divider()
            
            // Settings content
            Form {
                Section(header: Text("General")) {
                    Toggle("Start at login", isOn: $startAtLogin)
                    Toggle("Show icon in Dock", isOn: $showInDock)
                }
                
                Section(header: Text("Performance")) {
                    VStack(alignment: .leading) {
                        Text("Update frequency: \(String(format: "%.1f", updateFrequency))s")
                        
                        Slider(value: $updateFrequency, in: 0.5...5.0, step: 0.5)
                    }
                    
                    Button("Reset All Settings") {
                        // Reset logic here
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Device")
                        Spacer()
                        Text("MacBook Pro")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .frame(width: 350, height: 400)
    }
} 