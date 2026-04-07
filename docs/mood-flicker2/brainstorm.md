# Brainstorm: MoodFlicker2

## Analysis

The real problem isn't just tracking mood — it's **removing friction from the act of recording how you feel**. Most mood trackers fail because they ask too much: long surveys, daily notifications that feel like chores, and complex interfaces. Users need a 2-5 second interaction that captures enough signal to be useful without becoming a burden.

## Ideas

### Idea 1: Emoji-First Quick Check-In
**What**: Single-tap mood selection using 5 carefully chosen emoji faces, optional 1-word tag
**Why it works**: Universally understood, no reading required, taps into emotional recognition faster than words
**Risk**: May feel too simplistic for users wanting deeper reflection
**Effort**: Low

### Idea 2: Slider + Color Gradient Mood Picker
**What**: Horizontal slider that transitions through a color gradient (blue → green → yellow → orange → red) representing mood spectrum
**Why it works**: More nuanced than emoji, visual feedback is satisfying, captures subtle mood variations
**Risk**: Slightly longer interaction time (3-5 seconds vs 2-3)
**Effort**: Low

### Idea 3: Widget-First Architecture
**What**: iOS home screen widget as primary interface — check-in without opening app
**Why it works**: Reduces friction to absolute minimum, glanceable trends, native iOS feel
**Risk**: WidgetKit limitations on interactivity, requires iOS 17+ for best experience
**Effort**: Medium

### Idea 4: Pattern-Based Trend Detection
**What**: Simple time-based insights — "You tend to feel better on weekends", "Mood drops on Monday mornings"
**Why it works**: Users want meaning from data, not just raw numbers; creates habit loop
**Risk**: Requires minimum data points before showing insights (7+ days)
**Effort**: Medium

### Idea 5: Export to PDF/CSV
**What**: Monthly PDF report with trends + raw CSV export for power users
**Why it works**: Appeals to quantified-self users, enables sharing with therapists/coaches
**Risk**: PDF generation complexity, privacy concerns with exported files
**Effort**: Medium

### Idea 6: Streak Gamification
**What**: Gentle streak counter, not aggressive — "7 days of check-ins" not "Don't break your streak!"
**Why it works**: Positive reinforcement without guilt; optional, doesn't punish missed days
**Risk**: Can still feel pressure-inducing for some users
**Effort**: Low

### Idea 7: Contextual Quick-Add (Time-Based Suggestions)
**What**: Pre-suggest common contexts based on time — morning coffee, work break, evening wind-down
**Why it works**: Reduces cognitive load, captures situational context that explains mood patterns
**Risk**: May feel intrusive if suggestions are wrong
**Effort**: Medium

## Tech Direction

**Recommended Stack:**
- **Platform**: iOS 17+ (SwiftUI + WidgetKit)
- **Data**: SwiftData for local-first storage
- **Export**: PDFKit + CSV generation
- **Charts**: Swift Charts for trend visualization

**Key Technical Bets:**
1. **WidgetKit as primary interface** — Bet that users prefer widget check-ins over app-open
2. **SwiftData for sync** — Local-first with eventual iCloud sync via SwiftData
3. **No backend** — Privacy-first, no account required, no server costs

## Recommendation

**Go with Idea 1 + Idea 3 + Idea 4 + Idea 5.**

The core experience: Emoji-first quick check-in (2-3 seconds) accessible via widget. This is the minimum viable product that delivers on the "frictionless" promise. Add trend detection after 7 days of data, and export functionality for users who want their data. Skip streak gamification initially — it adds pressure that conflicts with the "sakin" brand feel. Contextual quick-add can come in v2 if the core loop proves sticky.

## Combinations

The winning combination creates a **"capture first, reflect later"** system:
- Widget enables 2-second capture anywhere
- App provides trends and insights when user wants deeper reflection
- Export gives users ownership of their data

## Summary (for downstream agents)

```yaml
feature: "MoodFlicker2 - Lightweight iOS Mood Tracker"
selected_direction: "Emoji-first widget-based mood tracking with trends and export"
rejected_directions:
  - "Slider + color gradient (slightly slower, less intuitive)"
  - "Streak gamification (conflicts with 'sakin' brand)"
  - "Contextual quick-add (v2 feature, not core loop)"
constraints:
  - "iOS 17+ only (WidgetKit limitations)"
  - "2-5 second check-in target"
  - "No backend, local-first storage"
  - "Privacy-first, no account required"
technical_bets:
  - "WidgetKit as primary interface"
  - "SwiftData with iCloud sync"
  - "Swift Charts for trend visualization"
open_questions:
  - "Which 5 emoji best represent the mood spectrum?"
  - "What trend insights are most valuable with limited data?"
  - "PDF export format design"
```

## Handoff Contract

**Next Agent:** `prd`

**Required Artifacts:**
- `docs/mood-flicker2/brainstorm.md`

**Recommended Artifacts:**
- None (no analysis artifact provided)

**Critical Inputs that must remain stable:**
- 2-5 second check-in target
- Widget-first architecture
- Emoji-based mood selection
- No backend / privacy-first approach
- iOS 17+ target

**Sections That Must Not Change before PRD:**
- Selected direction (emoji-first widget-based tracking)
- Core constraints (speed, privacy, iOS-only)
- Technical bets (WidgetKit, SwiftData, no backend)
