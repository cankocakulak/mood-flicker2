import UIKit
import CoreHaptics

// MARK: - Haptic Manager

/// Manages haptic feedback for the app
/// Widget interactions cannot directly trigger haptics, so this manager
/// coordinates feedback when the main app detects widget activity
@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    private var hapticEngine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    
    // UserDefaults keys
    private let widgetHapticPendingKey = "widgetHapticPending"
    private let widgetHapticTimestampKey = "widgetHapticTimestamp"
    
    private init() {
        prepareHaptics()
    }
    
    // MARK: - Setup
    
    private func prepareHaptics() {
        // Check if device supports haptics
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        guard supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Handle engine reset
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            
            // Handle engine stop
            hapticEngine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
            supportsHaptics = false
        }
    }
    
    // MARK: - Widget Haptic Coordination
    
    /// Call this when app becomes active to check for pending widget haptics
    func checkAndTriggerPendingWidgetHaptic() {
        guard isWidgetHapticPending() else { return }
        
        // Check if the haptic is recent (within last 5 seconds)
        if let timestamp = getWidgetHapticTimestamp(),
           Date().timeIntervalSince(timestamp) < 5.0 {
            triggerWidgetSuccessHaptic()
        }
        
        clearWidgetHapticPending()
    }
    
    /// Marks a widget haptic as pending (called from widget)
    static func markWidgetHapticPending() {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        defaults?.set(true, forKey: "widgetHapticPending")
        defaults?.set(Date(), forKey: "widgetHapticTimestamp")
    }
    
    private func isWidgetHapticPending() -> Bool {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        return defaults?.bool(forKey: widgetHapticPendingKey) ?? false
    }
    
    private func getWidgetHapticTimestamp() -> Date? {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        return defaults?.object(forKey: widgetHapticTimestampKey) as? Date
    }
    
    private func clearWidgetHapticPending() {
        let defaults = UserDefaults(suiteName: "group.com.cankocakulak.moodflicker2")
        defaults?.removeObject(forKey: widgetHapticPendingKey)
        defaults?.removeObject(forKey: widgetHapticTimestampKey)
    }
    
    // MARK: - Haptic Patterns
    
    /// Light impact feedback for subtle interactions
    func triggerLightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact feedback for standard interactions
    func triggerMediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact feedback for significant interactions
    func triggerHeavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Success feedback for positive actions
    func triggerSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Error feedback for failed actions
    func triggerError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Warning feedback for cautionary actions
    func triggerWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Selection feedback for picker-style interactions
    func triggerSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Widget-Specific Haptics
    
    /// Success haptic optimized for widget mood logging
    func triggerWidgetSuccessHaptic() {
        if supportsHaptics, let engine = hapticEngine {
            // Use CoreHaptics for a richer experience
            do {
                let pattern = try createWidgetSuccessPattern()
                try engine.playPattern(from: pattern)
            } catch {
                // Fallback to standard success haptic
                triggerSuccess()
            }
        } else {
            // Standard UIKit haptic
            triggerSuccess()
        }
    }
    
    private func createWidgetSuccessPattern() throws -> CHHapticPattern {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
}

// MARK: - View Extension

extension View {
    /// Adds widget haptic detection based on scene phase
    func detectWidgetHaptics() -> some View {
        self.modifier(WidgetHapticModifier())
    }
}

// MARK: - Widget Haptic Modifier

struct WidgetHapticModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    // App became active - check for pending widget haptics
                    HapticManager.shared.checkAndTriggerPendingWidgetHaptic()
                }
            }
    }
}
