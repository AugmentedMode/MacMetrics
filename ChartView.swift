import SwiftUI

struct ChartView: View {
    let values: [Double]
    let color: Color
    let height: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: geometry.size.width / CGFloat(values.count) * 0.2) {
                ForEach(0..<values.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(
                            width: geometry.size.width / CGFloat(values.count) * 0.8,
                            height: max(1, values[index] / 100.0 * height)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: height)
    }
}

struct NetworkChartView: View {
    let values: [Double]
    let color: Color
    let height: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(0..<values.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 0)
                        .fill(color)
                        .frame(
                            width: geometry.size.width / CGFloat(values.count),
                            height: max(1, values[index] / 100.0 * height)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: height)
    }
} 