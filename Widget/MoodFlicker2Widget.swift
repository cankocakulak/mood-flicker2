import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct MoodEntryTimelineEntry: TimelineEntry {
    let date: Date
    let lastMoodEntry: MoodEntry?
    let showingConfirmation: Bool
    let confirmationMoodValue: Int?
    
    init(date: Date, lastMoodEntry: MoodEntry?, showingConfirmation: Bool = false, confirmationMoodValue: Int? = nil) {
        self.date = date
        self.lastMoodEntry = lastMoodEntry
        self.showingConfirmation = showingConfirmation
        self.confirmationMoodValue = confirmationMoodValue
    }
    
    var lastCheckInText: String {
        guard let entry = lastMoodEntry else {
            return "No check-ins yet"
        }
        return "Last check-in: \(entry.timestamp.relativeTimeDisplay())"
    }
}

// MARK: - Timeline Provider

struct MoodFlicker2WidgetProvider: AppIntentTimelineProvider {
    typealias Entry = MoodEntryTimelineEntry
    typealias Intent = ConfigurationAppIntent
    
    func placeholder(in context: Context) -> MoodEntryTimelineEntry {
        MoodEntryTimelineEntry(date: Date(), lastMoodEntry: nil)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MoodEntryTimelineEntry {
        let entry = await fetchMostRecentEntry()
        return MoodEntryTimelineEntry(date: Date(), lastMoodEntry: entry)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MoodEntryTimelineEntry> {
        let entry = await fetchMostRecentEntry()
        
        // Check if we should show confirmation state
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        let showingConfirmation = defaults?.bool(forKey: "widgetShowingConfirmation") ?? false
        let confirmationMoodValue = defaults?.integer(forKey: "widgetConfirmationMoodValue")
        let confirmationTimestamp = defaults?.object(forKey: "widgetConfirmationTimestamp") as? Date
        
        let timelineEntry: MoodEntryTimelineEntry
        
        if showingConfirmation,
           let timestamp = confirmationTimestamp,
           Date().timeIntervalSince(timestamp) < 0.5 {
            // Show confirmation state
            timelineEntry = MoodEntryTimelineEntry(
                date: Date(),
                lastMoodEntry: entry,
                showingConfirmation: true,
                confirmationMoodValue: confirmationMoodValue > 0 ? confirmationMoodValue : nil
            )
            
            // Schedule next update to clear confirmation after 0.5s
            let nextUpdate = Calendar.current.date(byAdding: .millisecond, value: 500, to: timestamp)!
            return Timeline(entries: [timelineEntry], policy: .after(nextUpdate))
        } else {
            // Normal state - clear confirmation flags
            defaults?.removeObject(forKey: "widgetShowingConfirmation")
            defaults?.removeObject(forKey: "widgetConfirmationMoodValue")
            defaults?.removeObject(forKey: "widgetConfirmationTimestamp")
            
            timelineEntry = MoodEntryTimelineEntry(date: Date(), lastMoodEntry: entry)
            
            // Refresh every 15 minutes to update relative time display
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            return Timeline(entries: [timelineEntry], policy: .after(nextUpdate))
        }
    }
    
    private func fetchMostRecentEntry() async -> MoodEntry? {
        do {
            let repository = try MoodRepository()
            return try await repository.fetchMostRecent()
        } catch {
            return nil
        }
    }
}

// MARK: - Configuration Intent

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "MoodFlicker2 Configuration"
    static var description = IntentDescription("Configure the MoodFlicker2 widget")
}

// MARK: - Widget View

struct MoodFlicker2WidgetEntryView: View {
    var entry: MoodEntryTimelineEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(spacing: 12) {
            if entry.showingConfirmation {
                // Confirmation state
                ConfirmationView(moodValue: entry.confirmationMoodValue)
            } else {
                // Normal state
                // Title
                Text("How are you feeling?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Emoji buttons row
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { moodValue in
                        MoodEmojiButton(moodValue: moodValue)
                    }
                }
                
                // Last check-in info
                Text(entry.lastCheckInText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Mood Emoji Button

struct MoodEmojiButton: View {
    let moodValue: Int
    
    var emoji: String {
        switch moodValue {
        case 1: return "😔"
        case 2: return "😟"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    var body: some View {
        Button(intent: LogMoodIntent(moodValue: moodValue)) {
            Text(emoji)
                .font(.system(size: 24))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(.fill.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Confirmation View

struct ConfirmationView: View {
    let moodValue: Int?
    
    var emoji: String {
        guard let value = moodValue else { return "✓" }
        switch value {
        case 1: return "😔"
        case 2: return "😟"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "✓"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Large checkmark with emoji
            ZStack {
                Circle()
                    .fill(.green.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(emoji)
                    .font(.system(size: 32))
            }
            
            // Confirmation text
            VStack(spacing: 4) {
                Text("Logged!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Mood saved successfully")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Configuration

struct MoodFlicker2Widget: Widget {
    let kind: String = "MoodFlicker2Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: MoodFlicker2WidgetProvider()
        ) { entry in
            MoodFlicker2WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MoodFlicker2")
        .description("Quick mood check-in from your home screen")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Date Extension for Relative Time

extension Date {
    func relativeTimeDisplay() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.minute, .hour, .day],
            from: self,
            to: now
        )
        
        if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days)d ago"
        }
        
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }
        
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }
        
        return "Just now"
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    MoodFlicker2Widget()
} timeline: {
    MoodEntryTimelineEntry(date: .now, lastMoodEntry: nil)
    MoodEntryTimelineEntry(
        date: .now,
        lastMoodEntry: MoodEntry(moodValue: 4, timestamp: Date().addingTimeInterval(-300))
    )
}
