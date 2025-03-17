import SwiftUI

// A design system inspired by Airbnb
struct MacTheme {
    // MARK: - Colors
    
    struct Colors {
        // Primary brand colors
        static let primary = Color(hex: "#FF5A5F")
        static let secondary = Color(hex: "#00A699")
        
        // Neutral colors
        static let background = Color(hex: "#1A1F25")
        static let card = Color(hex: "#252B33")
        static let cardHover = Color(hex: "#2D333B")
        static let divider = Color(hex: "#353C45").opacity(0.6)
        
        // Text colors
        static let textPrimary = Color(hex: "#FFFFFF")
        static let textSecondary = Color(hex: "#AAAAAA")
        static let textTertiary = Color(hex: "#777777")
        
        // Accent colors
        static let cpu = Color(hex: "#845EF7")       // Purple
        static let memory = Color(hex: "#FF922B")    // Orange
        static let disk = Color(hex: "#20C997")      // Teal
        static let network = Color(hex: "#339AF0")   // Blue
        static let battery = Color(hex: "#51CF66")   // Green
        static let warning = Color(hex: "#FCC419")   // Yellow
        static let danger = Color(hex: "#FF5A5F")    // Red (Airbnb signature)
        
        // Gradients
        static let backgroundGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#141A21"),
                Color(hex: "#1A1F25")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static func gradientFor(_ color: Color) -> LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.8),
                    color
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func statusColor(for value: Double) -> Color {
            switch value {
            case 0..<30: return Colors.battery    // Good
            case 30..<70: return Colors.warning   // Warning
            case _: return Colors.danger          // Critical
            }
        }
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Font sizes
        static let captionSize: CGFloat = 10
        static let smallSize: CGFloat = 12
        static let bodySize: CGFloat = 14
        static let titleSize: CGFloat = 16
        static let headlineSize: CGFloat = 20
        static let largeSize: CGFloat = 24
        static let heroSize: CGFloat = 36
        
        // Font styles
        static let caption = Font.system(size: captionSize, weight: .regular, design: .rounded)
        static let captionBold = Font.system(size: captionSize, weight: .semibold, design: .rounded)
        
        static let small = Font.system(size: smallSize, weight: .regular, design: .rounded)
        static let smallBold = Font.system(size: smallSize, weight: .semibold, design: .rounded)
        
        static let body = Font.system(size: bodySize, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: bodySize, weight: .semibold, design: .rounded)
        
        static let title = Font.system(size: titleSize, weight: .medium, design: .rounded)
        static let titleBold = Font.system(size: titleSize, weight: .bold, design: .rounded)
        
        static let headline = Font.system(size: headlineSize, weight: .semibold, design: .rounded)
        static let largeTitle = Font.system(size: largeSize, weight: .bold, design: .rounded)
        static let hero = Font.system(size: heroSize, weight: .bold, design: .rounded)
    }
    
    // MARK: - Layout
    
    struct Layout {
        // Spacing
        static let spacing2: CGFloat = 2
        static let spacing4: CGFloat = 4
        static let spacing8: CGFloat = 8
        static let spacing12: CGFloat = 12
        static let spacing16: CGFloat = 16
        static let spacing20: CGFloat = 20
        static let spacing24: CGFloat = 24
        static let spacing32: CGFloat = 32
        static let spacing40: CGFloat = 40
        
        // Radius
        static let radius4: CGFloat = 4
        static let radius8: CGFloat = 8
        static let radius12: CGFloat = 12
        static let radius16: CGFloat = 16
        static let radius20: CGFloat = 20
        
        // Shadows
        static let shadowSmall = Shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let shadowMedium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let shadowLarge = Shadow(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
        
        // Chart constants
        static let chartHeight: CGFloat = 120
        static let miniChartHeight: CGFloat = 80
        static let donutSize: CGFloat = 140
        static let donutStrokeWidth: CGFloat = 12
    }
    
    // MARK: - Animations
    
    struct Animations {
        static let fastDuration: Double = 0.2
        static let normalDuration: Double = 0.35
        static let slowDuration: Double = 0.5
        
        static let defaultEasing = Animation.easeInOut(duration: normalDuration)
        static let springy = Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.5)
    }
}

// Alias for backward compatibility
typealias AppTheme = MacTheme

// MARK: - Helper Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Simplified typealias for shadow
typealias Shadow = (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) 