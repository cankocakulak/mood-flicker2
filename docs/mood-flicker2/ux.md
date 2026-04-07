# UX: MoodFlicker2

## User Goal

Capture my current mood in under 5 seconds and optionally review trends when I want deeper insight into my emotional patterns.

## Visual Direction

### Tone & Feel

Calm, unobtrusive, and trustworthy. The app should feel like a gentle companion rather than a demanding tracker. Visual design prioritizes:
- **Clarity**: Immediate understanding of what to do
- **Speed**: No waiting, no loading states
- **Warmth**: Soft colors, rounded shapes, human-friendly emoji
- **Privacy**: No login screens, no account creation, no cloud imagery

### Reference Apps

- **Stoic** — Clean journaling interface, calm color palette, unobtrusive daily prompts
- **Bear** — Simple, focused writing experience with beautiful typography
- **Apple Health** — Clear data visualization, native iOS feel, trustworthy presentation
- **Headspace** — Soft gradients, friendly illustrations, non-judgmental tone

### Color Direction

- **Primary**: Soft lavender `#9B8FD4` — calming, distinctive, gender-neutral
- **Accent**: Warm coral `#F4A698` — for CTAs and interactive highlights
- **Semantic**:
  - Mood 1 (😔): Soft blue-gray `#8FA8C8`
  - Mood 2 (😟): Muted teal `#7FB5B5`
  - Mood 3 (😐): Neutral sage `#A8B5A0`
  - Mood 4 (🙂): Warm yellow `#E8D494`
  - Mood 5 (😄): Soft coral `#F4C4A0`
- **Neutral**:
  - Background: Off-white `#FAFAF8`
  - Card: Pure white `#FFFFFF`
  - Text Primary: Charcoal `#2D2D2D`
  - Text Secondary: Warm gray `#8A8A8A`
  - Border: Light gray `#E8E8E6`

### Typography & Spacing

- **Font**: SF Pro (system default) for native iOS feel
- **Hierarchy**:
  - Large Title: 28pt, semibold (screen headers)
  - Title: 20pt, semibold (section headers)
  - Body: 17pt, regular (primary content)
  - Callout: 16pt, medium (button labels)
  - Caption: 13pt, regular (metadata, timestamps)
- **Spacing**: Generous padding (16-24pt) for breathable, calm feel
- **Density**: Low to medium — prioritize scannability over information density

## Primary Flows

### Flow 1: Widget Quick Check-In

- **User Goal**: Record my current mood as fast as possible without opening the app
- **Trigger**: User taps a mood emoji on the iOS home screen widget
- **Steps**:
  1. User views widget on home screen showing 5 emoji options
  2. User taps desired mood emoji
  3. Widget briefly shows checkmark/confirmation (0.5s)
  4. Widget updates to show "Last check-in: Just now"
  5. Entry saved to local database with timestamp
- **Edge Cases**:
  - **First use**: Widget shows setup hint "Add your first mood in the app"
  - **Multiple taps**: Each tap creates new entry (user can record multiple moods)
  - **Widget not responding**: Fallback to app-open flow
- **Success State**: Mood entry saved, widget updated, optional haptic feedback
- **PRD Requirement References**:
  - `PR-001`: Widget Quick Check-In
  - `PR-002`: Emoji Mood Scale
  - `PR-010`: Widget Refresh

### Flow 2: In-App Trend Review

- **User Goal**: Review my mood patterns and gain insights
- **Trigger**: User opens MoodFlicker2 app from home screen
- **Steps**:
  1. App opens to Today view showing today's entries (if any)
  2. User sees 7-day chart at top of screen
  3. User can scroll to see individual entries with timestamps
  4. User taps "Insights" tab to see pattern summary
  5. Insights show "Most common mood" and "Best day" (after 7+ entries)
- **Edge Cases**:
  - **No entries yet**: Empty state with friendly illustration and "Tap widget to add your first mood"
  - **Single entry**: Show entry but disable insights ("Check in for 6 more days to see trends")
  - **Many entries**: Scrollable list with date grouping
- **Success State**: User views trends and insights, understands their mood patterns
- **PRD Requirement References**:
  - `PR-004`: Daily Trend View
  - `PR-005`: 7-Day Trend Chart
  - `PR-006`: Basic Insights

### Flow 3: Data Export

- **User Goal**: Export my mood data for backup or sharing
- **Trigger**: User taps "Export" in app settings
- **Steps**:
  1. User navigates to Settings tab
  2. User taps "Export Data"
  3. System share sheet appears with CSV file
  4. User selects destination (Files, Mail, Messages, etc.)
  5. Export completes with success confirmation
- **Edge Cases**:
  - **No data to export**: Button disabled with "Add some moods first" hint
  - **Large dataset**: Export may take 1-2 seconds, show loading indicator
  - **Export fails**: Error message with retry option
- **Success State**: CSV file shared/saved successfully
- **PRD Requirement References**:
  - `PR-007`: CSV Export

### Flow 4: Optional Tag Addition (App)

- **User Goal**: Add context to my mood entry
- **Trigger**: User opens app after widget check-in OR taps "Add Tag" on entry
- **Steps**:
  1. User sees recent entry with "Add context" prompt
  2. User taps from 5 preset tags: Work, Sleep, Social, Health, Weather
  3. Tag attaches to entry immediately
  4. Visual confirmation shows tag with entry
- **Edge Cases**:
  - **No tag wanted**: User can dismiss/ignore, entry remains untagged
  - **Wrong tag selected**: User can tap to remove and select different tag
  - **Custom tags (P1)**: "+" button to create custom tag (if PR-102 implemented)
- **Success State**: Entry updated with context tag
- **PRD Requirement References**:
  - `PR-003`: Optional Context Tag

## Screen/Component Breakdown

### Screen 1: Widget (Home Screen)

- **Purpose**: Primary check-in interface, always visible
- **Layout**: Horizontal row of 5 emoji buttons
- **Key elements**:
  - 5 mood emoji buttons (😔 😟 😐 🙂 😄)
  - "Last check-in" timestamp below (if any)
  - App icon/brand hint
- **Primary action**: Tap emoji to record mood
- **Edge cases**:
  - Empty state: "Open MoodFlicker2 to start"
  - Just checked in: Brief checkmark overlay on tapped emoji
- **Flow References**:
  - Widget Quick Check-In
- **PRD Requirement References**:
  - `PR-001`, `PR-002`, `PR-010`

### Screen 2: Today View (App)

- **Purpose**: Show today's mood entries and quick stats
- **Layout**: 
  - Top: 7-day mini chart
  - Middle: Today's entries list (newest first)
  - Bottom: Tab bar navigation
- **Key elements**:
  - 7-day sparkline chart
  - Entry cards with time, emoji, optional tag
  - "Add Tag" button on entries without tags
  - Empty state illustration when no entries
- **Primary action**: Review entries, add context tags
- **Edge cases**:
  - Empty state: Friendly illustration + setup guidance
  - Many entries: Scrollable list
- **Flow References**:
  - In-App Trend Review
  - Optional Tag Addition
- **PRD Requirement References**:
  - `PR-004`, `PR-005`

### Screen 3: Insights View (App)

- **Purpose**: Show pattern analysis and meaningful insights
- **Layout**:
  - Top: Summary cards (Most Common Mood, Best Day)
  - Middle: 7-day detailed chart
  - Bottom: Tips/guidance
- **Key elements**:
  - Insight cards with emoji and stat
  - Full 7-day bar/line chart
  - "Keep checking in to see more insights" prompt (if < 7 entries)
- **Primary action**: Review insights, understand patterns
- **Edge cases**:
  - Not enough data: Encouraging message + progress indicator
  - No variation: "Your mood has been steady" message
- **Flow References**:
  - In-App Trend Review
- **PRD Requirement References**:
  - `PR-006`

### Screen 4: Settings View (App)

- **Purpose**: App configuration and data management
- **Layout**: Standard iOS settings list
- **Key elements**:
  - "Export Data" row with CSV label
  - "About" section with version
  - "Privacy" note (data stays on device)
  - Optional: Notification settings (P1)
  - Optional: iCloud sync toggle (P1)
- **Primary action**: Export data, configure app
- **Edge cases**:
  - No data: Export button disabled
- **Flow References**:
  - Data Export
- **PRD Requirement References**:
  - `PR-007`

## Interaction Patterns

- **Widget Taps**: Immediate haptic feedback (light impact), visual confirmation via brief checkmark overlay
- **App Navigation**: Standard iOS tab bar (Today, Insights, Settings)
- **Pull to Refresh**: Available on Today view to sync/check for updates
- **Entry Deletion**: Swipe left on entry, confirm with haptic
- **Tag Selection**: Tap to add, tap again to remove (toggle behavior)
- **Chart Interaction**: Tap data points to see exact value/time (if space permits)
- **Export**: Native iOS share sheet, no custom UI

## Copy Direction

### Button Labels
- "Export Data" (not "Download" or "Backup")
- "Add Context" (not "Tag" or "Categorize")

### Empty States
- "Your mood journal is waiting"
- "Add the MoodFlicker2 widget to your home screen for quick check-ins"

### Insights
- "Your most common mood: 🙂"
- "You tend to feel best on: Saturdays"
- "Check in for 3 more days to unlock insights"

### Confirmations
- "Mood saved" (brief toast, 1 second)
- "Export ready"

### Error States
- "Couldn't save — try again"
- "Export failed — check storage space"

## Accessibility

- **Dynamic Type**: Support all iOS text sizes, layout adapts
- **VoiceOver**: All emoji buttons labeled with mood description ("Sad", "Anxious", "Neutral", "Happy", "Great")
- **Color Independence**: Mood states distinguishable by emoji + position, not just color
- **Touch Targets**: Widget emoji buttons minimum 44x44pt (system handles this)
- **Reduce Motion**: Respect system setting for animations
- **High Contrast**: Test all color combinations for WCAG AA compliance

## Summary (for downstream agents)

```yaml
feature: "MoodFlicker2 - Lightweight iOS Mood Tracker"
source_artifacts:
  prd: "docs/mood-flicker2/prd.md"
  analysis: ""
primary_flows:
  - name: "Widget Quick Check-In"
    prd_requirements: ["PR-001", "PR-002", "PR-010"]
  - name: "In-App Trend Review"
    prd_requirements: ["PR-004", "PR-005", "PR-006"]
  - name: "Data Export"
    prd_requirements: ["PR-007"]
  - name: "Optional Tag Addition"
    prd_requirements: ["PR-003"]
screens:
  - name: "Widget"
    flows: ["Widget Quick Check-In"]
  - name: "Today View"
    flows: ["In-App Trend Review", "Optional Tag Addition"]
  - name: "Insights View"
    flows: ["In-App Trend Review"]
  - name: "Settings View"
    flows: ["Data Export"]
p0_requirements_covered:
  - "PR-001"
  - "PR-002"
  - "PR-003"
  - "PR-004"
  - "PR-005"
  - "PR-006"
  - "PR-007"
  - "PR-008"
  - "PR-009"
  - "PR-010"
key_risks:
  - "WidgetKit interactivity may have edge cases on some devices"
  - "User may need onboarding to discover widget setup"
  - "Color choices must work in both light and dark mode"
```

## Handoff Contract

**Next Agent:** `user-stories`

**Required Artifacts:**
- `docs/mood-flicker2/prd.md`
- `docs/mood-flicker2/ux.md`

**Recommended Artifacts:**
- None

**Critical Inputs:**
- User goal (capture mood in < 5 seconds)
- Primary flows (Widget Check-In, Trend Review, Export, Tag Addition)
- Screen breakdown (Widget, Today View, Insights View, Settings View)
- Interaction patterns (haptic feedback, tab navigation)
- Copy direction (friendly, non-clinical)
- Accessibility requirements

**Sections That Must Not Change:**
- User Goal
- Primary Flows
- Screen/Component Breakdown
- Interaction Patterns

**Mapping Rules:**
- Every primary flow must map to at least one story.
- Every screen/component referenced by a flow must appear in at least one story.
- Every P0 requirement referenced from the PRD must remain covered here.
