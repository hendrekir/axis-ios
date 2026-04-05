import SwiftUI

extension Font {
    // DISPLAY — Syne ExtraBold 800
    // Used for: screen titles, hero numbers, score displays
    static func axisSyne(_ size: CGFloat) -> Font {
        Font.custom("Syne-ExtraBold", size: size)
    }

    // BODY — Instrument Sans
    // Used for: body copy, labels, thread messages, descriptions
    static func axisBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name = weight == .medium ? "InstrumentSans-Medium" : "InstrumentSans-Regular"
        return Font.custom(name, size: size)
    }

    // MONO — JetBrains Mono
    // Used for: timestamps, system data, version numbers, stats
    static func axisMono(_ size: CGFloat) -> Font {
        Font.custom("JetBrainsMono-Medium", size: size)
    }

    // PREDEFINED SCALES
    static let axisHero:   Font = axisSyne(32)       // Screen heroes
    static let axisTitle:  Font = axisSyne(22)        // Section titles
    static let axisH1:     Font = axisBody(17, weight: .medium)  // Card titles
    static let axisH2:     Font = axisBody(15, weight: .medium)  // Sub-titles
    static let axisBody1:  Font = axisBody(15)        // Primary body
    static let axisBody2:  Font = axisBody(13)        // Secondary body
    static let axisCaption:Font = axisBody(12)        // Captions, labels
    static let axisLabel:  Font = axisMono(11)        // System labels, timestamps
    static let axisMicro:  Font = axisMono(9)         // Tags, badges
}
