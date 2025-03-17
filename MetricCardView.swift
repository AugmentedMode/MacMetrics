import SwiftUI

struct MetricCardView: View {
    let title: String
    let value: String
    let chart: Bool
    let chartData: [Double]
    let chartColor: Color
    let content: AnyView?
    
    init(title: String, value: String, chart: Bool = false, chartData: [Double] = [], chartColor: Color = .blue, content: AnyView? = nil) {
        self.title = title
        self.value = value
        self.chart = chart
        self.chartData = chartData
        self.chartColor = chartColor
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: title.contains("Processor") ? "cpu" : 
                             title.contains("Battery") ? "battery.100" : 
                             title.contains("Graphic") ? "display" : 
                             "network")
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if content != nil {
                HStack {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    content
                }
            } else {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            
            if chart {
                ChartView(values: chartData, color: chartColor, height: 80)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct TemperatureGaugeView: View {
    let temperature: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: min(temperature / 100.0, 1.0))
                .stroke(
                    temperature > 75 ? Color.red :
                    temperature > 60 ? Color.orange : Color.blue,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 2) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2, height: 20)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct BatteryGaugeView: View {
    let percentage: Double
    let isCharging: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green.opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: percentage / 100.0)
                .stroke(
                    percentage < 20 ? Color.red :
                    percentage < 40 ? Color.orange : Color.green,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            VStack {
                Image(systemName: "battery.100")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                if isCharging {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
            }
        }
    }
} 