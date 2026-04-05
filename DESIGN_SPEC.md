# AXIS — iOS App Design Specification
## Complete build guide: every screen, every layout, every interaction
### Version 1.0 · April 2026 · For Claude Code + Cursor

---

## PART 1: DESIGN SYSTEM

### 1.1 Color Palette

All colors defined as SwiftUI `Color` extensions in `DesignSystem/Colors.swift`.

```swift
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
```

### 1.2 Typography

Custom fonts registered in `Info.plist`. Add via Swift Package Manager or as bundled resources.

```swift
// Fonts/AxisFont.swift
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
```

### 1.3 Spacing System

All spacing from an 8pt grid.

```swift
// Spacing/AxisSpacing.swift
enum AxisSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let base:CGFloat = 16
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
    static let section: CGFloat = 48  // Between major sections
}

enum AxisRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let pill: CGFloat = 100  // Full radius for tags/badges
}
```

### 1.4 Reusable Components

#### AxisCard
```swift
// Components/AxisCard.swift
struct AxisCard<Content: View>: View {
    var elevated: Bool = false
    var accent: Bool = false
    let content: Content

    init(elevated: Bool = false, accent: Bool = false, @ViewBuilder content: () -> Content) {
        self.elevated = elevated
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        content
            .background(elevated ? Color.axisSurface1 : Color.axisSurface1.opacity(0.6))
            .cornerRadius(AxisRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AxisRadius.lg)
                    .stroke(
                        accent ? Color.axisVioletBorder : Color.axisBorderDefault,
                        lineWidth: 0.5
                    )
            )
    }
}
```

#### AxisTag
```swift
// Components/AxisTag.swift
struct AxisTag: View {
    let text: String
    var color: Color = .axisViolet

    var body: some View {
        Text(text.uppercased())
            .font(.axisMicro)
            .foregroundColor(color)
            .padding(.horizontal, AxisSpacing.sm)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .cornerRadius(AxisRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AxisRadius.pill)
                    .stroke(color.opacity(0.2), lineWidth: 0.5)
            )
    }
}
```

#### AxisButton (primary)
```swift
// Components/AxisButton.swift
struct AxisPrimaryButton: View {
    let title: String
    let action: () -> Void
    var destructive: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.axisBody(15, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    destructive ? Color.axisRed : Color.axisViolet
                )
                .cornerRadius(AxisRadius.xl)
        }
        .buttonStyle(.plain)
    }
}

struct AxisSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.axisBody(15, weight: .medium))
                .foregroundColor(.axisTextPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.axisSurface2)
                .cornerRadius(AxisRadius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: AxisRadius.xl)
                        .stroke(Color.axisBorderInput, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
```

#### AxisTextField
```swift
// Components/AxisTextField.swift
struct AxisTextField: View {
    let placeholder: String
    @Binding var text: String
    var multiline: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextMuted)
                    .padding(.horizontal, AxisSpacing.base)
                    .padding(.top, 14)
            }
            if multiline {
                TextEditor(text: $text)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, AxisSpacing.md)
                    .padding(.vertical, AxisSpacing.sm)
            } else {
                TextField("", text: $text)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .padding(.horizontal, AxisSpacing.base)
                    .frame(height: 52)
            }
        }
        .background(Color.axisSurface2)
        .cornerRadius(AxisRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AxisRadius.md)
                .stroke(Color.axisBorderInput, lineWidth: 0.5)
        )
    }
}
```

### 1.5 The Axis Mark (Logo)

Used in navigation bar, splash screen, and onboarding.

```swift
// Components/AxisMark.swift
struct AxisMark: View {
    var size: CGFloat = 32
    var color: Color = .axisViolet

    var body: some View {
        Canvas { ctx, size in
            // Body — rounded dome shape emerging upward
            var body = Path()
            body.move(to: CGPoint(x: size.width * 0.19, y: size.height))
            body.addLine(to: CGPoint(x: size.width * 0.19, y: size.height * 0.5))
            body.addQuadCurve(
                to: CGPoint(x: size.width * 0.5, y: 0),
                control: CGPoint(x: size.width * 0.19, y: size.height * 0.08)
            )
            body.addQuadCurve(
                to: CGPoint(x: size.width * 0.81, y: size.height * 0.5),
                control: CGPoint(x: size.width * 0.81, y: size.height * 0.08)
            )
            body.addLine(to: CGPoint(x: size.width * 0.81, y: size.height))
            ctx.stroke(body, with: .color(color), lineWidth: size.width * 0.043)

            // Eye — large circle with concentric rings
            let eyeCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.38)
            let eyeR = size.width * 0.17
            ctx.stroke(Circle().path(in: CGRect(
                x: eyeCenter.x - eyeR, y: eyeCenter.y - eyeR,
                width: eyeR * 2, height: eyeR * 2
            )), with: .color(color), lineWidth: size.width * 0.043)

            // Pupil offset to 1 o'clock
            let pupilCenter = CGPoint(x: size.width * 0.528, y: size.height * 0.348)
            ctx.fill(Circle().path(in: CGRect(
                x: pupilCenter.x - size.width * 0.05, y: pupilCenter.y - size.width * 0.05,
                width: size.width * 0.1, height: size.width * 0.1
            )), with: .color(color))

            // Antenna — straight up then kinked right
            var antenna = Path()
            antenna.move(to: CGPoint(x: size.width * 0.5, y: 0))
            antenna.addLine(to: CGPoint(x: size.width * 0.5, y: -size.height * 0.14))
            antenna.addLine(to: CGPoint(x: size.width * 0.563, y: -size.height * 0.3))
            ctx.stroke(antenna, with: .color(color), lineWidth: size.width * 0.043)

            // Ball at antenna tip
            let ballCenter = CGPoint(x: size.width * 0.569, y: -size.height * 0.358)
            ctx.fill(Circle().path(in: CGRect(
                x: ballCenter.x - size.width * 0.094, y: ballCenter.y - size.width * 0.094,
                width: size.width * 0.188, height: size.width * 0.188
            )), with: .color(color))
        }
        .frame(width: size, height: size * 0.7)
        .clipped()
    }
}
```

---

## PART 2: APP ARCHITECTURE

### 2.1 Project Structure

```
axis-ios/
├── AxisApp.swift                    # App entry, background task registration
├── AppDelegate.swift                # APNs registration, notification categories
├── Info.plist                       # BGTaskSchedulerPermittedIdentifiers, permissions
│
├── DesignSystem/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   └── Components/
│       ├── AxisCard.swift
│       ├── AxisMark.swift
│       ├── AxisButton.swift
│       ├── AxisTextField.swift
│       ├── AxisTag.swift
│       └── AxisDivider.swift
│
├── Navigation/
│   ├── MainTabView.swift            # 4 bottom tabs
│   └── SidebarView.swift            # Hamburger sidebar
│
├── Screens/
│   ├── Onboarding/
│   │   ├── OnboardingFlow.swift
│   │   ├── Step1Welcome.swift
│   │   ├── Step2Capture.swift
│   │   ├── Step3Connect.swift
│   │   ├── Step4Journal.swift
│   │   └── Step5Ready.swift
│   ├── Situation/
│   │   └── SituationView.swift
│   ├── Thread/
│   │   ├── ThreadView.swift
│   │   ├── MessageBubble.swift
│   │   ├── ActionButtonRow.swift
│   │   └── ThreadInput.swift
│   ├── Mind/
│   │   ├── MindView.swift           # Segmented: Map / Skill Tree / Journal
│   │   ├── MindMap/
│   │   │   └── MindMapView.swift
│   │   ├── SkillTree/
│   │   │   └── SkillTreeView.swift
│   │   └── Journal/
│   │       ├── JournalView.swift
│   │       └── JournalEntryView.swift
│   ├── Brief/
│   │   ├── BriefView.swift          # Segmented: Today / World / Learn
│   │   ├── TodayBriefView.swift
│   │   ├── WorldBriefView.swift
│   │   └── LearnBriefView.swift
│   └── Sidebar/
│       ├── SignalView.swift
│       ├── ScheduleView.swift
│       ├── ConnectionsView.swift
│       ├── CapabilitiesView.swift
│       └── SettingsView.swift
│
├── Services/
│   ├── APIService.swift             # All backend calls, Clerk JWT auth
│   ├── LocationService.swift        # CoreLocation, geofencing
│   ├── HealthService.swift          # HealthKit
│   ├── NotificationService.swift    # APNs registration, categories
│   └── BackgroundService.swift      # BGTaskScheduler
│
├── Intents/                         # App Intents for Siri + widget buttons
│   ├── AddToAxisIntent.swift
│   ├── MarkDoneIntent.swift
│   ├── SnoozeIntent.swift
│   ├── BrainDumpIntent.swift
│   ├── SetModeIntent.swift
│   ├── GetSignalIntent.swift
│   └── AxisShortcuts.swift
│
├── Widgets/
│   ├── AxisWidgetBundle.swift
│   ├── LockScreenWidget.swift       # accessoryRectangular
│   ├── HomeScreenMediumWidget.swift # .systemMedium
│   └── HomeScreenSmallWidget.swift  # .systemSmall
│
├── Models/
│   ├── Signal.swift
│   ├── ThreadMessage.swift
│   ├── Task.swift
│   ├── JournalEntry.swift
│   ├── User.swift
│   └── Skill.swift
│
└── Shared/                          # Shared group for widget data
    └── SharedDefaults.swift
```

### 2.2 Navigation Structure

```swift
// Navigation/MainTabView.swift
struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var sidebarVisible: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            TabView(selection: $selectedTab) {
                SituationView()
                    .tabItem {
                        Label("Situation", systemImage: "eye.fill")
                    }
                    .tag(0)

                ThreadView()
                    .tabItem {
                        // Custom Axis mark icon for this tab
                        Label("Axis", image: "axis-tab-icon")
                    }
                    .tag(1)

                MindView()
                    .tabItem {
                        Label("Mind", systemImage: "brain.head.profile")
                    }
                    .tag(2)

                BriefView()
                    .tabItem {
                        Label("Brief", systemImage: "newspaper.fill")
                    }
                    .tag(3)
            }
            .tint(.axisViolet)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.axisSurface1, for: .tabBar)

            // Hamburger sidebar overlays everything
            if sidebarVisible {
                SidebarView(isVisible: $sidebarVisible)
                    .transition(.move(edge: .leading))
            }
        }
        .preferredColorScheme(.dark)  // Always dark — no light mode
        .environmentObject(AppState.shared)
    }
}
```

**Tab bar appearance rules:**
- Background: `axisSurface1` (#110F1C)
- Selected icon + label: `axisViolet` (#8B5CF6)
- Unselected icon + label: `axisTextMuted`
- Tab bar height: system default (83pt including safe area on iPhone 15)
- Axis tab (tab 2): uses custom SVG mark, not SF Symbol
- No tab bar border line — blends into the background

**Every screen has the same navigation bar:**
```swift
// Applied in each root view's .navigationBarTitleDisplayMode(.inline)
ToolbarItem(placement: .navigationBarLeading) {
    Button(action: { sidebarVisible.toggle() }) {
        Image(systemName: "line.3.horizontal")
            .foregroundColor(.axisTextSecondary)
    }
}

ToolbarItem(placement: .navigationBarTrailing) {
    // Screen-specific action (filter, compose, etc.)
}
```

---

## PART 3: ONBOARDING FLOW

5 screens. Each full-screen. No skip option until Step 4. Dots indicator at bottom of each screen showing progress (5 dots, current = white, others = axisVioletBorder).

### 3.1 Step 1 — Welcome

**What it is:** Full-screen splash with the Axis mark animating in, then the wordmark, then a single line.

**Layout:**
```
Full screen background: axisBackground (#0C0A15)

Center column (max width 320pt):
  ┌─────────────────────────────┐
  │                             │
  │         [84pt gap]          │
  │                             │
  │  [Axis Mark, 80pt wide]     │  — animates in: scale from 0.8 + opacity 0 to 1.0 + opacity 1, spring, 0.6s
  │                             │
  │  [16pt gap]                 │
  │                             │
  │  AXIS                       │  — Syne 800, 40pt, #F0EEFF, letter-spacing -0.05em
  │                             │    fades in 0.2s after mark completes
  │  extend the mind            │  — JetBrains Mono, 10pt, axisViolet 35% opacity
  │                             │    letter-spacing 0.28em, uppercase
  │                             │
  │  [48pt gap]                 │
  │                             │
  │  "AI is extending           │  — Instrument Sans 400, 20pt, #F0EEFF 85% opacity
  │   what's possible.          │    center-aligned, line-height 1.5
  │   Axis extends you."        │    fades in 0.3s after wordmark
  │                             │
  │  [auto spacer]              │
  │                             │
  │  [Continue button]          │  — AxisPrimaryButton, 52pt height, full width
  │                             │    "Get started"
  │  [24pt safe area gap]       │
  │                             │
  └─────────────────────────────┘

5-dot indicator: 24pt above the button
```

### 3.2 Step 2 — Capture

**What it is:** Demonstrates the brain dump / capture concept with an animated mock.

**Layout:**
```
Top half: Animated capture demonstration
  - Floating speech bubble appears from bottom: "Hey Siri, tell Axis: 
    the membrane on Level 2 is failing"
  - Axis responds below it in an iMessage-style bubble: "Added to site tasks.
    Supplier alert queued for Thursday."
  - Subtle particle animation showing "data flowing in" from top

Bottom half:
  [32pt gap]
  
  "Capture anything.               — Syne 800, 24pt, white
   From anywhere."
  
  [16pt gap]
  
  "Voice. Text. Photos. Shared     — Instrument Sans 400, 15pt, axisTextSecondary
   from any app. Axis captures     line-height 1.7
   and structures everything
   so you don't have to think
   about it."
  
  [32pt gap]
  
  Permission request row:          — Only shown if mic permission not granted
  ┌───────────────────────────────┐
  │ 🎙  Microphone access         │ — Surface1 card, 12pt corner radius
  │     For Siri + voice capture  │   Tap triggers permission dialog
  └───────────────────────────────┘
  
  [auto spacer]
  [Continue button]
  [24pt safe area]
```

### 3.3 Step 3 — Connect

**What it is:** Connect Gmail. This is the critical step. First meaningful data connection.

**Layout:**
```
[56pt top padding]

"Connect your inbox."    — Syne 800, 28pt, white

[12pt gap]

"Axis reads your email,  — Instrument Sans 400, 15pt, axisTextSecondary
 ranks what matters,     line-height 1.7
 and drafts replies in
 your voice."

[32pt gap]

[Gmail Connect Card — AxisCard, elevated]:
  ┌─────────────────────────────────────┐
  │  [G logo, 24pt]                     │
  │  Connect Gmail                      │  — axisH1
  │  Read + send email on your behalf   │  — axisBody2, axisTextSecondary
  │                                     │
  │  [Connect button, axisViolet, full] │  — Taps → opens OAuth in SFSafariVC
  └─────────────────────────────────────┘

[16pt gap]

[Google Calendar Card — same structure]:
  Connect Google Calendar
  Meeting prep + conflict detection

[16pt gap]

"Skip for now →"  — axisBody2, axisTextMuted, center
                    (Always available — don't force connections in onboarding)

[auto spacer]
[Continue button: "Continue" — enabled regardless of connections made]
[24pt safe area]
```

### 3.4 Step 4 — Permissions

**What it is:** Batch permission requests. Show WHY each matters with a concrete example.

**Layout:**
```
"One-time setup."        — Syne 800, 28pt, white

[12pt gap]

"These let Axis work     — axisBody1, axisTextSecondary
 without you having
 to think about it."

[24pt gap]

Permission cards (AxisCard, tap to request):

  ┌────────────────────────────────────────────┐
  │ 🔔  Notifications                      [●] │  — Green dot when granted, grey ring when not
  │     The main way Axis reaches you          │
  └────────────────────────────────────────────┘
  [8pt gap]
  ┌────────────────────────────────────────────┐
  │ 📍  Location                           [○] │
  │     Auto-switch modes when you arrive      │
  └────────────────────────────────────────────┘
  [8pt gap]
  ┌────────────────────────────────────────────┐
  │ ❤️  Health                             [○] │
  │     Route tasks by your energy level       │
  └────────────────────────────────────────────┘
  [8pt gap]
  ┌────────────────────────────────────────────┐
  │ 👥  Contacts                           [○] │
  │     Know who matters in your email         │
  └────────────────────────────────────────────┘

[auto spacer]
["Continue" — always enabled, users can skip permissions]
[24pt safe area]
```

### 3.5 Step 5 — Ready

**What it is:** The Axis mark pulses. A short motivating message. "Let's go" dismisses onboarding.

**Layout:**
```
Full center:

  [Axis mark, 100pt, with a slow breathing pulse animation]
  — Scale oscillates between 0.95 and 1.05 over 3s, ease in-out, repeating

  [24pt gap]

  "You're set up."         — Syne 800, 32pt, white

  [16pt gap]

  "Axis is watching.       — axisBody1, axisTextSecondary, center
   Every morning at 6:50,  line-height 1.7
   your brief arrives."

  [48pt gap]

  [Let's go — AxisPrimaryButton]
  
  [Dismiss to main app]
```

---

## PART 4: SITUATION SCREEN (TAB 1 — DEFAULT)

The most important screen. This is what users see when they open the app during their 3 daily sessions. Everything on this screen is generated by the dispatch job.

### 4.1 Layout

```
NavigationView {
    ScrollView {

        // MORNING BRIEF SECTION
        MorningBriefCard

        // TODAY'S SIGNAL
        SignalHeroCard

        // MOST IMPORTANT TASKS (MITs)
        MITSection

        // INSIGHTS (pattern observations from apprentice)
        InsightsSection

        // AXIS HANDLED (silent items count + summary)
        AxisHandledCard

    }
    .background(Color.axisBackground)
    .navigationTitle("") // Empty — no title
    .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
            // Hamburger
            Button(action: { sidebarVisible.toggle() }) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.axisTextSecondary)
                    .imageScale(.medium)
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            // Time + greeting
            VStack(alignment: .trailing, spacing: 1) {
                Text(currentGreeting)   // "Good morning" / "Good afternoon" / "Good evening"
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)
                Text(currentTime)       // "7:04 AM"
                    .font(.axisMono(11))
                    .foregroundColor(.axisTextSecondary)
            }
        }
    }
}
.padding(.horizontal, 16)
.padding(.top, 8)
```

### 4.2 Morning Brief Card

Only shown before 10AM or if there's a new brief. Collapses to a single line ("Morning brief ready →") after user has seen it.

```
AxisCard (elevated: true, accent: true) {
    VStack(alignment: .leading, spacing: 12) {

        // Header row
        HStack {
            AxisTag(text: "Morning brief", color: .axisViolet)
            Spacer()
            Text(briefTime)             // "6:50 AM" — axisMono(10), axisTextMuted
                .font(.axisMono(10))
                .foregroundColor(.axisTextMuted)
        }

        // Brief messages — each on its own line
        // Generated by the morning digest prompt
        // Format: plain text, axisBod1, white, line-height 1.7
        ForEach(briefMessages) { message in
            Text(message.content)
                .font(.axisBody1)
                .foregroundColor(.axisTextPrimary)
                .lineSpacing(4)
        }

        // "Put the phone down." final line
        // Always italic, axisTextMuted
        Text("Put the phone down.")
            .font(Font.custom("InstrumentSans-Regular", size: 14).italic())
            .foregroundColor(.axisTextMuted)

        // Silent count row
        HStack(spacing: 6) {
            Image(systemName: "eye.slash")
                .font(.system(size: 11))
                .foregroundColor(.axisViolet.opacity(0.5))
            Text("Axis handled \(silentCount) other items quietly")
                .font(.axisMono(10))
                .foregroundColor(.axisTextMuted)
        }
    }
    .padding(16)
}
.padding(.bottom, 4)
```

### 4.3 Signal Hero Card

The single most important action right now. Big, prominent, always visible.

```
AxisCard (elevated: true) {
    VStack(alignment: .leading, spacing: 0) {

        // Urgency indicator bar — top edge of card
        Rectangle()
            .fill(urgencyColor)     // axisRed if 9-10, axisAmber if 7-8, axisViolet if 5-6
            .frame(height: 3)
            .cornerRadius(AxisRadius.lg, corners: [.topLeft, .topRight])

        VStack(alignment: .leading, spacing: 12) {

            // Signal label row
            HStack {
                AxisTag(text: "Signal", color: urgencyColor)
                Spacer()
                Text(timeAgo)           // "2 min ago", axisMono(10), muted
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)
            }

            // Signal text — the key action
            Text(signal.text)
                .font(.axisH1)
                .foregroundColor(.axisTextPrimary)
                .lineSpacing(2)

            // Reason — why this is the signal
            Text(signal.reason)
                .font(.axisBody2)
                .foregroundColor(.axisTextSecondary)
                .lineSpacing(3)

            // Action buttons — prepared by dispatch job
            HStack(spacing: 8) {
                // Primary action — full violet button
                Button(signal.primaryActionLabel) {
                    handlePrimaryAction()
                }
                .font(.axisBody(14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.axisViolet)
                .cornerRadius(AxisRadius.pill)

                // Secondary — outlined
                Button("Later") {
                    snoozeSignal()
                }
                .font(.axisBody2)
                .foregroundColor(.axisTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.axisSurface2)
                .cornerRadius(AxisRadius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: AxisRadius.pill)
                        .stroke(Color.axisBorderDefault, lineWidth: 0.5)
                )

                Spacer()

                // Done
                Button(action: { markDone() }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.axisGreen)
                }
            }
        }
        .padding(16)
    }
}
.padding(.bottom, 4)
```

### 4.4 MIT Section (Most Important Tasks)

3 tasks maximum. Ordered by urgency score from dispatch. User can mark done inline.

```
VStack(alignment: .leading, spacing: 8) {

    // Section header
    HStack {
        Text("Today")
            .font(.axisMono(11))
            .foregroundColor(.axisTextMuted)
            .textCase(.uppercase)
            .kerning(1.5)
        Spacer()
        Text("\(completedCount)/\(totalCount)")
            .font(.axisMono(11))
            .foregroundColor(.axisViolet)
    }
    .padding(.horizontal, 4)

    ForEach(mits) { task in
        MITRow(task: task)
    }
}

// MIT Row structure:
struct MITRow: View {
    let task: Task

    var body: some View {
        AxisCard {
            HStack(spacing: 12) {

                // Completion circle
                Button(action: { toggleDone(task) }) {
                    ZStack {
                        Circle()
                            .stroke(
                                task.isDone ? Color.axisGreen : Color.axisBorderStrong,
                                lineWidth: 1.5
                            )
                            .frame(width: 22, height: 22)
                        if task.isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.axisGreen)
                        }
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.axisBody1)
                        .foregroundColor(task.isDone ? .axisTextMuted : .axisTextPrimary)
                        .strikethrough(task.isDone)
                        .lineLimit(2)

                    if let skill = task.skill {
                        Text(skill)
                            .font(.axisMono(10))
                            .foregroundColor(.axisViolet.opacity(0.6))
                    }
                }

                Spacer()

                // Urgency dot
                Circle()
                    .fill(urgencyColor(task.urgency))
                    .frame(width: 7, height: 7)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
}
```

### 4.5 Insights Section

Shown when apprentice has learned enough patterns to surface something worth noting.

```
VStack(alignment: .leading, spacing: 8) {

    Text("Axis noticed")
        .font(.axisMono(11))
        .foregroundColor(.axisTextMuted)
        .textCase(.uppercase)
        .kerning(1.5)
        .padding(.horizontal, 4)

    ForEach(insights) { insight in
        AxisCard {
            HStack(spacing: 12) {
                // Insight type icon
                Image(systemName: insight.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.axisViolet.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(Color.axisVioletDim)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 3) {
                    Text(insight.title)
                        .font(.axisBody(14, weight: .medium))
                        .foregroundColor(.axisTextPrimary)
                    Text(insight.detail)
                        .font(.axisBody2)
                        .foregroundColor(.axisTextSecondary)
                        .lineSpacing(2)
                }

                Spacer()
            }
            .padding(14)
        }
    }
}
```

### 4.6 Axis Handled Card

Shown at the bottom — reinforces the product's value. "Here's what Axis did while you weren't looking."

```
AxisCard {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text("Handled silently")
                .font(.axisMono(11))
                .foregroundColor(.axisTextMuted)
                .textCase(.uppercase)
                .kerning(1.5)
            Spacer()
            Text("\(silentCount) items")
                .font(.axisMono(11))
                .foregroundColor(.axisViolet)
        }

        // Bullet summary of what was silently handled
        ForEach(handledSummary) { item in
            HStack(spacing: 8) {
                Circle().fill(Color.axisGreen).frame(width: 5, height: 5)
                Text(item)
                    .font(.axisBody2)
                    .foregroundColor(.axisTextSecondary)
            }
        }
    }
    .padding(14)
}
.padding(.bottom, 24)
```

---

## PART 5: THREAD / AXIS SCREEN (TAB 2)

The conversational heart of the app. iMessage-style. Axis speaks first. User captures + responds here.

### 5.1 Overall Layout

```
NavigationView {
    VStack(spacing: 0) {
        // Scrollable message list
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .onChange(of: messages.count) { _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
        }

        // Input bar — always pinned to keyboard
        ThreadInputBar()
            .background(Color.axisSurface1)
            .overlay(
                Divider()
                    .background(Color.axisBorderDefault),
                alignment: .top
            )
    }
    .background(Color.axisBackground)
}
```

### 5.2 Message Bubbles

**Axis messages (left-aligned):**
```
HStack(alignment: .top, spacing: 10) {
    // Axis mark avatar — 28pt circle
    ZStack {
        Circle()
            .fill(Color.axisVioletDim)
            .frame(width: 28, height: 28)
        AxisMark(size: 16, color: .axisViolet)
    }

    VStack(alignment: .leading, spacing: 6) {
        // Message bubble
        Text(message.content)
            .font(.axisBody1)
            .foregroundColor(.axisTextPrimary)
            .lineSpacing(4)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.axisSurface1)
            .cornerRadius(4, corners: .topLeft)
            .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.axisBorderDefault, lineWidth: 0.5)
            )

        // Action buttons (if message has actions)
        if let actions = message.actions, !actions.isEmpty {
            ActionButtonRow(actions: actions)
        }

        // Timestamp
        Text(message.timestamp.timeAgo)
            .font(.axisMono(10))
            .foregroundColor(.axisTextMuted)
            .padding(.leading, 4)
    }

    Spacer(minLength: 60)  // Forces bubble to max 75% width
}
```

**User messages (right-aligned):**
```
HStack(alignment: .top, spacing: 10) {
    Spacer(minLength: 60)

    VStack(alignment: .trailing, spacing: 4) {
        Text(message.content)
            .font(.axisBody1)
            .foregroundColor(.white)
            .lineSpacing(4)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.axisViolet)
            .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
            .cornerRadius(4, corners: .bottomRight)

        Text(message.timestamp.timeAgo)
            .font(.axisMono(10))
            .foregroundColor(.axisTextMuted)
            .padding(.trailing, 4)
    }
}
```

**Skill result messages (distinct styling):**
These are generated by skill executions — email drafts, calendar events, finance alerts.

```
AxisCard (accent: true) {
    VStack(alignment: .leading, spacing: 10) {
        // Skill label
        HStack(spacing: 6) {
            AxisMark(size: 12, color: .axisViolet)
            Text(message.skillName.uppercased())
                .font(.axisMono(9))
                .foregroundColor(.axisViolet.opacity(0.7))
                .kerning(1.5)
            Spacer()
            Text(message.timestamp.timeAgo)
                .font(.axisMono(10))
                .foregroundColor(.axisTextMuted)
        }

        // Content
        Text(message.content)
            .font(.axisBody1)
            .foregroundColor(.axisTextPrimary)
            .lineSpacing(4)

        // Draft preview (if email skill)
        if let draft = message.emailDraft {
            VStack(alignment: .leading, spacing: 6) {
                Text("To: \(draft.recipient)")
                    .font(.axisMono(11))
                    .foregroundColor(.axisTextMuted)
                Divider().background(Color.axisBorderDefault)
                Text(draft.body)
                    .font(.axisBody2)
                    .foregroundColor(.axisTextSecondary)
                    .lineSpacing(3)
                    .lineLimit(4)
            }
            .padding(12)
            .background(Color.axisSurface2)
            .cornerRadius(AxisRadius.md)
        }

        // Action buttons
        if let actions = message.actions {
            ActionButtonRow(actions: actions)
        }
    }
    .padding(14)
}
.padding(.horizontal, 16)
```

### 5.3 Action Button Row

```swift
struct ActionButtonRow: View {
    let actions: [MessageAction]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(actions) { action in
                Button(action: { handleAction(action) }) {
                    Text(action.label)
                        .font(.axisBody(13, weight: .medium))
                        .foregroundColor(action.isPrimary ? .white : .axisTextSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            action.isPrimary
                            ? (action.isDestructive ? Color.axisRed : Color.axisViolet)
                            : Color.axisSurface2
                        )
                        .cornerRadius(AxisRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: AxisRadius.pill)
                                .stroke(
                                    action.isPrimary ? Color.clear : Color.axisBorderDefault,
                                    lineWidth: 0.5
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
```

### 5.4 Thread Input Bar

```swift
struct ThreadInputBar: View {
    @State private var inputText: String = ""
    @State private var isRecording: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Text input
            ZStack(alignment: .leading) {
                if inputText.isEmpty {
                    Text("Capture anything...")
                        .font(.axisBody1)
                        .foregroundColor(.axisTextMuted)
                        .padding(.horizontal, 14)
                }
                TextField("", text: $inputText, axis: .vertical)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextPrimary)
                    .lineLimit(1...6)
                    .focused($isFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
            .background(Color.axisSurface2)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isFocused ? Color.axisVioletBorder : Color.axisBorderInput,
                        lineWidth: 0.5
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)

            // Mic button (shown when input is empty)
            // Send button (shown when input has text)
            if inputText.isEmpty {
                Button(action: { startVoiceCapture() }) {
                    Image(systemName: isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isRecording ? .axisRed : .axisViolet)
                        .frame(width: 44, height: 44)
                        .background(
                            isRecording ? Color.axisRedDim : Color.axisVioletDim
                        )
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { sendMessage() }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.axisViolet)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.15), value: inputText.isEmpty)
    }
}
```

**Input bar behavior:**
- When keyboard appears: bar lifts with keyboard (keyboardResponsive modifier)
- Mic button: hold → waveform animation plays → release → audio processed and sent as capture
- When text entered: mic button replaced by send button (animated transition)
- Send: POST to /thread/message, response streams back as Axis reply

---

## PART 6: MIND SCREEN (TAB 3)

Three sub-tabs: Map, Skill Tree, Journal. Segmented control at top.

### 6.1 Sub-tab Navigation

```swift
struct MindView: View {
    @State private var selectedTab: MindTab = .journal

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented control — custom styled
                MindSegmentedControl(selected: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                // Content
                switch selectedTab {
                case .map:     MindMapView()
                case .skills:  SkillTreeView()
                case .journal: JournalView()
                }
            }
            .background(Color.axisBackground)
            .navigationTitle("Mind")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Custom segmented control matching the design
struct MindSegmentedControl: View {
    @Binding var selected: MindTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MindTab.allCases) { tab in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selected = tab } }) {
                    Text(tab.label)
                        .font(.axisBody(13, weight: selected == tab ? .medium : .regular))
                        .foregroundColor(selected == tab ? .axisTextPrimary : .axisTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            selected == tab ? Color.axisSurface2 : Color.clear
                        )
                        .cornerRadius(AxisRadius.md)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.axisSurface1)
        .cornerRadius(AxisRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AxisRadius.lg)
                .stroke(Color.axisBorderDefault, lineWidth: 0.5)
        )
    }
}
```

### 6.2 Journal (Default Mind Sub-tab)

Daily rotating journal question + past entries.

```
ScrollView {

    // Today's question card
    AxisCard (elevated: true, accent: true) {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AxisTag(text: "Today · \(dayName)", color: .axisViolet)
                Spacer()
                // Streak counter
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.axisAmber)
                    Text("\(streak) days")
                        .font(.axisMono(11))
                        .foregroundColor(.axisAmber)
                }
            }

            Text(todaysQuestion)
                .font(.axisH1)
                .foregroundColor(.axisTextPrimary)
                .lineSpacing(3)

            if hasAnswered {
                // Show today's answer, read-only
                Text(todaysAnswer)
                    .font(.axisBody1)
                    .foregroundColor(.axisTextSecondary)
                    .lineSpacing(4)
                    .padding(12)
                    .background(Color.axisSurface2)
                    .cornerRadius(AxisRadius.md)
            } else {
                // Answer input
                AxisTextField(
                    placeholder: "What's on your mind...",
                    text: $journalDraft,
                    multiline: true
                )
                .frame(minHeight: 100)

                Button(action: { submitJournalEntry() }) {
                    Text("Save")
                        .font(.axisBody(14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.axisViolet)
                        .cornerRadius(AxisRadius.pill)
                }
            }
        }
        .padding(16)
    }

    // Past entries — grouped by week
    ForEach(pastEntryGroups) { group in
        VStack(alignment: .leading, spacing: 6) {
            Text(group.weekLabel)       // "This week", "Last week", "March 2026"
                .font(.axisMono(11))
                .foregroundColor(.axisTextMuted)
                .textCase(.uppercase)
                .kerning(1.5)
                .padding(.horizontal, 4)

            ForEach(group.entries) { entry in
                JournalEntryRow(entry: entry)
                    .onTapGesture { showEntry(entry) }
            }
        }
    }
}
.padding(.horizontal, 16)
.padding(.top, 4)

// Entry row:
struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        AxisCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.question)
                        .font(.axisBody2)
                        .foregroundColor(.axisTextMuted)
                        .lineLimit(1)
                    Text(entry.answer)
                        .font(.axisBody1)
                        .foregroundColor(.axisTextPrimary)
                        .lineLimit(2)
                }

                Spacer()

                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)
            }
            .padding(14)
        }
    }
}
```

**7 rotating journal questions:**
1. Monday: "What's the one thing that would make this week feel like a success?"
2. Tuesday: "Who do you need to reach out to that you've been putting off?"
3. Wednesday: "What's working right now that you should do more of?"
4. Thursday: "What decision have you been avoiding? What's actually stopping you?"
5. Friday: "What did you learn this week — about work, people, yourself?"
6. Saturday: "What would you do tomorrow if it wasn't about being productive?"
7. Sunday: "What does next week need to feel like?"

### 6.3 Skill Tree

Visual map of all connected skills — which are active, last run, performance.

```
ScrollView {
    // Mode selector
    ModePicker(selected: $currentMode)
        .padding(.bottom, 8)

    // Skill cards in a 2-column grid
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
        ForEach(skills) { skill in
            SkillCard(skill: skill)
        }
    }
}
.padding(16)

struct SkillCard: View {
    let skill: Skill

    var body: some View {
        AxisCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(skill.icon)     // "📧" "📅" "💰" etc.
                        .font(.system(size: 24))
                    Spacer()
                    Circle()
                        .fill(skill.isActive ? Color.axisGreen : Color.axisSurface3)
                        .frame(width: 7, height: 7)
                }

                Text(skill.name)
                    .font(.axisH2)
                    .foregroundColor(.axisTextPrimary)

                Text(skill.lastRun?.timeAgo ?? "Never run")
                    .font(.axisMono(10))
                    .foregroundColor(.axisTextMuted)

                // Model badge
                AxisTag(text: skill.model, color: modelColor(skill.model))
            }
            .padding(14)
        }
    }
}
```

### 6.4 Mind Map

Visual graph of the user's life — populated from journal entries, captures, and relationships. Pinch to zoom, drag to pan.

```swift
struct MindMapView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var selectedNode: MindNode? = nil

    var body: some View {
        ZStack {
            // Background grid — subtle dot pattern
            Canvas { ctx, size in
                // Draw dot grid every 24pt
                let dotColor = Color.axisViolet.opacity(0.06)
                for x in stride(from: 0, to: size.width, by: 24) {
                    for y in stride(from: 0, to: size.height, by: 24) {
                        let rect = CGRect(x: x-1, y: y-1, width: 2, height: 2)
                        ctx.fill(Circle().path(in: rect), with: .color(dotColor))
                    }
                }
            }

            // Connections between nodes (drawn first, behind nodes)
            ForEach(connections) { connection in
                ConnectionLine(from: connection.from, to: connection.to)
            }

            // Nodes
            ForEach(nodes) { node in
                MindNodeView(node: node, isSelected: selectedNode?.id == node.id)
                    .position(node.position)
                    .onTapGesture { selectedNode = node }
            }

            // Selected node detail panel (slides up from bottom)
            if let node = selectedNode {
                NodeDetailPanel(node: node, onClose: { selectedNode = nil })
                    .transition(.move(edge: .bottom))
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .gesture(
            MagnificationGesture()
                .onChanged { value in scale = value.magnitude }
        )
        .gesture(
            DragGesture()
                .onChanged { value in offset = value.translation }
        )
        .animation(.interactiveSpring(), value: scale)
        .clipped()
    }
}

// Node clusters: Work, Relationships, Finance, Health, Knowledge, Projects
// Each cluster is a different color from the Axis palette
// Nodes within clusters are connected by thin lines (0.5pt, axisVioletBorder)
// Clusters connected to each other by slightly thicker lines (1pt)
```

---

## PART 7: BRIEF SCREEN (TAB 4)

Three sub-tabs: Today, World, Learn.

### 7.1 Today Sub-tab

Summary of today's schedule, tasks, and finance snapshot.

```
ScrollView {

    // Date + context header
    HStack {
        VStack(alignment: .leading, spacing: 2) {
            Text(today.formatted(date: .complete, time: .omitted))
                .font(.axisSyne(14))
                .foregroundColor(.axisTextPrimary)
            Text(modeLabel)         // "Builder mode · Site A"
                .font(.axisMono(10))
                .foregroundColor(.axisViolet)
        }
        Spacer()
        // Health summary (if HealthKit connected)
        HStack(spacing: 8) {
            HStack(spacing: 3) {
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 11))
                    .foregroundColor(sleepQualityColor)
                Text("\(sleepHours, specifier: "%.1f")h")
                    .font(.axisMono(11))
                    .foregroundColor(sleepQualityColor)
            }
        }
    }
    .padding(.horizontal, 4)
    .padding(.bottom, 4)

    // Calendar timeline for today
    // Shows meetings as cards, gaps as "free" periods
    VStack(spacing: 6) {
        ForEach(todaySchedule) { block in
            if block.isMeeting {
                MeetingCard(meeting: block)
            } else {
                FreeTimeRow(duration: block.duration)
            }
        }
    }

    Divider().background(Color.axisBorderDefault).padding(.vertical, 8)

    // Finance snapshot (if Stripe/Xero connected)
    FinanceSnapshotCard()

}
.padding(.horizontal, 16)
```

### 7.2 World Sub-tab

Perplexity-powered world brief — news, trends, research relevant to the user's context.

```
ScrollView {
    // Generated by Research skill (Perplexity)
    // Each section has a category label + 2-3 stories

    ForEach(worldBriefSections) { section in
        VStack(alignment: .leading, spacing: 8) {
            Text(section.category)      // "Construction", "Finance", "AI", etc.
                .font(.axisMono(11))
                .foregroundColor(.axisTextMuted)
                .textCase(.uppercase)
                .kerning(1.5)
                .padding(.horizontal, 4)

            ForEach(section.stories) { story in
                AxisCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(story.headline)
                            .font(.axisH2)
                            .foregroundColor(.axisTextPrimary)
                            .lineSpacing(2)

                        Text(story.summary)
                            .font(.axisBody2)
                            .foregroundColor(.axisTextSecondary)
                            .lineSpacing(3)
                            .lineLimit(3)

                        HStack {
                            Text(story.source)
                                .font(.axisMono(10))
                                .foregroundColor(.axisTextMuted)
                            Spacer()
                            Text(story.timeAgo)
                                .font(.axisMono(10))
                                .foregroundColor(.axisTextMuted)
                        }
                    }
                    .padding(14)
                }
                .onTapGesture { openURL(story.url) }
            }
        }
        .padding(.bottom, 8)
    }
}
.padding(.horizontal, 16)
```

### 7.3 Learn Sub-tab

4 rotating micro-lessons. Claude-generated, contextual to what the user is working on.

```
ScrollView {
    VStack(spacing: 10) {
        ForEach(lessons.indices, id: \.self) { index in
            LearnCard(lesson: lessons[index], index: index)
        }
    }
    .padding(.horizontal, 16)
}

struct LearnCard: View {
    let lesson: Lesson
    let index: Int
    @State private var expanded: Bool = false

    var body: some View {
        AxisCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AxisTag(text: lesson.category, color: .axisViolet)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.axisTextMuted)
                }

                Text(lesson.title)
                    .font(.axisH2)
                    .foregroundColor(.axisTextPrimary)
                    .lineSpacing(2)

                if expanded {
                    Text(lesson.content)
                        .font(.axisBody1)
                        .foregroundColor(.axisTextSecondary)
                        .lineSpacing(5)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Text(lesson.preview)
                        .font(.axisBody2)
                        .foregroundColor(.axisTextSecondary)
                        .lineLimit(2)
                }
            }
            .padding(14)
            .animation(.easeInOut(duration: 0.2), value: expanded)
        }
        .onTapGesture { expanded.toggle() }
    }
}
```

---

## PART 8: SIDEBAR

Slides in from the left when hamburger is tapped. Covers 80% of screen width (max 320pt). Tap outside to dismiss.

### 8.1 Layout

```swift
struct SidebarView: View {
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar content
            VStack(spacing: 0) {
                // Header
                SidebarHeader()
                    .padding(.horizontal, 20)
                    .padding(.top, 60) // Accounts for status bar

                Divider()
                    .background(Color.axisBorderDefault)
                    .padding(.vertical, 16)

                // Navigation items
                SidebarNavItem(icon: "bell.fill", label: "Signal") { navigateTo(.signal) }
                SidebarNavItem(icon: "calendar", label: "Schedule") { navigateTo(.schedule) }
                SidebarNavItem(icon: "network", label: "Connections") { navigateTo(.connections) }
                SidebarNavItem(icon: "cpu", label: "Capabilities") { navigateTo(.capabilities) }

                Spacer()

                Divider().background(Color.axisBorderDefault)

                SidebarNavItem(icon: "gearshape.fill", label: "Settings") { navigateTo(.settings) }
                    .padding(.bottom, 32)
            }
            .frame(width: min(UIScreen.main.bounds.width * 0.8, 320))
            .background(Color.axisSurface1)
            .overlay(
                Rectangle()
                    .fill(Color.axisBorderDefault)
                    .frame(width: 0.5),
                alignment: .trailing
            )

            // Tap-to-dismiss overlay
            Color.black.opacity(0.5)
                .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { isVisible = false } }
        }
        .ignoresSafeArea()
    }
}

struct SidebarHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            AxisMark(size: 28, color: .axisViolet)
            VStack(alignment: .leading, spacing: 2) {
                Text("AXIS")
                    .font(.axisSyne(18))
                    .foregroundColor(.axisTextPrimary)
                Text("extend the mind")
                    .font(.axisMono(9))
                    .foregroundColor(.axisViolet.opacity(0.4))
                    .kerning(2)
            }
        }
    }
}

struct SidebarNavItem: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.axisViolet)
                    .frame(width: 22)
                Text(label)
                    .font(.axisBody(15, weight: .medium))
                    .foregroundColor(.axisTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.axisTextMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}
```

### 8.2 Connections Screen (from sidebar)

```
NavigationView {
    ScrollView {

        // Connected section
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "Connected")

            ConnectionRow(
                icon: "gmail-icon",
                name: "Gmail",
                status: .connected,
                subtitle: "Read + send · Last sync 2 min ago",
                onDisconnect: { disconnectGmail() }
            )

            ConnectionRow(
                icon: "calendar-icon",
                name: "Google Calendar",
                status: .connected,
                subtitle: "Meeting prep · Last sync 5 min ago",
                onDisconnect: { disconnectCalendar() }
            )
        }

        // Available section
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "Available")

            ConnectionRow(name: "Spotify", status: .disconnected, subtitle: "Music + entertainment")
            ConnectionRow(name: "Stripe", status: .disconnected, subtitle: "Invoices + cash flow")
            ConnectionRow(name: "Xero", status: .disconnected, subtitle: "Accounting")
            ConnectionRow(name: "Slack", status: .disconnected, subtitle: "Team communication")
            ConnectionRow(name: "WhatsApp Business", status: .disconnected, subtitle: "Business messages")
        }

    }
    .padding(.horizontal, 16)
    .navigationTitle("Connections")
    .navigationBarTitleDisplayMode(.inline)
}

// Connection row:
struct ConnectionRow: View {
    let name: String
    let status: ConnectionStatus
    let subtitle: String
    var onConnect: (() -> Void)? = nil
    var onDisconnect: (() -> Void)? = nil

    var body: some View {
        AxisCard {
            HStack(spacing: 12) {
                // Service logo/icon (32pt circle)
                Circle()
                    .fill(Color.axisSurface2)
                    .frame(width: 40, height: 40)
                    .overlay(Text(name.prefix(1)).font(.axisH2).foregroundColor(.axisTextSecondary))

                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.axisH2).foregroundColor(.axisTextPrimary)
                    Text(subtitle).font(.axisBody2).foregroundColor(.axisTextSecondary)
                }

                Spacer()

                Button(status == .connected ? "Disconnect" : "Connect") {
                    status == .connected ? onDisconnect?() : onConnect?()
                }
                .font(.axisBody(13, weight: .medium))
                .foregroundColor(status == .connected ? .axisRed : .axisViolet)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    (status == .connected ? Color.axisRed : Color.axisViolet).opacity(0.1)
                )
                .cornerRadius(AxisRadius.pill)
            }
            .padding(14)
        }
    }
}
```

---

## PART 9: OS SURFACES

### 9.1 Lock Screen Widget (accessoryRectangular)

Shown on the lock screen. Most-seen Axis surface. Updates every 15 minutes.

```swift
// Widgets/LockScreenWidget.swift
struct LockScreenWidgetView: View {
    let entry: AxisSignalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Signal text — 2 lines max
            Text(entry.signal)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            // Action buttons row
            HStack(spacing: 6) {
                // Done button (App Intent — executes without opening app)
                Button(intent: MarkDoneIntent()) {
                    Label("Done", systemImage: "checkmark")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(.green)

                // Snooze button
                Button(intent: SnoozeIntent()) {
                    Label("Later", systemImage: "clock")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
        }
    }
}
```

**Widget provider:**
```swift
struct AxisLockWidgetProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<AxisSignalEntry>) -> Void) {
        Task {
            let signal = try? await APIService.shared.fetchCurrentSignal()
            let entry = AxisSignalEntry(
                date: .now,
                signal: signal?.text ?? "Axis is watching...",
                urgency: signal?.urgency ?? 0,
                actionType: signal?.actionType ?? ""
            )
            // Refresh 15 minutes after the dispatch job would have run
            let nextRefresh = Date().addingTimeInterval(15 * 60)
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }
}
```

### 9.2 Home Screen Medium Widget (systemMedium)

```swift
struct HomeScreenMediumView: View {
    let entry: AxisHomeEntry

    var body: some View {
        HStack(spacing: 0) {
            // Left: Signal
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    AxisMark(size: 14, color: .white.opacity(0.9))
                    Text("SIGNAL")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .kerning(1.5)
                }

                Text(entry.signal)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(3)

                Button(intent: MarkDoneIntent()) {
                    Text("Done ✓")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(100)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)

            // Right divider
            Rectangle().fill(Color.white.opacity(0.08)).frame(width: 0.5)

            // Right: MIT count + time
            VStack(spacing: 6) {
                Text("\(entry.mitCount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("tasks today")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)

                Spacer()

                Text(entry.nextEventTime)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 90)
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
        }
        .background(Color(hex: "#110F1C"))
        .widgetURL(URL(string: "axis://situation"))
    }
}
```

### 9.3 Push Notification Categories

Registered in AppDelegate at launch:

```swift
func registerNotificationCategories() {
    let sendAction    = UNNotificationAction(identifier: "SEND",    title: "Send",       options: .authenticationRequired)
    let editAction    = UNNotificationAction(identifier: "EDIT",    title: "Edit",       options: .foreground)
    let laterAction   = UNNotificationAction(identifier: "LATER",   title: "Later",      options: [])
    let doneAction    = UNNotificationAction(identifier: "DONE",    title: "Done ✓",     options: [])
    let snoozeAction  = UNNotificationAction(identifier: "SNOOZE",  title: "Snooze 2h",  options: [])
    let callAction    = UNNotificationAction(identifier: "CALL",    title: "Call them",  options: .foreground)
    let readAction    = UNNotificationAction(identifier: "READ",    title: "Read brief", options: .foreground)
    let dismissAction = UNNotificationAction(identifier: "DISMISS", title: "Dismiss",    options: [])

    UNUserNotificationCenter.current().setNotificationCategories([
        UNNotificationCategory(
            identifier: "EMAIL_DRAFT",
            actions: [sendAction, editAction, laterAction],
            intentIdentifiers: [], options: .customDismissAction
        ),
        UNNotificationCategory(
            identifier: "INVOICE_REMINDER",
            actions: [sendAction, callAction, snoozeAction],
            intentIdentifiers: [], options: []
        ),
        UNNotificationCategory(
            identifier: "MEETING_PREP",
            actions: [readAction, dismissAction],
            intentIdentifiers: [], options: []
        ),
        UNNotificationCategory(
            identifier: "SIGNAL_ALERT",
            actions: [doneAction, snoozeAction],
            intentIdentifiers: [], options: []
        ),
        UNNotificationCategory(
            identifier: "GPS_MODE_SWITCH",
            actions: [dismissAction],
            intentIdentifiers: [], options: []
        ),
    ])
}
```

### 9.4 Deep Link Routing

Every notification and widget tap routes to the right place in the app.

```swift
// In AxisApp.swift
.onOpenURL { url in
    switch url.host {
    case "situation":    selectedTab = 0
    case "thread":       selectedTab = 1
    case "mind":         selectedTab = 2
    case "brief":        selectedTab = 3
    case "signal":       selectedTab = 0; showSignalDetail = true
    case "email_draft":  selectedTab = 1; showEmailDraft(id: url.pathComponents[1])
    case "meeting_prep": selectedTab = 0; showMeetingPrep(id: url.pathComponents[1])
    default: break
    }
}
```

---

## PART 10: MICRO-INTERACTIONS AND ANIMATIONS

### 10.1 Page Transitions

- Tab switch: No animation — instant. iOS standard.
- Sidebar open/close: `.easeInOut(duration: 0.25)`, `.move(edge: .leading)`
- Sheet presentation: Standard iOS modal sheet (half-height for quick actions, full-height for detail views)
- Navigate to detail: Push navigation, `.navigationTransition(.slide)`

### 10.2 Loading States

Every data-fetching screen shows a skeleton before content loads.

```swift
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.axisSurface2,
                        Color.axisSurface3,
                        Color.axisSurface2
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AxisRadius.sm)
            .opacity(isAnimating ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}
```

### 10.3 Completion Animation

When a task is marked done:
1. Checkmark circle fills from the center outward — spring animation, 0.3s
2. Row background briefly flashes axisGreenDim
3. Row fades out while remaining rows shift up — easeInOut, 0.25s

### 10.4 Haptics

```swift
// Every significant action gets haptic feedback
enum AxisHaptic {
    static let impact  = UIImpactFeedbackGenerator(style: .medium)
    static let success = UINotificationFeedbackGenerator()
    static let error   = UINotificationFeedbackGenerator()

    static func markDone()    { success.notificationOccurred(.success) }
    static func send()        { impact.impactOccurred() }
    static func error()       { error.notificationOccurred(.error) }
    static func tap()         { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func urgent()      { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}
```

Usage rules:
- Mark task done → `.success` haptic
- Send email → `.impact` medium
- Error / failed send → `.error` haptic
- Every button tap → `.light` impact
- Urgent signal arriving (via BGTask) → `.warning` haptic

### 10.5 The Axis Mark on Launch

When the app launches cold (not from background):
1. Black screen
2. Axis mark scales in from 0.7 + opacity 0 → 1.0 opacity, spring animation, 0.5s
3. "AXIS" wordmark fades in underneath, 0.2s delay
4. After 0.8s total → fade to main tab view

This only plays when the app was force-quit and relaunches from scratch. Background wakes skip this.

---

## PART 11: SETTINGS SCREEN

```
NavigationView {
    List {
        // Account section
        Section("Account") {
            AccountRow(email: user.email, name: user.name)

            NavigationLink("Subscription") {
                SubscriptionView()
            }
        }

        // Preferences section
        Section("Preferences") {
            // Mode picker
            HStack {
                Text("Default mode")
                    .foregroundColor(.axisTextPrimary)
                Spacer()
                Picker("", selection: $defaultMode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .tint(.axisViolet)
            }

            // Notification time preferences
            NavigationLink("Notification hours") {
                NotificationPrefsView()
            }

            // Saved locations for GPS mode switching
            NavigationLink("Saved locations") {
                SavedLocationsView()
            }
        }

        // Data section
        Section("Intelligence") {
            NavigationLink("What Axis learned") {
                ApprenticeView()  // The learned patterns dashboard
            }

            Toggle("Health routing", isOn: $healthRoutingEnabled)
                .tint(.axisViolet)

            Toggle("Entertainment in brief", isOn: $entertainmentEnabled)
                .tint(.axisViolet)
        }

        // Privacy
        Section("Privacy & Data") {
            NavigationLink("Connected apps") {
                ConnectionsView()
            }

            Button("Export my data") { exportData() }
                .foregroundColor(.axisViolet)

            Button("Delete my account") { showDeleteConfirmation = true }
                .foregroundColor(.axisRed)
        }

        // Sign out
        Section {
            Button("Sign out") { signOut() }
                .foregroundColor(.axisRed)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    .listStyle(.insetGrouped)
    .scrollContentBackground(.hidden)
    .background(Color.axisBackground)
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.inline)
}
```

**List styling:**
- List section headers: axisMono(11), axisTextMuted, uppercase, kerning 1.5
- List rows: background = axisSurface1, separator = axisBorderDefault at 0.5pt
- Toggle tint: axisViolet
- Disclosure chevrons: axisTextMuted, system small

---

## PART 12: QUICK REFERENCE — KEY MEASUREMENTS

| Element | Value |
|---|---|
| Screen horizontal padding | 16pt |
| Card internal padding | 14–16pt |
| Card corner radius | 16pt (AxisRadius.lg) |
| Card border width | 0.5pt |
| Tab bar height | System (83pt with safe area) |
| Navigation bar height | System (56pt) |
| Button height (primary) | 52pt |
| Input field height (single line) | 52pt |
| Section header font | JetBrains Mono 11pt, uppercase, 1.5 kerning |
| Body copy line spacing | 4–5pt additional |
| Minimum touch target | 44×44pt |
| Widget refresh interval | 15 minutes |
| Sidebar width | min(80% screen width, 320pt) |
| Message bubble max width | ~75% screen width |
| Avatar size (Thread) | 28pt circle |
| Skeleton animation duration | 1.0s, repeating |

---

## PART 13: BUILD ORDER

Build in this exact order. Each step should be deployable and testable before moving to the next.

1. **DesignSystem** — Colors, Typography, Spacing, all base components (2 days)
2. **Navigation shell** — Empty MainTabView with 4 tabs + sidebar structure (1 day)
3. **APIService.swift** — Auth with Clerk JWT, all endpoints wired (1 day)
4. **Situation screen** — Morning brief card + Signal hero card + MIT section (3 days)
5. **Thread screen** — Message bubbles, ActionButtonRow, ThreadInputBar (3 days)
6. **Onboarding flow** — All 5 steps, permission requests, Gmail OAuth connect (2 days)
7. **Mind/Journal** — Journal tab only first, then Skill Tree, then Map (3 days)
8. **Brief screen** — All 3 sub-tabs (2 days)
9. **Sidebar + Settings** — All sidebar navigation, Settings screen (2 days)
10. **Lock screen widget** — AxisSignalEntry + interactive buttons + provider (1 day)
11. **App Intents** — All 8 Siri intents + AxisShortcuts registration (2 days)
12. **APNs** — Category registration + action handling + deep links (1 day)
13. **HealthKit** — Permissions + SleepContext → APIService (1 day)
14. **CoreLocation** — Geofencing setup + mode switching (1 day)
15. **BGTaskScheduler** — Background refresh + widget timeline update (1 day)
16. **Share Extension** — Universal capture from any app (1 day)
17. **TestFlight** — Build, sign, submit for external testing (1 day)

**Total estimate:** ~25 developer days (5 weeks solo / 3 weeks with pair)

---

*Copy this file into ~/forge/axis-ios/DESIGN_SPEC.md*
*Reference it in every Cursor session before starting iOS work*
*Do not deviate from the design system — every screen must use AxisCard, AxisTag, AxisButton, etc.*
*Real device testing required before every PR — simulator misrepresents performance and haptics*
