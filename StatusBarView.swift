import SwiftUI

struct StatusBarView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    
    var body: some View {
        HStack(spacing: 8) {
            // CPU Indicator
            MiniMetricView(
                value: systemMonitor.cpuUsage,
                icon: "cpu",
                color: Color.purple.opacity(0.9)
            )
            
            // Memory Indicator
            MiniMetricView(
                value: systemMonitor.memoryUsage,
                icon: "memorychip",
                color: Color.orange.opacity(0.9)
            )
        }
        .padding(.horizontal, 4)
        .frame(height: 22)
    }
}

struct MiniMetricView: View {
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            
            LiveBarView(value: value, color: color)
        }
    }
}

struct LiveBarView: View {
    let value: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 8)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: min(36 * value / 100, 36), height: 8)
            }
            .frame(width: 36, height: geometry.size.height, alignment: .center)
        }
        .frame(width: 36, height: 16)
    }
} 