import SwiftUI

struct SpeedTestView: View {
    @StateObject private var speedService = NetworkSpeedService()
    @State private var showHistory = false
    
    // Average speeds in US for comparison
    private let avgDownloadSpeed: Double = 180.0 // Mbps
    private let avgUploadSpeed: Double = 30.0 // Mbps
    
    var body: some View {
        VStack(spacing: 0) {
            // Animated wave header with test button
            ZStack {
                // Animated wave background
                WaveBackground(
                    color: AppTheme.Colors.network,
                    amplitude: 10,
                    frequency: 8,
                    phase: 0,
                    height: 140
                )
                
                VStack(spacing: 16) {
                    Text("Speed Test")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    SpeedTestButton(
                        isRunning: speedService.isRunning,
                        phase: speedService.testPhase,
                        action: {
                            if !speedService.isRunning {
                                speedService.startTest()
                            }
                        }
                    )
                }
                .padding(.top, 6)
            }
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Test results section
                    if speedService.testPhase == .completed {
                        resultSection
                    } else if speedService.isRunning {
                        progressSection
                    } else {
                        instructionSection
                    }
                    
                    // Historical data and statistics
                    Button(action: {
                        withAnimation(.spring()) {
                            showHistory.toggle()
                        }
                    }) {
                        HStack {
                            Text(showHistory ? "Hide History" : "Show History")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.network)
                            
                            Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.network)
                        }
                        .padding(.top, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if showHistory {
                        SpeedHistoryChart(history: speedService.testHistory)
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 400, height: 450)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separatorColor).opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - Content Sections
    
    private var instructionSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "speedometer")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.network.opacity(0.7))
            
            Text("Test your connection speed")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(.labelColor))
            
            Text("Click the button above to measure your download and upload speeds. The test takes about 30 seconds to complete.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    private var progressSection: some View {
        VStack(spacing: 30) {
            // Main progress indicator
            SpeedTestProgressView(
                progress: progressForCurrentPhase(),
                color: AppTheme.Colors.network,
                lineWidth: 12,
                icon: iconForCurrentPhase(),
                size: 160
            )
            
            // Current phase text
            Text(titleForCurrentPhase())
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color(.labelColor))
            
            // Phase indicator dots
            HStack(spacing: 8) {
                ForEach(NetworkSpeedService.TestPhase.allCases.filter { $0 != .idle && $0 != .failed }, id: \.self) { phase in
                    Circle()
                        .fill(phaseColor(phase))
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(phaseColor(phase).opacity(0.3), lineWidth: 2)
                                .opacity(speedService.testPhase == phase ? 1 : 0)
                        )
                        .scaleEffect(speedService.testPhase == phase ? 1.2 : 1.0)
                        .animation(.spring(), value: speedService.testPhase)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var resultSection: some View {
        VStack(spacing: 24) {
            // Main results display
            HStack(spacing: 40) {
                // Download result
                SpeedGauge(
                    value: speedService.downloadSpeed,
                    maxValue: 300, // Adjust based on expected maximum
                    label: "Download",
                    color: AppTheme.Colors.network,
                    icon: "arrow.down"
                )
                
                // Upload result
                SpeedGauge(
                    value: speedService.uploadSpeed,
                    maxValue: 100, // Adjust based on expected maximum
                    label: "Upload",
                    color: AppTheme.Colors.network.opacity(0.8),
                    icon: "arrow.up"
                )
            }
            
            HStack(spacing: 10) {
                // Ping result
                VStack(alignment: .center, spacing: 4) {
                    Text("Ping")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(speedService.ping)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(pingColor)
                        
                        Text("ms")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.windowBackgroundColor).opacity(0.7))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separatorColor).opacity(0.5), lineWidth: 1)
                )
            }
            
            // Comparison with average speeds
            HStack(spacing: 16) {
                SpeedComparisonView(
                    value: speedService.downloadSpeed,
                    comparisonLabel: "vs avg download",
                    comparisonValue: avgDownloadSpeed
                )
                
                SpeedComparisonView(
                    value: speedService.uploadSpeed,
                    comparisonLabel: "vs avg upload",
                    comparisonValue: avgUploadSpeed
                )
            }
            
            // Test again button
            Button(action: {
                speedService.startTest()
            }) {
                Text("Test Again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.network)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.network.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Helper Methods
    
    private func progressForCurrentPhase() -> Double {
        switch speedService.testPhase {
        case .ping:
            return speedService.isRunning ? 0.25 : 0
        case .download:
            return 0.25 + speedService.downloadProgress * 0.35
        case .upload:
            return 0.6 + speedService.uploadProgress * 0.35
        case .completed:
            return 1.0
        default:
            return 0
        }
    }
    
    private func iconForCurrentPhase() -> String {
        switch speedService.testPhase {
        case .ping: return "wifi"
        case .download: return "arrow.down"
        case .upload: return "arrow.up"
        case .completed: return "checkmark"
        case .failed: return "exclamationmark.triangle"
        default: return "speedometer"
        }
    }
    
    private func titleForCurrentPhase() -> String {
        switch speedService.testPhase {
        case .ping: return "Measuring Ping"
        case .download: return "Testing Download Speed"
        case .upload: return "Testing Upload Speed"
        case .completed: return "Test Completed"
        case .failed: return "Test Failed"
        default: return "Ready to Test"
        }
    }
    
    private func phaseColor(_ phase: NetworkSpeedService.TestPhase) -> Color {
        if speedService.testPhase == .failed {
            return Color.red.opacity(0.7)
        }
        
        let isCompleted = phase.rawValue <= speedService.testPhase.rawValue
        return isCompleted ? AppTheme.Colors.network : Color.gray.opacity(0.3)
    }
    
    private var pingColor: Color {
        if speedService.ping <= 20 {
            return Color.green
        } else if speedService.ping <= 50 {
            return Color.orange
        } else {
            return Color.red
        }
    }
} 