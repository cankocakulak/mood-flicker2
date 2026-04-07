import SwiftUI
import SwiftData

@main
struct MoodFlicker2App: App {
    private let container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
        .modelContainer(for: MoodEntry.self)
    }
}
