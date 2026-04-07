import Foundation
import SwiftData

/// Represents a single mood check-in entry
@Model
final class MoodEntry {
    /// Unique identifier for the entry
    @Attribute(.unique) var id: UUID
    
    /// Mood value from 1 (lowest) to 5 (highest)
    /// 1 = 😔 Very Low, 2 = 😟 Low, 3 = 😐 Neutral, 4 = 🙂 Good, 5 = 😄 Excellent
    var moodValue: Int
    
    /// Timestamp when the mood entry was created
    var timestamp: Date
    
    /// Optional context tag (e.g., "Work", "Sleep", "Social", "Health", "Weather")
    var tag: String?
    
    /// Computed property to get emoji representation of mood
    var moodEmoji: String {
        switch moodValue {
        case 1: return "😔"
        case 2: return "😟"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    /// Computed property to get descriptive text for the mood
    var moodDescription: String {
        switch moodValue {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Neutral"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Neutral"
        }
    }
    
    init(id: UUID = UUID(), moodValue: Int, timestamp: Date = Date(), tag: String? = nil) {
        self.id = id
        self.moodValue = moodValue
        self.timestamp = timestamp
        self.tag = tag
    }
}

// MARK: - Preset Tags

extension MoodEntry {
    /// Preset context tags available for mood entries
    static let presetTags: [String] = [
        "Work",
        "Sleep",
        "Social",
        "Health",
        "Weather"
    ]
}

// MARK: - Validation

extension MoodEntry {
    /// Validates that the mood value is within acceptable range (1-5)
    var isValidMoodValue: Bool {
        moodValue >= 1 && moodValue <= 5
    }
}
