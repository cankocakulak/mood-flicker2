import SwiftUI
import SwiftData

@main
struct MoodFlicker2App: App {
    private let container = AppContainer.live()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // App became active - check for pending widget haptics
                        HapticManager.shared.checkAndTriggerPendingWidgetHaptic()
                    }
                }
        }
        .modelContainer(for: MoodEntry.self)
    }
}
