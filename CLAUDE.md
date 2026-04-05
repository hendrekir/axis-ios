# AXIS iOS — Claude Code Master Build Guide

## What You're Building

Axis is an ambient AI agent iOS app. Think Jarvis — not a chatbot, not an assistant you
summon. Axis watches continuously, surfaces signals, and acts on your behalf. The tone is
calm, confident, dark. No clutter. No noise. Just intelligence.

**Vision:** The user opens Axis and it already knows what matters. It doesn't wait to be asked.

---

## Stack

- **iOS**: SwiftUI, iOS 17+, iPhone 17 Pro simulator
- **Auth**: Clerk iOS SDK (already installed) — production keys `pk_live_`
- **Backend**: FastAPI on Railway — `https://web-production-32f5d.up.railway.app`
- **Database**: Neon Postgres
- **AI**: Claude (via backend) + Perplexity for news

---

## Before You Touch Anything

### Step 1 — Read the full project structure
```bash
find ~/forge/axis-ios/Axis -name "*.swift" | sort
cat ~/forge/axis-ios/Axis/Services/APIService.swift
cat ~/forge/axis-ios/Axis/App/AxisApp.swift
```

### Step 2 — Verify auth is wired correctly
Check that `APIService.swift` calls `Clerk.shared.session?.getToken()` and attaches it
as `Authorization: Bearer <token>` on every request. If not, fix this first before
touching any UI. Nothing works without auth.

### Step 3 — Verify backend is live
```bash
curl -s https://web-production-32f5d.up.railway.app/health
# Should return: {"status": "ok"}

curl -s -o /dev/null -w "%{http_code}" \
  https://web-production-32f5d.up.railway.app/brief/today
# Should return: 401 (protected, exists)
```

### Step 4 — Check asset colors exist
```bash
ls ~/forge/axis-ios/Axis/Assets.xcassets/
# Must include: AxisBackground.colorset, AxisCard.colorset, AccentColor.colorset
```

---

## Design System — Apply Everywhere, No Exceptions

### Colors
```swift
Color("AxisBackground")  // #0C0A15 — near-black, every screen background
Color("AxisCard")        // #110F1C — card/input backgrounds
Color.accentColor        // Purple — interactive elements, accents
Color.primary            // White — main text
Color.secondary          // Muted — supporting text
```

### Typography — Consistent Across All Screens
```swift
.font(.title2.bold())    // Screen titles, section headers
.font(.body)             // Primary content
.font(.body.bold())      // Emphasized content (signal titles, card titles)
.font(.caption.bold())   // Category labels (always uppercased)
.font(.caption)          // Timestamps, metadata, secondary info
```

### Every Screen Must Have
```swift
.background(Color("AxisBackground"))
.scrollContentBackground(.hidden)  // on Lists/ScrollViews
```

### Input Fields — Dark Theme Rules
```swift
TextEditor(text: $text)
    .foregroundStyle(.primary)         // text visible on dark background
    .tint(Color.accentColor)           // cursor color
    .background(Color("AxisCard"))
    .cornerRadius(12)

TextField("...", text: $text)
    .foregroundStyle(.primary)
    .tint(Color.accentColor)
```

### Keyboard Dismissal — Add to Every Screen
```swift
// Add this extension once in a shared Utilities file
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// On every ScrollView/background:
.onTapGesture { hideKeyboard() }
```

---

## Backend API Reference

Base URL: `https://web-production-32f5d.up.railway.app`
Auth: `Authorization: Bearer <clerk_jwt>` on every request

| Screen | Method | Endpoint | Payload | Response |
|--------|--------|----------|---------|----------|
| Brief | GET | `/brief/today` | — | `{messages, calendarEvents, gmailConnected, silentCount, generatedAt}` |
| Situation | GET | `/signal` | — | `[{id, title, body, urgency, category, createdAt}]` |
| Axis chat | GET | `/thread` | — | `[{id, sender, content, createdAt}]` |
| Axis chat | POST | `/thread` | `{message: string}` | `{id, sender, content, createdAt}` |
| Mind | POST | `/brain-dump` | `{content: string}` | `{id, response, tags}` |
| Gmail status | GET | `/gmail/status` | — | `{connected: bool}` |
| Gmail inbox | GET | `/gmail/inbox` | — | `{emails: [{subject, sender, date, snippet}]}` |
| Gmail connect | GET | `/auth/gmail?clerk_id=X&source=ios` | — | redirect → `axis://gmail-connected` |

---

## Screen-by-Screen Build Spec

### 1. Brief (Priority: Critical)

**Purpose:** Morning intelligence digest. User opens app and immediately knows what matters.

**Layout:**
```
"Good [morning/afternoon/evening]"  — dynamic greeting
Date subtitle

[Morning Summary cards — from /brief/today messages]
  Each card: category label (uppercased caption) + content (body)

[TODAY'S CALENDAR section — if events exist]
  Each event: accent color bar | title | time range | location

[Gmail status row]
  Connected: green envelope + "Inbox is being read"
  Disconnected: "Connect" tappable link → opens Gmail OAuth

"Put the phone down."  — sign-off, centered, tertiary color

[Silent count — if > 0]
  "Axis handled X items silently overnight."
```

**States:**
- Loading: pulsing sunrise icon + "Your brief is loading..." (animated opacity)
- Error: "Couldn't load brief" + "Pull to refresh"
- Empty (no brief yet): "Your brief appears each morning at 6:50 AM"

**Dark background:** `Color("AxisBackground")` — this was white before, fix it.

---

### 2. Situation (Signals)

**Purpose:** Axis surfaces things that need attention. Not a notification feed — a curated signal.

**Layout:**
- Each signal card: urgency indicator dot + title (body.bold) + body (body, secondary) + timestamp (caption)
- Urgency colors: `.red` for high, `.orange` for medium, `.secondary` for low
- Empty state: checkmark shield icon + "All Clear" + "No signals right now. Axis is watching."
- Pull to refresh

---

### 3. Axis (Chat / Thread)

**Purpose:** Direct line to Axis. Not a generic chatbot — Axis has context and responds with it.

**Layout:**
- Messages list, newest at bottom
- User messages: right-aligned, accent color bubble
- Axis messages: left-aligned, AxisCard bubble
- Input bar pinned to bottom: TextField + mic button + send button
- Send button: disabled when empty, spinner while sending
- User's message appears instantly (optimistic UI) before server responds

**Keyboard:** Rises with keyboard, dismisses on send or tap outside.

---

### 4. Mind (Brain Dump)

**Purpose:** Capture anything. Axis sorts it.

**Layout:**
- Title: "Brain Dump"
- Subtitle: "Get it out of your head. Axis will sort it." (caption, secondary)
- TextEditor: min height 120, AxisCard background, rounded, primary text color
- Buttons: "Voice" (mic icon) + "Note" (submit)
- Note button: disabled when empty, spinner while submitting
- After submit: show Axis's response/confirmation, clear input

**Keyboard:** Dismisses after submit and on tap outside.

---

## APIService.swift — Required Implementation

```swift
func request<T: Decodable>(
    _ path: String,
    method: String = "GET",
    body: [String: Any]? = nil
) async throws -> T {
    // 1. Get Clerk token — REQUIRED
    guard let token = try await Clerk.shared.session?.getToken() else {
        throw APIError.unauthorized
    }
    
    // 2. Build request
    var request = URLRequest(url: URL(string: baseURL + path)!)
    request.httpMethod = method
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let body = body {
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
    }
    
    // 3. Execute
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // 4. Debug (remove before App Store)
    print("[API] \(method) \(path) → \((response as? HTTPURLResponse)?.statusCode ?? 0)")
    
    // 5. Decode
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: data)
}
```

---

## Build Order

Do these in order. Do not skip ahead.

1. **APIService.swift** — verify token is attached, add debug logging, test with `/health`
2. **Global styles** — ViewExtensions.swift with `hideKeyboard()`, confirm asset colors exist
3. **Brief screen** — full build with dark background, loading state, data rendering
4. **Situation screen** — wire to `/signal`, real data or empty state
5. **Axis chat** — optimistic messages, keyboard handling, visible input
6. **Mind** — keyboard handling, visible input, submit confirmation

---

## Commit Rules

- One commit per screen, not one giant commit
- Message format: `feat(brief): wire /brief/today, add loading + error states`
- Do not commit if the build has errors
- Push after each screen — Railway auto-deploys backend, Xcode picks up iOS changes

---

## Definition of Done

Each screen is done when:
- [ ] Dark background renders correctly
- [ ] API call fires with Clerk token on load
- [ ] Real data renders when backend responds
- [ ] Empty state shows when no data
- [ ] Error state shows on network failure with pull-to-refresh
- [ ] Keyboard dismisses properly
- [ ] Text inputs are visible (light text on dark background)
- [ ] Loading state shows while fetching
- [ ] Fonts match the design system

The app is done when all 4 screens pass the above checklist and data flows
end-to-end from the backend to the UI.
