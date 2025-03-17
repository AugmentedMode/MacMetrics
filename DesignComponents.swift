import SwiftUI

// A beautiful card component with hover effects
struct MetricCard: View {
    let title: String
    let icon: String
    let content: AnyView
    let color: Color
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(.labelColor))
                
                Spacer()
                
                // More info button
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.secondary.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(isHovering ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
            }
            
            // Divider with color
            Rectangle()
                .fill(color.opacity(0.15))
                .frame(height: 1)
            
            // Content
            content
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(
            ZStack {
                // Card background with subtle gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.windowBackgroundColor).opacity(0.95),
                                Color(.windowBackgroundColor)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Card border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(isHovering ? 0.3 : 0.1),
                                color.opacity(isHovering ? 0.1 : 0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(
                color: Color.black.opacity(isHovering ? 0.12 : 0.08),
                radius: isHovering ? 8 : 6,
                x: 0,
                y: isHovering ? 4 : 2
            )
        )
        .scaleEffect(isHovering ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// A custom tab button with animation
struct CustomTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color(.labelColor) : Color.secondary)
                
                // Indicator line
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(height: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Progress indicator with animation
struct AnimatedProgressView: View {
    let value: Double
    let color: Color
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.15))
                
                // Foreground
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(
                        0,
                        min(
                            CGFloat(value * animationProgress) / 100 * geometry.size.width,
                            geometry.size.width
                        )
                    ))
            }
        }
        .frame(height: 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
}

// Frosted glass effect background
struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Base blur
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .background(
                    Rectangle()
                        .fill(Color(.windowBackgroundColor).opacity(0.9))
                        .blur(radius: 10)
                )
            
            // Subtle gradient overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.1), location: 0),
                            .init(color: Color.white.opacity(0.05), location: 0.5),
                            .init(color: Color.white.opacity(0), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.3), location: 0),
                            .init(color: Color.white.opacity(0.1), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
} 