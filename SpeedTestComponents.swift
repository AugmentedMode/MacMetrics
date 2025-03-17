import SwiftUI

// Animated circular progress indicator for speed test
struct SpeedTestProgressView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let icon: String
    let size: CGFloat
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.5), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Rotating glowing dots for animation during in-progress state
            if progress < 1.0 {
                ForEach(0..<8) { i in
                    Circle()
                        .fill(color.opacity(0.5))
                        .frame(width: lineWidth/2, height: lineWidth/2)
                        .offset(y: -(size - lineWidth)/2)
                        .rotationEffect(.degrees(Double(i) * 45 + rotationAngle))
                        .opacity(0.3 + 0.7 * sin(Double(i) * 0.7 + rotationAngle/30))
                }
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotationAngle)
                .onAppear {
                    rotationAngle = 360
                }
            }
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: size/5, weight: .semibold))
                .foregroundColor(color)
                .opacity(progress < 1.0 ? 0.8 : 1.0)
                .scaleEffect(progress < 1.0 ? 0.95 + 0.05 * sin(rotationAngle/20) : 1.0)
        }
        .frame(width: size, height: size)
    }
}

// Wave animation for background - replaced with macOS 11 compatible version
struct WaveBackground: View {
    let color: Color
    let amplitude: CGFloat
    let frequency: Double
    let phase: Double
    let height: CGFloat
    
    @State private var animationPhase: Double = 0
    
    var body: some View {
        ZStack {
            // Use a gradient background instead of Canvas
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.7),
                    color.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)
            
            // Add simple animated shapes instead of path-based wave
            ForEach(0..<10) { i in
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 20 + CGFloat(i) * 10, height: 20 + CGFloat(i) * 10)
                    .offset(x: sin(animationPhase + Double(i)) * amplitude * 2, 
                            y: -height/3 + CGFloat(i) * 5)
                    .blendMode(.plusLighter)
            }
        }
        .frame(height: height)
        .clipped()
        .onAppear {
            withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                animationPhase = 2 * .pi
            }
        }
    }
}

// Animated result display with value counting effect
struct AnimatedSpeedValueView: View {
    let value: Double
    let unit: String
    let color: Color
    let large: Bool
    
    @State private var displayValue: Double = 0
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.1f", displayValue))
                .font(large ? 
                      .system(size: 36, weight: .bold, design: .rounded) : 
                      .system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(large ?
                      .system(size: 16, weight: .medium, design: .rounded) :
                      .system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.8))
                .padding(.leading, 2)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                displayValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeOut(duration: 1.0)) {
                displayValue = newValue
            }
        }
    }
}

// Speed test result gauge
struct SpeedGauge: View {
    let value: Double
    let maxValue: Double
    let label: String
    let color: Color
    let icon: String
    
    @State private var showValue = false
    
    var body: some View {
        VStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            ZStack {
                // Background track
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        color.opacity(0.1),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(135))
                
                // Value indicator
                Circle()
                    .trim(from: 0, to: min(CGFloat(value) / CGFloat(maxValue) * 0.75, 0.75))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.7), color]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(135))
                    .animation(.easeOut(duration: 1.0), value: value)
                
                // Value text
                VStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                        .padding(.bottom, 2)
                    
                    AnimatedSpeedValueView(
                        value: value,
                        unit: "Mbps",
                        color: color,
                        large: false
                    )
                }
                .opacity(showValue ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn.delay(0.5)) {
                        showValue = true
                    }
                }
            }
        }
    }
}

// Speed test button with animated phase indicator
struct SpeedTestButton: View {
    let isRunning: Bool
    let phase: NetworkSpeedService.TestPhase
    let action: () -> Void
    
    @State private var isHovering = false
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isRunning {
                    // Show status based on current phase
                    Image(systemName: iconForPhase(phase))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(0.9)
                    
                    Text(textForPhase(phase))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.9)
                } else {
                    Image(systemName: "speedometer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Start Speed Test")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isRunning {
                        // Pulsing animation for running state
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppTheme.Colors.network.opacity(0.8),
                                        AppTheme.Colors.network
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(buttonScale)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: buttonScale
                            )
                            .onAppear {
                                buttonScale = 1.05
                            }
                    } else {
                        // Normal gradient for idle state
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppTheme.Colors.network.opacity(isHovering ? 1.0 : 0.9),
                                        AppTheme.Colors.network.opacity(isHovering ? 0.8 : 0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: AppTheme.Colors.network.opacity(isHovering ? 0.5 : 0.3),
                                radius: isHovering ? 10 : 5,
                                x: 0,
                                y: isHovering ? 5 : 3
                            )
                    }
                }
            )
            .clipShape(Capsule())
            .scaleEffect(isHovering && !isRunning ? 1.03 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isHovering)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isRunning)
        .onHover { hovering in
            isHovering = hovering && !isRunning
        }
    }
    
    private func iconForPhase(_ phase: NetworkSpeedService.TestPhase) -> String {
        switch phase {
        case .idle: return "speedometer"
        case .ping: return "wifi"
        case .download: return "arrow.down"
        case .upload: return "arrow.up"
        case .completed: return "checkmark.circle"
        case .failed: return "exclamationmark.triangle"
        }
    }
    
    private func textForPhase(_ phase: NetworkSpeedService.TestPhase) -> String {
        switch phase {
        case .idle: return "Ready"
        case .ping: return "Measuring Ping"
        case .download: return "Download Test"
        case .upload: return "Upload Test"
        case .completed: return "Completed"
        case .failed: return "Test Failed"
        }
    }
}

// Speed history chart
struct SpeedHistoryChart: View {
    let history: [NetworkSpeedService.SpeedTestResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(.labelColor))
            
            if history.isEmpty {
                Text("No speed tests yet")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 16) {
                    // Chart header
                    HStack {
                        Text("Date")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 90, alignment: .leading)
                        
                        Spacer()
                        
                        Text("Download")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .trailing)
                        
                        Text("Upload")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .trailing)
                        
                        Text("Ping")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    
                    // History rows
                    ForEach(history.reversed().prefix(5)) { result in
                        VStack {
                            HStack {
                                Text(formatDate(result.date))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(.labelColor))
                                    .frame(width: 90, alignment: .leading)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text(String(format: "%.1f", result.downloadSpeed))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.network)
                                    
                                    Text("Mbps")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 80, alignment: .trailing)
                                
                                HStack(spacing: 4) {
                                    Text(String(format: "%.1f", result.uploadSpeed))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.network.opacity(0.8))
                                    
                                    Text("Mbps")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 80, alignment: .trailing)
                                
                                HStack(spacing: 4) {
                                    Text("\(result.ping)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.warning)
                                    
                                    Text("ms")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 50, alignment: .trailing)
                            }
                            
                            Divider()
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// Speed comparison indicator
struct SpeedComparisonView: View {
    let value: Double
    let comparisonLabel: String
    let comparisonValue: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Comparison indicator
            ZStack {
                Circle()
                    .fill(comparisonColor.opacity(0.15))
                    .frame(width: 30, height: 30)
                
                Image(systemName: comparisonIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(comparisonColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(comparisonText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(comparisonColor)
                
                Text(comparisonLabel)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(.windowBackgroundColor).opacity(0.7))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(comparisonColor.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var percentage: Int {
        if comparisonValue <= 0 { return 0 }
        return Int((value / comparisonValue - 1) * 100)
    }
    
    private var comparisonText: String {
        let absPercentage = abs(percentage)
        if absPercentage < 5 {
            return "About average"
        } else if percentage > 0 {
            return "\(absPercentage)% faster"
        } else {
            return "\(absPercentage)% slower"
        }
    }
    
    private var comparisonIcon: String {
        if abs(percentage) < 5 {
            return "equal.circle.fill"
        } else if percentage > 0 {
            return "arrow.up.circle.fill"
        } else {
            return "arrow.down.circle.fill"
        }
    }
    
    private var comparisonColor: Color {
        if abs(percentage) < 5 {
            return Color.orange
        } else if percentage > 0 {
            return Color.green
        } else {
            return Color.red
        }
    }
} 