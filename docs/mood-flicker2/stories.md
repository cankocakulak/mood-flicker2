# User Stories: MoodFlicker2

## Epic Summary

A lightweight iOS mood tracker with widget-first check-ins, trend visualization, and data export — capturing moods in under 5 seconds while providing meaningful insights over time.

## Stories

### P0 MF-001: Widget Quick Check-In

**As a** daily mood tracker user  
**I want** to record my mood with a single tap from my home screen widget  
**So that** I can capture how I feel in under 3 seconds without opening the app

**PRD Requirement References:** `PR-001`, `PR-002`, `PR-010`  
**UX Flow References:** Widget Quick Check-In  
**Dependencies:** None  
**Implementation Boundary:** Widget UI with 5 emoji buttons, App Intent handling, data persistence. Does NOT include in-app trend views or export functionality.

**Acceptance Criteria:**
- [ ] Given the MoodFlicker2 widget is on the home screen, when I view it, then I see 5 emoji buttons (😔 😟 😐 🙂 😄) arranged horizontally
- [ ] Given I tap a mood emoji on the widget, when the tap completes, then a mood entry is saved with the current timestamp and selected mood value (1-5)
- [ ] Given a mood entry is saved via widget, when the save completes, then the widget updates to show a brief checkmark confirmation (0.5s) and "Last check-in: Just now"
- [ ] Given the widget is displayed, when 5 minutes pass since last check-in, then the timestamp updates to show relative time (e.g., "5m ago")
- [ ] Given the widget is tapped, when the interaction occurs, then haptic feedback (light impact) is triggered

**Notes:** Requires iOS 17+ for interactive widgets. Widget refresh may have system-imposed rate limits.

---

### P0 MF-002: Local Data Storage

**As a** privacy-conscious user  
**I want** all my mood data stored locally on my device  
**So that** my personal emotional data never leaves my phone

**PRD Requirement References:** `PR-008`  
**UX Flow References:** All flows  
**Dependencies:** None  
**Implementation Boundary:** SwiftData model definition, CRUD operations, data persistence layer. Does NOT include iCloud sync (P1).

**Acceptance Criteria:**
- [ ] Given the app creates a mood entry, when saved, then it persists to local SwiftData storage immediately
- [ ] Given the app is force-quit and reopened, when it launches, then all previously saved entries are loaded correctly
- [ ] Given a mood entry exists, when queried by date range, then results return in chronological order
- [ ] Given the data model includes mood value (Int 1-5), timestamp (Date), and optional tag (String), when saved, then all fields persist correctly
- [ ] Given the device has no internet connection, when I use the app, then all functionality works normally (no network dependency)

**Notes:** Data model should be designed to support future iCloud sync without migration.

---

### P0 MF-003: Today View

**As a** mood tracker user  
**I want** to see today's mood entries when I open the app  
**So that** I can review how my day has been going

**PRD Requirement References:** `PR-004`  
**UX Flow References:** In-App Trend Review  
**Dependencies:** MF-002 (Local Data Storage)  
**Implementation Boundary:** Today tab UI, entry list display, empty state. Does NOT include charts (MF-005) or insights (MF-006).

**Acceptance Criteria:**
- [ ] Given I open the MoodFlicker2 app, when the Today view loads, then I see a list of today's mood entries sorted by time (newest first)
- [ ] Given an entry exists, when displayed, then it shows the emoji, exact time (e.g., "2:30 PM"), and optional tag if present
- [ ] Given no entries exist for today, when the view loads, then I see a friendly empty state with illustration and "Add the MoodFlicker2 widget to your home screen" guidance
- [ ] Given I pull down on the list, when the gesture completes, then the view refreshes to show any new entries
- [ ] Given I swipe left on an entry, when the delete action appears and I confirm, then the entry is removed from storage and the list updates

**Notes:** Empty state illustration should be simple, calm, and on-brand.

---

### P0 MF-004: Optional Context Tags

**As a** mood tracker user  
**I want** to add context tags to my mood entries  
**So that** I can understand what situations affect my mood

**PRD Requirement References:** `PR-003`  
**UX Flow References:** Optional Tag Addition  
**Dependencies:** MF-002 (Local Data Storage), MF-003 (Today View)  
**Implementation Boundary:** Tag selection UI, tag persistence, tag display. Does NOT include custom tags (P1) or tag-based insights (P2).

**Acceptance Criteria:**
- [ ] Given I view an entry without a tag in the Today view, when I look at it, then I see an "Add Context" button
- [ ] Given I tap "Add Context", when the tag selector appears, then I see 5 preset options: Work, Sleep, Social, Health, Weather
- [ ] Given I select a tag, when confirmed, then the tag attaches to the entry and displays with the entry immediately
- [ ] Given an entry has a tag, when I tap the tag, then it removes the tag (toggle behavior)
- [ ] Given a widget check-in creates a new entry, when I open the app within 5 minutes, then I see a prompt to add context to that recent entry

**Notes:** Tag selector should use subtle pill buttons, not full-screen modal.

---

### P0 MF-005: 7-Day Trend Chart

**As a** mood tracker user  
**I want** to see a chart of my mood patterns over the last 7 days  
**So that** I can visualize my emotional trends

**PRD Requirement References:** `PR-005`  
**UX Flow References:** In-App Trend Review  
**Dependencies:** MF-002 (Local Data Storage)  
**Implementation Boundary:** Chart visualization using Swift Charts, 7-day data aggregation. Does NOT include insights text (MF-006) or monthly view (P1).

**Acceptance Criteria:**
- [ ] Given I view the Today or Insights tab, when the screen loads, then I see a 7-day chart showing mood values over time
- [ ] Given the chart displays, when I examine it, then each day shows the average mood value for that day (or individual entries if multiple per day)
- [ ] Given I have fewer than 7 days of data, when the chart displays, then it shows available days with clear indication of the date range
- [ ] Given I tap a data point on the chart, when selected, then I see the exact date and average mood value
- [ ] Given the chart renders, when viewed, then it uses the mood color scheme (blue-gray to coral gradient) for visual consistency

**Notes:** Use Swift Charts (iOS 16+) for native look and feel. Chart should be readable at glance.

---

### P0 MF-006: Basic Insights

**As a** mood tracker user  
**I want** to see simple insights about my mood patterns  
**So that** I can understand my emotional trends without analyzing raw data

**PRD Requirement References:** `PR-006`  
**UX Flow References:** In-App Trend Review  
**Dependencies:** MF-002 (Local Data Storage), MF-005 (7-Day Trend Chart)  
**Implementation Boundary:** Insights calculation, insights cards UI. Does NOT include correlation insights (P2) or advanced analytics.

**Acceptance Criteria:**
- [ ] Given I have 7 or more entries, when I view the Insights tab, then I see a "Most Common Mood" card showing the emoji and percentage
- [ ] Given I have 7 or more entries across multiple days, when I view Insights, then I see a "Best Day" card showing which day of week has highest average mood
- [ ] Given I have fewer than 7 entries, when I view Insights, then I see an encouraging message: "Check in for X more days to unlock insights" with progress indicator
- [ ] Given insights are displayed, when the data updates (new entry added), then insights recalculate automatically
- [ ] Given I view insights, when displayed, then the copy is friendly and non-clinical (e.g., "You've been feeling 🙂 most often")

**Notes:** Insights should update in real-time as new entries are added. Keep calculations simple and fast.

---

### P0 MF-007: CSV Export

**As a** mood tracker user  
**I want** to export my mood data to CSV format  
**So that** I can back up my data or share it with my therapist

**PRD Requirement References:** `PR-007`  
**UX Flow References:** Data Export  
**Dependencies:** MF-002 (Local Data Storage)  
**Implementation Boundary:** CSV generation, share sheet presentation, export functionality. Does NOT include PDF export (P1).

**Acceptance Criteria:**
- [ ] Given I navigate to Settings, when I view the export section, then I see an "Export Data" button
- [ ] Given I have no mood entries, when I view Settings, then the "Export Data" button is disabled with "Add some moods first" hint
- [ ] Given I tap "Export Data" with entries present, when the export prepares, then the app generates a CSV file with columns: Date, Time, Mood (1-5), Mood Emoji, Tag
- [ ] Given the CSV is generated, when ready, then the iOS share sheet appears with the file named "MoodFlicker_Export_YYYY-MM-DD.csv"
- [ ] Given I share the file, when the operation completes, then I see a brief "Export ready" confirmation

**Notes:** CSV should use UTF-8 encoding, comma delimiter, and include header row. Handle large datasets (1000+ entries) without memory issues.

---

### P0 MF-008: iOS 17+ Platform Support

**As an** iOS user  
**I want** the app to work seamlessly on iOS 17 and later  
**So that** I can use modern iOS features like interactive widgets

**PRD Requirement References:** `PR-009`  
**UX Flow References:** All flows  
**Dependencies:** None  
**Implementation Boundary:** Project configuration, deployment target, iOS 17 API usage. Does NOT include backward compatibility with iOS 16.

**Acceptance Criteria:**
- [ ] Given the app project, when configured, then the deployment target is set to iOS 17.0
- [ ] Given the app runs on iOS 17+, when using widgets, then interactive widget features (App Intents) work correctly
- [ ] Given the app uses SwiftData, when running, then it uses modern SwiftData APIs available in iOS 17+
- [ ] Given the app is submitted to App Store, when reviewed, then it meets all iOS 17+ requirements

**Notes:** This is a foundational story that affects all other stories. Must be completed first.

---

### P1 MF-101: PDF Export

**As a** mood tracker user  
**I want** to export a monthly PDF report with charts  
**So that** I can have a visual summary of my mood trends

**PRD Requirement References:** `PR-101`  
**UX Flow References:** Data Export  
**Dependencies:** MF-007 (CSV Export)  
**Implementation Boundary:** PDF generation with charts, monthly aggregation. Does NOT include custom date ranges.

**Acceptance Criteria:**
- [ ] Given I navigate to Settings, when I view export options, then I see "Export as PDF" alongside CSV option
- [ ] Given I tap "Export as PDF", when generated, then the PDF includes: monthly calendar view, trend chart, summary statistics, and entry list
- [ ] Given the PDF is generated, when viewed, then it uses the app's color scheme and is formatted for printing/sharing
- [ ] Given I have data spanning multiple months, when exporting PDF, then I can select which month to export

---

### P1 MF-102: Custom Tags

**As a** mood tracker user  
**I want** to create my own custom tags  
**So that** I can track contexts specific to my life

**PRD Requirement References:** `PR-102`  
**UX Flow References:** Optional Tag Addition  
**Dependencies:** MF-004 (Optional Context Tags)  
**Implementation Boundary:** Custom tag creation, storage, selection UI.

**Acceptance Criteria:**
- [ ] Given I tap "Add Context" on an entry, when the tag selector appears, then I see a "+" button to create custom tag
- [ ] Given I tap "+", when the creation dialog appears, then I can enter a custom tag name (max 20 chars)
- [ ] Given I create a custom tag, when saved, then it appears in my tag list for future use
- [ ] Given I have custom tags, when viewing tag selector, then preset tags and custom tags are visually distinct

---

### P1 MF-103: iCloud Sync

**As a** user with multiple Apple devices  
**I want** my mood data to sync via iCloud  
**So that** I can access my entries on all my devices

**PRD Requirement References:** `PR-103`  
**UX Flow References:** All flows  
**Dependencies:** MF-002 (Local Data Storage)  
**Implementation Boundary:** SwiftData iCloud sync configuration, conflict resolution.

**Acceptance Criteria:**
- [ ] Given I enable iCloud sync in Settings, when enabled, then my data syncs to iCloud
- [ ] Given I install the app on a second device, when signed in with same Apple ID, then my mood data appears
- [ ] Given I add an entry on one device, when sync completes, then it appears on my other devices within minutes
- [ ] Given sync conflicts occur, when resolved, then most recent entry wins (last-write-wins)

---

### P1 MF-104: Notification Reminders

**As a** mood tracker user  
**I want** optional daily reminders to check in  
**So that** I can build a consistent tracking habit

**PRD Requirement References:** `PR-104`  
**UX Flow References:** N/A  
**Dependencies:** None  
**Implementation Boundary:** Local notification scheduling, settings UI.

**Acceptance Criteria:**
- [ ] Given I navigate to Settings, when I view notifications, then I see a toggle for "Daily Reminder"
- [ ] Given I enable reminders, when configured, then I can select a time for the daily notification
- [ ] Given the reminder time arrives, when triggered, then I receive a gentle notification: "How are you feeling?"
- [ ] Given I tap the notification, when opened, then the app launches to the Today view

---

### P1 MF-105: Monthly Trend View

**As a** long-term mood tracker user  
**I want** to see trends over the past 30 days  
**So that** I can identify longer-term patterns

**PRD Requirement References:** `PR-105`  
**UX Flow References:** In-App Trend Review  
**Dependencies:** MF-005 (7-Day Trend Chart)  
**Implementation Boundary:** Extended chart view, 30-day data aggregation.

**Acceptance Criteria:**
- [ ] Given I view the Insights tab, when I look at chart options, then I can toggle between 7-day and 30-day views
- [ ] Given I select 30-day view, when displayed, then the chart shows daily averages over the past month
- [ ] Given I have fewer than 30 days of data, when viewing 30-day chart, then it shows available data with clear date range

---

## Coverage Map

### PRD Requirement Coverage

| PRD Requirement | Covered By Stories |
|-----------------|-------------------|
| PR-001: Widget Quick Check-In | MF-001 |
| PR-002: Emoji Mood Scale | MF-001 |
| PR-003: Optional Context Tag | MF-004 |
| PR-004: Daily Trend View | MF-003 |
| PR-005: 7-Day Trend Chart | MF-005 |
| PR-006: Basic Insights | MF-006 |
| PR-007: CSV Export | MF-007 |
| PR-008: Local Data Storage | MF-002 |
| PR-009: iOS 17+ Support | MF-008 |
| PR-010: Widget Refresh | MF-001 |
| PR-101: PDF Export | MF-101 |
| PR-102: Custom Tags | MF-102 |
| PR-103: iCloud Sync | MF-103 |
| PR-104: Notification Reminders | MF-104 |
| PR-105: Monthly Trend View | MF-105 |

### UX Flow Coverage

| UX Flow | Covered By Stories |
|---------|-------------------|
| Widget Quick Check-In | MF-001 |
| In-App Trend Review | MF-003, MF-005, MF-006 |
| Data Export | MF-007, MF-101 |
| Optional Tag Addition | MF-004, MF-102 |

## Summary (for downstream agents)

```yaml
feature: "MoodFlicker2 - Lightweight iOS Mood Tracker"
source_artifacts:
  prd: "docs/mood-flicker2/prd.md"
  ux: "docs/mood-flicker2/ux.md"
story_ids:
  p0: ["MF-001", "MF-002", "MF-003", "MF-004", "MF-005", "MF-006", "MF-007", "MF-008"]
  p1: ["MF-101", "MF-102", "MF-103", "MF-104", "MF-105"]
coverage:
  prd_requirements:
    PR-001: ["MF-001"]
    PR-002: ["MF-001"]
    PR-003: ["MF-004"]
    PR-004: ["MF-003"]
    PR-005: ["MF-005"]
    PR-006: ["MF-006"]
    PR-007: ["MF-007"]
    PR-008: ["MF-002"]
    PR-009: ["MF-008"]
    PR-010: ["MF-001"]
  ux_flows:
    "Widget Quick Check-In": ["MF-001"]
    "In-App Trend Review": ["MF-003", "MF-005", "MF-006"]
    "Data Export": ["MF-007"]
    "Optional Tag Addition": ["MF-004"]
dependencies:
  MF-001: ["MF-002", "MF-008"]
  MF-002: []
  MF-003: ["MF-002"]
  MF-004: ["MF-002", "MF-003"]
  MF-005: ["MF-002"]
  MF-006: ["MF-002", "MF-005"]
  MF-007: ["MF-002"]
  MF-008: []
implementation_risks:
  - "MF-001 (Widget) may hit WidgetKit interactivity edge cases"
  - "MF-006 (Insights) requires careful handling of sparse data"
  - "MF-007 (Export) must handle large datasets efficiently"
  - "Story ordering is important — MF-008 and MF-002 should be first"
```

## Handoff Contract

**Next Agent:** `task-planner`

**Required Artifacts:**
- `docs/mood-flicker2/stories.md`
- `docs/mood-flicker2/prd.md`

**Recommended Artifacts:**
- `docs/mood-flicker2/ux.md`

**Critical Inputs:**
- Story ordering (MF-008 and MF-002 first, then MF-001, etc.)
- Story IDs (MF-001 through MF-008 for P0)
- Acceptance criteria (Given/When/Then format)
- Dependencies (explicitly mapped)
- Implementation boundaries (scope limits)
- Coverage map (PRD and UX flow coverage)

**Sections That Must Not Change:**
- Story IDs
- Acceptance criteria intent
- Dependencies
- Implementation Boundary

**Mapping Rules:**
- Every P0 requirement must map to at least one story.
- Every primary UX flow must map to at least one story.
- Every story must be independently implementable or explicitly flagged for splitting.
