import SwiftUI

struct ContentView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    private let tabs = ["Overview", "CPU", "Memory", "Battery", "Network"]
    private let tabIcons = ["gauge.medium", "cpu", "memorychip", "battery.100", "network"]
    private let tabColors: [Color] = [
        Color(.labelColor),
        AppTheme.Colors.cpu,
        AppTheme.Colors.memory,
        AppTheme.Colors.battery,
        AppTheme.Colors.network
    ]
    
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
                TabButton(
                    title: tabs[index],
                    icon: tabIcons[index],
                    color: tabColors[index],
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
            SpeedTestView()
                .frame(height: 450)
                
            // Network bandwidth monitoring
            MetricCard(
                title: "Real-Time Network Activity",
                icon: "network",
                content: AnyView(
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            // Download rate
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(AppTheme.Colors.network)
                                    .font(.system(size: 24))
                                
                                Text("Download")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(systemMonitor.downloadRate.formatBandwidth())")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.Colors.network)
                                    
                                    Text("/s")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Upload rate
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(AppTheme.Colors.network.opacity(0.8))
                                    .font(.system(size: 24))
                                
                                Text("Upload")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(systemMonitor.uploadRate.formatBandwidth())")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.Colors.network.opacity(0.8))
                                    
                                    Text("/s")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Network traffic chart
                        AnimatedChartView(
                            values: systemMonitor.networkHistory,
                            color: AppTheme.Colors.network,
                            height: 80,
                            showLabels: true,
                            title: "Network Traffic"
                        )
                    }
                ),
                color: AppTheme.Colors.network
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
    @State private var selectedSection = 0
    @State private var showResetConfirmation = false
    @State private var appearAnimation = false
    
    private let sections = ["General", "Performance", "Display", "About"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.Colors.background,
                        AppTheme.Colors.background.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Settings")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .opacity(0.7)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Section tabs
                    HStack(spacing: 0) {
                        ForEach(0..<sections.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedSection = index
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text(sections[index])
                                        .font(AppTheme.Typography.smallBold)
                                        .foregroundColor(selectedSection == index ? 
                                            AppTheme.Colors.primary : 
                                            AppTheme.Colors.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                    
                                    Rectangle()
                                        .fill(selectedSection == index ? 
                                            AppTheme.Colors.primary : 
                                            Color.clear)
                                        .frame(height: 2)
                                        .padding(.horizontal, 2)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(height: 90)
            
            // Content
            ZStack {
                // Background - use Color.secondary instead of Color(AppTheme.Colors.card)
                Color.secondary
                    .opacity(0.1)
                
                // Settings content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedSection {
                        case 0: generalSection
                        case 1: performanceSection
                        case 2: displaySection
                        case 3: aboutSection
                        default: EmptyView()
                        }
                    }
                    .padding()
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 10)
                    .animation(.easeOut(duration: 0.3).delay(0.1), value: appearAnimation)
                    .animation(.easeOut(duration: 0.3), value: selectedSection)
                }
            }
        }
        .frame(width: 420, height: 500)
        .background(AppTheme.Colors.background)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.Colors.divider, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    appearAnimation = true
                }
            }
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset Settings"),
                message: Text("Are you sure you want to reset all settings to default?"),
                primaryButton: .destructive(Text("Reset")) {
                    resetSettings()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Settings Sections
    
    private var generalSection: some View {
        VStack(spacing: 20) {
            settingsSectionTitle("General Settings")
            
            VStack(spacing: 0) {
                settingsToggle(
                    title: "Start at login",
                    description: "Automatically open MacMetrics when you log in",
                    icon: "power",
                    iconColor: AppTheme.Colors.primary,
                    isOn: $startAtLogin
                )
                
                Divider()
                    .padding(.leading, 56)
                
                settingsToggle(
                    title: "Show in Dock",
                    description: "Display MacMetrics icon in the Dock",
                    icon: "dock.rectangle",
                    iconColor: AppTheme.Colors.secondary,
                    isOn: $showInDock
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var performanceSection: some View {
        VStack(spacing: 20) {
            settingsSectionTitle("Performance Settings")
            
            VStack(spacing: 16) {
                settingsSlider(
                    title: "Update Frequency",
                    description: "How often metrics are refreshed (seconds)",
                    icon: "timer",
                    iconColor: AppTheme.Colors.cpu,
                    value: $updateFrequency,
                    range: 0.5...5.0,
                    step: 0.5,
                    valueDisplay: "\(String(format: "%.1f", updateFrequency))s"
                )
                
                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    showResetConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.danger)
                        
                        Text("Reset All Settings")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.danger)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.Colors.danger.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var displaySection: some View {
        VStack(spacing: 20) {
            settingsSectionTitle("Display Settings")
            
            VStack(spacing: 0) {
                settingsToggle(
                    title: "Dark Mode",
                    description: "Use dark appearance",
                    icon: "moon.fill",
                    iconColor: AppTheme.Colors.network,
                    isOn: .constant(true)
                )
                
                Divider()
                    .padding(.leading, 56)
                
                settingsToggle(
                    title: "Compact Layout",
                    description: "Use a more compact UI for small screens",
                    icon: "rectangle.compress.vertical",
                    iconColor: AppTheme.Colors.memory,
                    isOn: .constant(false)
                )
                
                Divider()
                    .padding(.leading, 56)
                
                settingsToggle(
                    title: "Show Animations",
                    description: "Enable UI animations throughout the app",
                    icon: "waveform",
                    iconColor: AppTheme.Colors.battery,
                    isOn: .constant(true)
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
            
            VStack(spacing: 16) {
                Text("Theme Color")
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                // Color theme picker
                HStack(spacing: 12) {
                    ForEach([
                        AppTheme.Colors.primary,
                        AppTheme.Colors.secondary,
                        AppTheme.Colors.cpu,
                        AppTheme.Colors.memory,
                        AppTheme.Colors.network
                    ], id: \.self) { color in
                        Button(action: {}) {
                            Circle()
                                .fill(color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                        .opacity(color == AppTheme.Colors.primary ? 1 : 0)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 20) {
            settingsSectionTitle("About MacMetrics")
            
            VStack(spacing: 16) {
                // App icon and info
                VStack(spacing: 8) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("MacMetrics")
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Version 1.0.0")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // System info
                VStack(spacing: 12) {
                    infoRow(title: "Device", value: "MacBook Pro")
                    infoRow(title: "macOS", value: "Sonoma 14.5")
                    infoRow(title: "Processor", value: "Apple M1 Pro")
                    infoRow(title: "Memory", value: "16 GB")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
            
            // Footer with buttons
            HStack(spacing: 16) {
                footerButton("Website", icon: "globe", color: AppTheme.Colors.network)
                footerButton("Support", icon: "questionmark.circle", color: AppTheme.Colors.memory)
                footerButton("Privacy", icon: "lock.shield", color: AppTheme.Colors.battery)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppTheme.Typography.titleBold)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func settingsToggle(title: String, description: String, icon: String, iconColor: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(description)
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: iconColor))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func settingsSlider(title: String, description: String, icon: String, iconColor: Color, value: Binding<Double>, range: ClosedRange<Double>, step: Double, valueDisplay: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(description)
                        .font(AppTheme.Typography.small)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text(valueDisplay)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(iconColor)
                    .frame(width: 50, alignment: .trailing)
            }
            
            // Custom slider
            SliderView(value: value, range: range, step: step, color: iconColor)
                .padding(.leading, 52)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.bodyBold)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
    
    private func footerButton(_ title: String, icon: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppTheme.Typography.small)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func resetSettings() {
        // Reset logic
        updateFrequency = 2.0
        startAtLogin = true
        showInDock = false
    }
}

// Custom slider with improved styling
struct SliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let color: Color
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            // Track
            if #available(macOS 14.0, *) {
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                    
                    // Foreground track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.7),
                                    color
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(valuePosition(in: geometry.size.width))), height: 8)
                    
                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                        .offset(x: CGFloat(valuePosition(in: geometry.size.width)) - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    isDragging = true
                                    updateValue(at: gesture.location, in: geometry.size)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                        .scaleEffect(isDragging ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    // Convert tap location to correct coordinate space
                    let xValue = min(max(0, location.x), geometry.size.width)
                    let percent = Double(xValue / geometry.size.width)
                    let rawValue = range.lowerBound + percent * (range.upperBound - range.lowerBound)
                    
                    // Round to nearest step
                    let steps = round((rawValue - range.lowerBound) / step)
                    value = min(range.upperBound, max(range.lowerBound, range.lowerBound + steps * step))
                }
            } else {
                // Fallback on earlier versions
            };if #available(macOS 14.0, *) {
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                    
                    // Foreground track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.7),
                                    color
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(valuePosition(in: geometry.size.width))), height: 8)
                    
                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                        .offset(x: CGFloat(valuePosition(in: geometry.size.width)) - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    isDragging = true
                                    updateValue(at: gesture.location, in: geometry.size)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                        .scaleEffect(isDragging ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    // Convert tap location to correct coordinate space
                    let xValue = min(max(0, location.x), geometry.size.width)
                    let percent = Double(xValue / geometry.size.width)
                    let rawValue = range.lowerBound + percent * (range.upperBound - range.lowerBound)
                    
                    // Round to nearest step
                    let steps = round((rawValue - range.lowerBound) / step)
                    value = min(range.upperBound, max(range.lowerBound, range.lowerBound + steps * step))
                }
            } else {
                // Fallback on earlier versions
            }
        }
        .frame(height: 20)
        .padding(.trailing, 10)
    }
    
    private func valuePosition(in width: CGFloat) -> Double {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return Double(width) * percent
    }
    
    private func updateValue(at point: CGPoint, in size: CGSize) {
        let width = size.width
        let percent = max(0, min(1, Double(point.x / width)))
        let rawValue = range.lowerBound + percent * (range.upperBound - range.lowerBound)
        
        // Round to nearest step
        let steps = round((rawValue - range.lowerBound) / step)
        value = min(range.upperBound, max(range.lowerBound, range.lowerBound + steps * step))
    }
}

// Custom tab button with icon and color
struct TabButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? color : .secondary)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? color : .secondary)
            }
            .frame(minWidth: 70, maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            ZStack {
                if isSelected {
                    Rectangle()
                        .fill(color.opacity(0.1))
                        .frame(height: 3)
                        .offset(y: 16)
                }
            }
        )
    }
}

// Extension for formatting network bandwidth
extension Int {
    func formatBandwidth() -> String {
        let kb = Double(self) / 1024.0
        
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%.1f MB", mb)
        }
    }
    
    func formatBytes() -> String {
        let kb = Double(self) / 1024.0
        
        if kb < 1024 {
            return String(format: "%.0f KB", kb)
        } else if kb < 1024 * 1024 {
            let mb = kb / 1024.0
            return String(format: "%.1f GB", mb)
        } else {
            let gb = kb / (1024.0 * 1024.0)
            return String(format: "%.1f GB", gb)
        }
    }
} 
