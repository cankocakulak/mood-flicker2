import AppIntents
import SwiftData
import WidgetKit

// MARK: - Log Mood Intent

struct LogMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Mood"
    static var description = IntentDescription("Log a mood check-in from the widget")
    
    @Parameter(title: "Mood Value", description: "The mood value from 1-5")
    var moodValue: Int
    
    init() {}
    
    init(moodValue: Int) {
        self.moodValue = moodValue
    }
    
    func perform() async throws -> some IntentResult {
        // Validate mood value
        guard moodValue >= 1 && moodValue <= 5 else {
            throw IntentError.invalidMoodValue
        }
        
        // Set confirmation state before saving
        setConfirmationState(moodValue: moodValue)
        
        // Request widget refresh to show confirmation
        WidgetCenter.shared.reloadTimelines(ofKind: "MoodFlicker2Widget")
        
        // Create and save the mood entry
        let entry = MoodEntry(moodValue: moodValue, timestamp: Date())
        
        do {
            let repository = try MoodRepository()
            try await repository.save(entry)
            
            // Save timestamp for "add context" prompt
            saveWidgetCheckInTimestamp()
            
            // Trigger haptic feedback via notification
            await MainActor.run {
                HapticFeedbackHelper.triggerSuccess()
            }
            
            // Schedule another refresh to clear confirmation after 0.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WidgetCenter.shared.reloadTimelines(ofKind: "MoodFlicker2Widget")
            }
            
            return .result(
                value: true,
                dialog: IntentDialog(stringLiteral: "Mood logged successfully!")
            )
        } catch {
            // Clear confirmation state on error
            clearConfirmationState()
            WidgetCenter.shared.reloadTimelines(ofKind: "MoodFlicker2Widget")
            throw IntentError.saveFailed(error.localizedDescription)
        }
    }
    
    private func setConfirmationState(moodValue: Int) {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        defaults?.set(true, forKey: "widgetShowingConfirmation")
        defaults?.set(moodValue, forKey: "widgetConfirmationMoodValue")
        defaults?.set(Date(), forKey: "widgetConfirmationTimestamp")
    }
    
    private func clearConfirmationState() {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        defaults?.removeObject(forKey: "widgetShowingConfirmation")
        defaults?.removeObject(forKey: "widgetConfirmationMoodValue")
        defaults?.removeObject(forKey: "widgetConfirmationTimestamp")
    }
    
    private func saveWidgetCheckInTimestamp() {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        defaults?.set(Date(), forKey: "lastWidgetCheckIn")
    }
}

// MARK: - Intent Errors

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case invalidMoodValue
    case saveFailed(String)
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidMoodValue:
            return "Invalid mood value. Please select a value between 1 and 5."
        case .saveFailed(let message):
            return "Failed to save mood: \(message)"
        }
    }
}

// MARK: - Haptic Feedback Helper

@MainActor
struct HapticFeedbackHelper {
    static func triggerSuccess() {
        // Haptic feedback is handled by the system for widget interactions
        // This is a placeholder for any additional feedback if needed
    }
}
