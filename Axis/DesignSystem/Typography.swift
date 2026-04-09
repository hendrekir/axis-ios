import SwiftUI

// System-font based typography. Token names preserved so call sites don't break.
// No custom fonts bundled — everything routes through SF Pro / SF Mono.
extension Font {
    // DISPLAY — formerly Syne ExtraBold. Now rounded bold system.
    static func axisSyne(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    // BODY — formerly Instrument Sans. Now default system.
    static func axisBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    // MONO — formerly JetBrains Mono. Now SF Mono.
    static func axisMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    // PREDEFINED SCALES (from the 10-point fix spec)
    static let axisHero:   Font = .system(size: 32, weight: .bold,     design: .rounded)
    static let axisTitle:  Font = .system(size: 22, weight: .bold,     design: .rounded)
    static let axisH1:     Font = .system(size: 28, weight: .bold,     design: .rounded)
    static let axisH2:     Font = .system(size: 20, weight: .semibold, design: .rounded)
    static let axisBody1:  Font = .system(size: 15, weight: .regular)
    static let axisBody2:  Font = .system(size: 13, weight: .regular)
    static let axisCaption:Font = .system(size: 12, weight: .regular)
    static let axisLabel:  Font = .system(size: 11, weight: .regular, design: .monospaced)
    static let axisMicro:  Font = .system(size: 9,  weight: .regular, design: .monospaced)
}
