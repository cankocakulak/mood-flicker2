# PRD: MoodFlicker2

## Problem

People want to track their mood for self-awareness and mental health insights, but existing mood trackers require too much time and effort. The friction of opening an app, navigating menus, and answering multiple questions leads to abandonment. Users need a way to capture their mood in 2-5 seconds that still provides meaningful trends over time.

## Solution

MoodFlicker2 is a lightweight iOS mood tracker built around iOS home screen widgets. Users check in via a single-tap emoji selector on the widget (2-3 seconds), with the full app available for viewing trends, insights, and exporting data. The experience is calm, fast, and privacy-first — no accounts, no servers, no data mining.

## Requirements

### Must Have (P0)

- [ ] `PR-001` **Widget Quick Check-In**: iOS home screen widget allowing single-tap mood selection via 5 emoji options
- [ ] `PR-002` **Emoji Mood Scale**: 5 carefully selected emoji representing mood spectrum (😔 → 😟 → 😐 → 🙂 → 😄)
- [ ] `PR-003` **Optional Context Tag**: After mood selection, user can add optional 1-word tag (work, sleep, social, health, weather)
- [ ] `PR-004` **Daily Trend View**: In-app view showing mood entries for the current day with timestamps
- [ ] `PR-005` **7-Day Trend Chart**: Simple line/bar chart showing mood patterns over the last 7 days
- [ ] `PR-006` **Basic Insights**: Pattern detection showing "most common mood" and "best day of week" after 7+ entries
- [ ] `PR-007` **CSV Export**: Export all mood data to CSV format with date, mood value, and optional tags
- [ ] `PR-008` **Local Data Storage**: All data stored locally using SwiftData, no cloud dependency
- [ ] `PR-009` **iOS 17+ Support**: App requires iOS 17+ for full WidgetKit functionality
- [ ] `PR-010` **Widget Refresh**: Widget updates immediately after check-in and refreshes at set intervals

### Should Have (P1)

- [ ] `PR-101` **PDF Export**: Monthly PDF report with trend charts and summary statistics
- [ ] `PR-102` **Custom Tags**: User can create custom tags beyond the 5 preset options
- [ ] `PR-103` **iCloud Sync**: Optional iCloud sync via SwiftData for device backup
- [ ] `PR-104` **Notification Reminders**: Optional gentle daily reminder (user-configurable time)
- [ ] `PR-105` **Monthly Trend View**: Extended chart view showing 30-day patterns

### Nice to Have (P2)

- [ ] `PR-201` **Mood Notes**: Optional short text note (max 140 chars) with mood entry
- [ ] `PR-202` **Correlation Insights**: "You tend to feel better after exercise" type insights with tag correlation
- [ ] `PR-203` **Multiple Widget Sizes**: Support for small, medium, and large widget variants
- [ ] `PR-204` **App Icon Themes**: Alternative app icon options matching mood colors

## Tech Stack

| Layer | Choice | Reasoning |
|-------|--------|-----------|
| Platform | iOS 17+ | WidgetKit interactivity requires iOS 17+ |
| Language | Swift | Native iOS development |
| UI Framework | SwiftUI | Modern declarative UI, WidgetKit integration |
| Data Persistence | SwiftData | Native iOS persistence, iCloud sync support |
| Widgets | WidgetKit + App Intents | Interactive widgets for quick check-in |
| Charts | Swift Charts | Native charting, integrates with SwiftUI |
| Export | PDFKit + CSV | Standard iOS frameworks for data export |

## Out of Scope

- Android support
- User accounts / authentication
- Backend server / API
- Social features (sharing moods, friend connections)
- Advanced analytics / ML insights
- Medication tracking
- Integration with HealthKit (v1)
- Dark mode toggle (follows system)
- Custom emoji/sticker selection
- Voice input
- Photo attachments

## Success Criteria

- User can complete a mood check-in in under 5 seconds from widget
- 7-day retention rate > 50% (users who check in at least once per week)
- Zero crash rate on widget interactions
- App Store rating > 4.5 stars
- Export functionality works with 1000+ entries without memory issues

## Open Questions

1. Should we show a confirmation after widget check-in, or is the visual feedback enough?
2. What time range should the widget display for "last check-in" indicator?
3. Should we implement haptic feedback on widget interactions?
4. How should we handle timezone changes for users who travel?

## Summary (for downstream agents)

```yaml
feature: "MoodFlicker2 - Lightweight iOS Mood Tracker"
source_artifacts:
  analysis: ""
  brainstorm: "docs/mood-flicker2/brainstorm.md"
primary_user_problem: "Mood tracking is too time-consuming and leads to abandonment"
solution_shape: "Widget-first emoji-based mood tracking with 2-5 second check-ins"
p0_requirements:
  - id: "PR-001"
    summary: "Widget Quick Check-In via single-tap emoji"
  - id: "PR-002"
    summary: "5-emoji mood scale"
  - id: "PR-003"
    summary: "Optional 1-word context tag"
  - id: "PR-004"
    summary: "Daily trend view in app"
  - id: "PR-005"
    summary: "7-day trend chart"
  - id: "PR-006"
    summary: "Basic insights after 7+ entries"
  - id: "PR-007"
    summary: "CSV export functionality"
  - id: "PR-008"
    summary: "Local SwiftData storage"
  - id: "PR-009"
    summary: "iOS 17+ support"
  - id: "PR-010"
    summary: "Widget refresh after check-in"
p1_requirements:
  - id: "PR-101"
    summary: "PDF export"
  - id: "PR-102"
    summary: "Custom tags"
  - id: "PR-103"
    summary: "iCloud sync"
  - id: "PR-104"
    summary: "Notification reminders"
  - id: "PR-105"
    summary: "Monthly trend view"
primary_flows_expected:
  - "Widget Quick Check-In"
  - "In-App Trend Review"
  - "Data Export"
key_risks:
  - "WidgetKit interactivity limitations on older iOS versions"
  - "User may not discover widget setup without onboarding"
  - "Limited trend insights with sparse data"
open_questions:
  - "Widget check-in confirmation UX"
  - "Timezone handling for travelers"
  - "Haptic feedback implementation"
```

## Handoff Contract

**Next Agent:** `ux-designer`

**Required Artifacts:**
- `docs/mood-flicker2/prd.md`

**Recommended Artifacts:**
- `docs/mood-flicker2/brainstorm.md`

**Critical Inputs:**
- 2-5 second check-in target
- Widget-first architecture
- Emoji-based mood selection (5 options)
- Privacy-first, no backend
- iOS 17+ requirement

**Sections That Must Not Change:**
- Problem statement
- Solution shape
- P0 requirements (PR-001 through PR-010)
- Out of Scope list

**Mapping Rules:**
- Every P0 requirement must map to at least one UX flow or user story.
- Primary flows expected: Widget Quick Check-In, In-App Trend Review, Data Export
- Open questions must stay visible until resolved by a downstream artifact.
