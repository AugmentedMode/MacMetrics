import SwiftUI

struct AnimatedChartView: View {
    let values: [Double]
    let color: Color
    let height: CGFloat
    let showLabels: Bool
    let title: String?
    
    @State private var animationProgress: CGFloat = 0
    
    init(values: [Double], color: Color, height: CGFloat, showLabels: Bool = false, title: String? = nil) {
        self.values = values
        self.color = color
        self.height = height
        self.showLabels = showLabels
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(.labelColor))
            }
            
            ZStack(alignment: .bottomLeading) {
                // Background grid
                VStack(spacing: height / 4) {
                    ForEach(0..<4) { i in
                        Divider()
                            .background(Color.gray.opacity(0.1))
                            .offset(y: i == 3 ? 0.5 : 0)
                    }
                    Spacer(minLength: 0)
                }
                
                // Chart container
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<values.count, id: \.self) { index in
                        let barHeight = (values[index] / 100.0) * height
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barGradient(for: color))
                            .frame(height: barHeight * animationProgress)
                            .shadow(color: color.opacity(0.3), radius: 1, x: 0, y: 1)
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                
                // Animated line
                ChartLineView(values: values, color: color, animationProgress: animationProgress)
            }
            .frame(height: height)
            
            if showLabels {
                HStack {
                    Text("0%")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("50%")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("100%")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func barGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                color.opacity(0.7),
                color
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

struct ChartLineView: View {
    let values: [Double] 
    let color: Color
    let animationProgress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(values.count - 1)
                
                // Start at the first point
                var x = CGFloat(0)
                var y = height - CGFloat(values[0] / 100.0 * Double(height))
                path.move(to: CGPoint(x: x, y: y))
                
                // Draw lines to each subsequent point
                for i in 1..<values.count {
                    x = step * CGFloat(i)
                    y = height - CGFloat(values[i] / 100.0 * Double(height))
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .trim(from: 0, to: animationProgress)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

struct DonutChartView: View {
    let value: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color
    let label: String
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Foreground circle showing the value
            Circle()
                .trim(from: 0, to: CGFloat(min(animationProgress * value / 100, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.7), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Center content
            VStack(spacing: 0) {
                Text("\(Int(value * animationProgress))%")
                    .font(.system(size: size/4, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: size/10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
} 