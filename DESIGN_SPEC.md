# AXIS iOS — Design & Build Specification v3.0
## April 2026 · Vision finalised · Capture-first · Three surfaces · Normal people primary market
## Save as ~/forge/axis-ios/DESIGN_SPEC.md

---

## CRITICAL CHANGES FROM v2.1

This version reflects the finalised product vision. Key changes:

1. **Capture-first onboarding** — OAuth is the upgrade, not the gate
2. **Three surfaces are the product** — voice, widget, notifications. App is config layer.
3. **Normal people primary market** — not just founders/business
4. **Natural language capture** — auto-classifies, no user-facing categories
5. **Travel time** — school pickup, meeting departure, leave now
6. **AirPods brief** — audio output, no screen required
7. **Discovery layer** — personalised recommendations from memory
8. **Widget is the most important screen** — more than any in-app tab
9. **Notification restraint** — max 3/day, each worth interrupting for
10. **App opened zero times = product working correctly**

---

## PART 1: DESIGN SYSTEM

### 1.1 Colors

```swift
extension Color {
    static let axisBackground     = Color(hex: "#0C0A15")
    static let axisSurface1       = Color(hex: "#110F1C")
    static let axisSurface2       = Color(hex: "#1A1826")
    static let axisSurface3       = Color(hex: "#22203A")
    static let axisViolet         = Color(hex: "#8B5CF6")
    static let axisVioletDim      = Color(hex: "#8B5CF6").opacity(0.12)
    static let axisVioletBorder   = Color(hex: "#8B5CF6").opacity(0.18)
    static let axisGreen          = Color(hex: "#10B981")
    static let axisGreenDim       = Color(hex: "#10B981").opacity(0.12)
    static let axisAmber          = Color(hex: "#F59E0B")
    static let axisAmberDim       = Color(hex: "#F59E0B").opacity(0.12)
    static let axisRed            = Color(hex: "#EF4444")
    static let axisRedDim         = Color(hex: "#EF4444").opacity(0.12)
    static let axisTextPrimary    = Color(hex: "#F0EEFF")
    static let axisTextSecondary  = Color(hex: "#F0EEFF").opacity(0.55)
    static let axisTextMuted      = Color(hex: "#F0EEFF").opacity(0.28)
    static let axisBorderDefault  = Color(hex: "#8B5CF6").opacity(0.08)
    static let axisBorderStrong   = Color(hex: "#8B5CF6").opacity(0.18)
    static let axisBorderInput    = Color(hex: "#8B5CF6").opacity(0.14)
    static let axisBorderDashed   = Color(hex: "#F59E0B").opacity(0.4)
}
```

Always dark. No light mode. `.preferredColorScheme(.dark)` on root.

### 1.2 Typography

```swift
extension Font {
    static func axisSyne(_ size: CGFloat) -> Font {
        Font.custom("Syne-ExtraBold", size: size)
    }
    static func axisBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom(weight == .medium ? "InstrumentSans-Medium" : "InstrumentSans-Regular", size: size)
    }
    static func axisMono(_ size: CGFloat) -> Font {
        Font.custom("JetBrainsMono-Medium", size: size)
    }

    static let axisHero:    Font = axisSyne(32)
    static let axisTitle:   Font = axisSyne(22)
    static let axisH1:      Font = axisBody(17, weight: .medium)
    static let axisH2:      Font = axisBody(15, weight: .medium)
    static let axisBody1:   Font = axisBody(15)
    static let axisBody2:   Font = axisBody(13)
    static let axisCaption: Font = axisBody(12)
    static let axisLabel:   Font = axisMono(11)
    static let axisMicro:   Font = axisMono(9)
}
```

### 1.3 Spacing and Radius

```swift
enum AxisSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum AxisRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let pill: CGFloat = 100
}
```

---

## PART 2: ONBOARDING — CAPTURE FIRST

**The rule:** Day one value before any OAuth connection. The product must be useful the moment someone types their first thought.

### Screen 1 — Brand moment
Full dark. AxisMark animates in. "AXIS" in Syne 40. "Extend the mind" in mono 10 at 35% opacity. "Get started" button.

### Screen 2 — The fridge note
Full screen. Large text, generous line height:

```
"What have you been
meaning to do?"
```

Below it — a large text input, placeholder "Anything. Call someone, book something, find something, remember something..." and a voice button. No categories. No structure. Just catch it.

Save button → POST /capture with the text.

This is the entire value proposition in one interaction. The user captures one thought and Axis has already started working.

### Screen 3 — What Axis does with it
After the first capture saves, show a simple card:

"Axis caught that. It'll surface it at the right moment — not a fixed reminder you'll dismiss, the actual right time based on your day."

One button: "Add more" or "Continue."

### Screen 4 — Privacy
"What Axis reads. What Axis never does." Link to tryaxis.app/privacy. "I understand" button.

### Screen 5 — Upgrade (optional connections)
"Connect Gmail and Calendar to let Axis read your world — not just what you tell it."

Gmail connect card. Calendar connect card. "Skip for now" always visible and prominent. Not buried. Not shamed.

### Screen 6 — Ready
"Axis is watching." Brief animation of the AxisMark. "Enter Axis" → sets onboarding complete.

**The key shift from v2.1:** Onboarding is now complete before OAuth. The product delivers value from Screen 2 onward. Connections make it smarter but are never required.

---

## PART 3: NAVIGATION

### Tab bar (4 tabs — locked)

```swift
TabView(selection: $selectedTab) {
    SituationView().tag(0)
        .tabItem { Label("Situation", systemImage: "eye.fill") }
    AxisThreadView().tag(1)
        .tabItem { Label("Axis", systemImage: "bubble.left.fill") }
    MindView().tag(2)
        .tabItem { Label("Mind", systemImage: "brain.head.profile") }
    BriefView().tag(3)
        .tabItem { Label("Brief", systemImage: "sun.max.fill") }
}
.tint(.axisViolet)
```

### Sidebar (slides from LEFT)
Signal · Schedule · Connections · Capabilities · Settings

**Scheduling rule:** Axis (Thread) tab = write via NLP. Sidebar Schedule = read-only calendar view. Never show manual event creation in the sidebar.

---

## PART 4: SITUATION SCREEN (TAB 1)

The default home. What's happening right now.

```swift
ScrollView {
    VStack(alignment: .leading, spacing: AxisSpacing.base) {

        // Greeting + streak
        GreetingHeader()

        // Morning brief (before 10AM or unread)
        if showMorningBrief { MorningBriefCard(brief: brief) }

        // Travel time alert (active when event approaching)
        if let departure = upcomingDeparture { TravelTimeCard(departure: departure) }

        // Top signal (urgency-ranked)
        if let signal = topSignal { SignalHeroCard(signal: signal) }

        // Capture prompt (if no signals — not empty state, invitation)
        if signals.isEmpty && brief == nil { CapturePromptCard() }

        // Silent count
        if silentCount > 0 { AxisHandledCard(count: silentCount) }
    }
    .padding(.horizontal, AxisSpacing.base)
}
.background(Color.axisBackground)
```

### Travel Time Card — new, critical

```swift
struct TravelTimeCard: View {
    let departure: DepartureAlert

    var body: some View {
        AxisCard(elevated: true) {
            HStack(spacing: 14) {
                Image(systemName: "car.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.axisAmber)
                    .frame(width: 36, height: 36)
                    .background(Color.axisAmberDim)
                    .cornerRadius(AxisRadius.sm)

                VStack(alignment: .leading, spacing: 3) {
                    Text(departure.title)
                        .font(.axisH2)
                    Text("Leave in \(departure.minutesUntilDepart) min · \(departure.driveTime) min drive")
                        .font(.axisMono(11))
                        .foregroundColor(.axisAmber)
                }
                Spacer()
                Text(departure.eventTime, style: .time)
                    .font(.axisMono(12))
                    .foregroundColor(.axisTextMuted)
            }
            .padding(14)
        }
    }
}
```

### Capture Prompt Card — replaces empty state

When no signals and no brief — not "all clear" which implies Axis stopped. Instead:

```swift
struct CapturePromptCard: View {
    @State private var text = ""

    var body: some View {
        AxisCard(elevated: true, accent: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What's on your mind?")
                    .font(.axisH2)
                AxisTextField(
                    placeholder: "Anything you've been meaning to do...",
                    text: $text,
                    multiline: true
                )
                if !text.isEmpty {
                    Button("Tell Axis") { submitCapture() }
                        .font(.axisBody(14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.axisViolet)
                        .cornerRadius(AxisRadius.pill)
                }
            }
            .padding(14)
        }
    }
}
```

---

## PART 5: AXIS SCREEN (TAB 2)

The conversational layer. Also the capture input for anything that needs more context.

### Layout

```swift
VStack(spacing: 0) {
    // Topic bubbles (when messages exist)
    if !messages.isEmpty { TopicBubbles(selected: $topic) }

    // Message list
    ScrollView { LazyVStack { ForEach(messages) { MessageBubble($0) } } }

    // Dream button in nav bar
    // Command bar pinned to keyboard
    ThreadCommandBar(onSend: sendMessage)
}
```

### Topic bubbles (10 categories)
Work · Personal · Health · Money · Travel · Family · Learning · Ideas · Errands · Social

Filter messages client-side. No API call on filter change.

### Dream button
Nav bar trailing. Compresses thread into a context note, archives messages, resets thread.

```swift
// Confirmation alert
"Axis will compress this conversation into a context note, then reset the thread. Nothing is lost."
// [Dream] [Cancel]
```

### Natural language commands (auto-detected, no UI)
```
"remember X"          → POST /notes
"what do I know about X" → GET /notes/search
"status of X"         → POST /status
"watch X for me"      → POST /watches
"schedule X with Y at Z" → POST /schedule/parse → ScheduleConfirmCard
"remind me to X when Y"  → POST /capture with location/time trigger
```

### Voice input (5 states)
idle · listening · processing · error · noise

See CLAUDE.md v6.0 Feature 25 for full spec.

### Command bar placeholder
"Capture anything, or ask Axis..." — not "Message Axis" which implies chat. Axis is not a chatbot. Axis is a coordinator.

---

## PART 6: MIND SCREEN (TAB 3)

Three sub-tabs: Map · Skill Tree · Journal

Default: Journal.

### Journal
Daily rotating question (7 questions, one per weekday). 30-second answer. POST /journal. Claude extracts entities, people, emotions, decisions — all appended to user model.

Streak display with flame icon. Day count.

Past entries grouped by week. Tap any entry to expand.

### Life Map
7 domain nodes: Work · Money · Relationships · Health · Knowledge · Growth · Ideas

Canvas-based, pinch to zoom. Gap domains (no journal mentions in 3+ weeks) render at 40% opacity with "Xw quiet" label in axisRed. Tap domain → detail panel slides up.

### Skill Tree
Tiers: Spark → Ember → Forge → Legend. Axis verifies from real activity. Cannot be manually inflated. Tap unlocked badge → iOS share sheet. Achievement unlock: subtle confetti, not aggressive.

---

## PART 7: BRIEF SCREEN (TAB 4)

Three sub-tabs: Today · World · Learn

### Today tab

```swift
ScrollView {
    VStack(alignment: .leading, spacing: AxisSpacing.base) {

        // Date and play button
        HStack {
            Text(Date(), style: .date).font(.axisSyne(14))
            Spacer()
            // ElevenLabs play button — plays through AirPods
            Button { playBrief() } label: {
                HStack(spacing: 6) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    Text(isPlaying ? "Stop" : "Listen")
                }
                .font(.axisBody(13, weight: .medium))
                .foregroundColor(.axisViolet)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color.axisVioletDim)
                .cornerRadius(AxisRadius.pill)
            }.buttonStyle(.plain)
        }

        // Brief messages
        ForEach(brief.messages) { msg in
            AxisCard { Text(msg.content).font(.axisBody1).lineSpacing(5).padding(14) }
        }

        // Calendar events
        if let events = brief.calendarEvents { CalendarSection(events: events) }

        // Daily discovery (from memory layer)
        if let rec = todaysRecommendation { DiscoveryCard(recommendation: rec) }

        // Sign-off
        Text("Your move.")
            .font(Font.custom("InstrumentSans-Regular", size: 14).italic())
            .foregroundColor(.axisTextMuted)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding(.horizontal, AxisSpacing.base)
}
```

### Discovery Card — new

```swift
struct DiscoveryCard: View {
    let recommendation: Recommendation // podcast | article | book | product

    var icon: String {
        switch recommendation.type {
        case "podcast": return "headphones"
        case "article": return "doc.text"
        case "book":    return "book"
        case "product": return "bag"
        default:        return "sparkles"
        }
    }

    var body: some View {
        AxisCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AxisTag("For you today", color: .axisViolet)
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.axisViolet)
                }
                Text(recommendation.title).font(.axisH2).lineSpacing(2)
                Text(recommendation.reason)
                    .font(.axisBody2)
                    .foregroundColor(.axisTextSecondary)
                    .lineSpacing(3)
                Link(recommendation.source, destination: recommendation.url)
                    .font(.axisMono(10))
                    .foregroundColor(.axisViolet)
            }.padding(14)
        }
    }
}
```

### World tab
Perplexity-powered. 4 story cards. Tags: Conflict · Markets · Tech · Local. Personalised to user context over time. "World intelligence personalises as Axis learns more about you" footer.

### Learn tab
Rotating lesson cards. 4 lessons: Financial literacy · Business · Psychology · History. "Next lesson →" cycles through. Compounds over time.

---

## PART 8: SIDEBAR

### Signal view
Three filter tabs: Now (urgency 8-10, red) · Today (5-7, amber) · When you can (<5, violet).

Signal urgency is ALWAYS language. Never show the number.

Swipe left on any signal card to dismiss. Empty state: "Nothing urgent right now. Axis is watching." — never "All clear."

### Schedule view (READ-ONLY)
Events from /brief/today. Read-only. Empty state: "Tell Axis in the chat tab to schedule anything."

Prompt text: "Talk to Axis to schedule. This view shows what's been scheduled."

### Connections view
Gmail · Google Calendar · Spotify · Stripe. Connected/not connected status. "Connect" button for unconnected services. No OAuth in sidebar — tapping "Connect" opens Safari for the OAuth flow.

### Capabilities view
Skills from /skills. Icon computed from name. Connected status dot. No toggle — enabling/disabling skills is via the Axis thread ("disable my finance skill").

### Settings view
```
Account section
What Axis should always know (context notes TextEditor)
Wake time (DatePicker — brief fires at wake_time - 10min, not hardcoded 6:50AM)
Intelligence (Apprentice visibility link)
Privacy & Data (Privacy policy link, Delete account)
Sign out
```

---

## PART 9: OS SURFACES

### Lock screen widget (accessoryRectangular)

The most important screen in the product.

```swift
struct LockScreenWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AxisSignal", provider: AxisSignalProvider()) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.signal ?? "Axis is watching")
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Button(intent: MarkDoneIntent()) {
                        Label("Done", systemImage: "checkmark")
                            .font(.system(size: 11, weight: .medium))
                    }.buttonStyle(.bordered).tint(.green)
                    Button(intent: SnoozeIntent()) {
                        Label("Later", systemImage: "clock")
                            .font(.system(size: 11, weight: .medium))
                    }.buttonStyle(.bordered)
                }
            }
        }
        .configurationDisplayName("Axis Signal")
        .description("Your top signal with actions.")
        .supportedFamilies([.accessoryRectangular])
    }
}
```

Updates every 15 minutes from dispatch loop. No user configuration. Axis decides what to show.

### Home screen medium widget (systemMedium)

Left half: top signal + Done button.
Right half: MIT count + next event + travel time if departing soon.

### Push notification categories (5)

```swift
UNNotificationCategory(
    identifier: "SIGNAL_ALERT",
    actions: [
        UNNotificationAction(identifier: "DONE", title: "Done", options: .authenticationRequired),
        UNNotificationAction(identifier: "SNOOZE", title: "Snooze 2h", options: [])
    ]
)

UNNotificationCategory(
    identifier: "EMAIL_DRAFT",
    actions: [
        UNNotificationAction(identifier: "SEND", title: "Send", options: .authenticationRequired),
        UNNotificationAction(identifier: "EDIT", title: "Edit", options: .foreground),
        UNNotificationAction(identifier: "LATER", title: "Later", options: [])
    ]
)

UNNotificationCategory(
    identifier: "MEETING_PREP",
    actions: [
        UNNotificationAction(identifier: "READ", title: "Read brief", options: .foreground),
        UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: [])
    ]
)

UNNotificationCategory(
    identifier: "TRAVEL_TIME",
    actions: [
        UNNotificationAction(identifier: "MAPS", title: "Open Maps", options: .foreground),
        UNNotificationAction(identifier: "DISMISS", title: "Got it", options: [])
    ]
)

UNNotificationCategory(
    identifier: "SILENCE_DETECTED",
    actions: [
        UNNotificationAction(identifier: "FOLLOW_UP", title: "Follow up", options: .foreground),
        UNNotificationAction(identifier: "LATER", title: "Remind me later", options: [])
    ]
)
```

### Siri App Intents (8 — all required)

```swift
"Hey Siri, add to Axis: [text]"              → AddToAxisIntent
"Hey Siri, what's my Axis signal?"            → GetSignalIntent (reads aloud)
"Hey Siri, mark my Axis signal done"          → MarkDoneIntent
"Hey Siri, what's on today?"                  → GetBriefIntent
"Hey Siri, tell Axis: [anything]"             → AddToAxisIntent
"Hey Siri, switch Axis to Builder mode"       → SetModeIntent
"Hey Siri, send that Axis reply"              → SendReplyIntent
"Hey Siri, what's in my Axis brief?"          → GetBriefIntent (reads aloud via ElevenLabs)
```

### Dynamic Island (Live Activity)

Active when Axis is handling something:
- Compact: AxisMark icon + "Handling 3 things"
- Expanded: list of what's being handled
- Dismiss when complete

### AirPods brief (audio output)

ElevenLabs reads morning digest aloud. Triggered at wake_time. Plays through AirPods. No screen interaction required. User can say "Hey Siri, stop" to pause.

This is the ambient surface. Working while you make coffee. No phone in hand.

---

## PART 10: CAPTURE SYSTEM

The most important new system. Works before any OAuth connection.

### Capture model

```swift
struct Capture: Codable, Identifiable {
    let id: UUID
    let content: String
    let captureType: String    // relationship_task | calendar_task | research_task |
                               // reminder | discovery_intent | follow_up | personal_goal
    let person: String?
    let urgency: Int
    let suggestedTime: String  // morning | quiet_gap | contextual | weekly
    let locationTrigger: String?
    let isHandled: Bool
    let createdAt: Date
}
```

### Quick Capture (floating button)

Purple + button, 52pt, bottom right, all screens except onboarding.

Tap → modal slides up:
- Large text input (auto-focus)
- Voice button (mic icon, 5 states)
- Claude classifies in background on submit
- "Axis caught that" confirmation banner

No categories shown to user. No structure. Just caught.

### Backend: POST /capture

```python
# Receives raw text or voice transcript
# Claude classifies into capture type
# Extracts: person, urgency, timing, location trigger
# Saves to captures table
# If calendar_task: suggests a time slot
# If relationship_task: checks relationship graph for context
# If research_task: queues for Perplexity lookup
# Returns classified capture with suggested action
```

---

## PART 11: TRAVEL TIME SYSTEM

**The feature Siri promised in 2011 and never delivered.**

### How it works

1. Dispatch reads upcoming calendar events
2. For each event with a location: Google Maps API calculates drive time from user's current location
3. Departure time = event start - drive time - 5min buffer
4. Notification fires at departure time
5. Widget updates to show "Leave in X minutes"

### The school pickup example

User captured: "Pick up kids from school at 3:30pm"
→ Calendar task created at St Peters Primary School, 3:30PM
→ Dispatch checks at 2:45PM: school is 18 minutes away
→ Notification at 3:07PM: "Leave in 5 minutes for school pickup — 18 min drive"
→ One tap opens Maps

This is the product in one interaction.

### Backend endpoint needed

```python
GET /me/travel-alert
# Returns departure alerts for events in next 2 hours
# { event_title, minutes_until_depart, drive_time, destination }
# Uses Google Maps Distance Matrix API
# Falls back to no alert if location not available
```

---

## PART 12: DISCOVERY SYSTEM

One recommendation per day. Personalised. From the memory layer.

Sources: Spotify (music/podcast) · Apple Podcasts API · Perplexity (articles) · Google Shopping (products)

### How personalisation works

1. Weekly improvement job reads journal entries + captures
2. Extracts interest graph: topics mentioned, domains active, goals stated
3. Perplexity queries "best [podcast/article] about [topic] for someone who [context]"
4. Returns one recommendation with a reason

### The reason is everything

Not "you might like this." Specific: "You mentioned wanting to understand investing better in Tuesday's journal. This podcast episode covers compound interest in under 20 minutes."

The reason surfaces the memory layer visibly. User sees that Axis knows them. That's the retention moment.

---

## PART 13: QUICK REFERENCE

| Element | Value |
|---------|-------|
| Screen horizontal padding | 16pt |
| Card internal padding | 14-16pt |
| Card corner radius | 16pt |
| Card border width | 0.5pt |
| Quick capture button | 52pt circle, bottom right |
| Input field height | 52pt single line |
| Minimum touch target | 44×44pt |
| Widget refresh | 15 minutes |
| Sidebar width | min(80% screen, 320pt) |
| Notification max per day | 3 |
| Signal urgency display | Language only: Now/Today/When you can |
| Empty state | Never "All clear" — always "Axis is watching" |
| App opens per day target | 0 (ambient working correctly) |

---

## PART 14: BUILD ORDER

### This week
1. Real device sign-in — Clerk token to Railway
2. Signal deduplication on backend
3. Skip-if-empty dispatch
4. OpenRouter integration

### Next two weeks
5. Capture-first onboarding (Screen 2 is fridge note, not OAuth)
6. POST /capture endpoint with Claude classification
7. Quick capture button wired to /capture
8. Travel time: Google Maps API + departure notifications
9. Discovery card in Brief Today tab

### When Apple Developer activates
10. APNs — all 5 notification categories
11. Lock screen widget — WidgetKit
12. App Intents — all 8 Siri commands
13. Background app refresh — BGTaskScheduler

### Month two
14. Calendar write actions (Axis schedules, not just reads)
15. AirPods brief (ElevenLabs audio output routing)
16. Dynamic Island live activity
17. Discovery recommendation system

### Month three
18. Silence as signal (Pro tier)
19. Decision memory (Pro tier)
20. Android build begins

---

*Copy to ~/forge/axis-ios/DESIGN_SPEC.md*
*Load at the start of every Xcode and Claude Code iOS session*
*The app is the config layer. The product is voice, widget, notifications.*
*Measure success by how rarely the app needs to be opened.*
*END OF AXIS iOS DESIGN SPEC v3.0*
