import SwiftUI

extension Color {
    // Backgrounds
    static let axisBackground    = Color(hex: "#0C0A15")  // Primary bg — very deep purple-black
    static let axisSurface1      = Color(hex: "#110F1C")  // Cards, sheets
    static let axisSurface2      = Color(hex: "#1A1826")  // Input fields, secondary cards
    static let axisSurface3      = Color(hex: "#22203A")  // Hover states, selected rows

    // Accent
    static let axisViolet        = Color(hex: "#8B5CF6")  // Primary accent — ALL interactive elements
    static let axisVioletDim     = Color(hex: "#8B5CF6").opacity(0.12)  // Accent fills
    static let axisVioletBorder  = Color(hex: "#8B5CF6").opacity(0.18)  // Accent borders

    // Semantic
    static let axisGreen         = Color(hex: "#10B981")  // Success, done, positive
    static let axisGreenDim      = Color(hex: "#10B981").opacity(0.12)
    static let axisAmber         = Color(hex: "#F59E0B")  // Warning, in-progress
    static let axisAmberDim      = Color(hex: "#F59E0B").opacity(0.12)
    static let axisRed           = Color(hex: "#EF4444")  // Destructive, urgent
    static let axisRedDim        = Color(hex: "#EF4444").opacity(0.12)
    static let axisBlue          = Color(hex: "#3B82F6")  // Info, links

    // Text
    static let axisTextPrimary   = Color(hex: "#F0EEFF")  // Body copy
    static let axisTextSecondary = Color(hex: "#F0EEFF").opacity(0.55)  // Labels, metadata
    static let axisTextMuted     = Color(hex: "#F0EEFF").opacity(0.28)  // Disabled, hints
    static let axisTextAccent    = Color(hex: "#8B5CF6")  // Links, active labels

    // Borders
    static let axisBorderDefault = Color(hex: "#8B5CF6").opacity(0.08)  // Default card border
    static let axisBorderStrong  = Color(hex: "#8B5CF6").opacity(0.18)  // Hover, active border
    static let axisBorderInput   = Color(hex: "#8B5CF6").opacity(0.14)  // Text field borders
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
