import SwiftUI

extension Color {
    // Backgrounds — four surface levels
    static let axisBackground    = Color(hex: "#09090F")
    static let axisSurface1      = Color(hex: "#111118")
    static let axisSurface2      = Color(hex: "#18181F")
    static let axisSurface3      = Color(hex: "#1E1E28")

    // Accent
    static let axisViolet        = Color(hex: "#7C3AED")  // Primary accent
    static let axisVioletLight   = Color(hex: "#8B5CF6")
    static let axisVioletDim     = Color(hex: "#7C3AED").opacity(0.12)
    static let axisVioletBorder  = Color(hex: "#7C3AED").opacity(0.18)

    // Semantic
    static let axisGreen         = Color(hex: "#10B981")
    static let axisGreenDim      = Color(hex: "#10B981").opacity(0.12)
    static let axisAmber         = Color(hex: "#F59E0B")
    static let axisAmberDim      = Color(hex: "#F59E0B").opacity(0.12)
    static let axisRed           = Color(hex: "#EF4444")
    static let axisRedDim        = Color(hex: "#EF4444").opacity(0.12)
    static let axisBlue          = Color(hex: "#3B82F6")

    // Text
    static let axisTextPrimary   = Color(hex: "#F4F4F5")
    static let axisTextSecondary = Color(hex: "#A1A1AA")
    static let axisTextMuted     = Color(hex: "#52525B")
    static let axisTextAccent    = Color(hex: "#7C3AED")

    // Borders
    static let axisBorderDefault = Color.white.opacity(0.06)
    static let axisBorderStrong  = Color.white.opacity(0.12)
    static let axisBorderInput   = Color.white.opacity(0.12)
}

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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
