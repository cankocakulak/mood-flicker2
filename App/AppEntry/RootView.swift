import SwiftUI

struct RootView: View {
    let container: AppContainer
    
    init(container: AppContainer) {
        self.container = container
    }
    
    var body: some View {
        TabView {
            TodayTab()
                .tabItem {
                    Label("Today", systemImage: "calendar.day")
                }
            
            HealthTab(container: container)
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
            
            SettingsTab(container: container)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Today Tab

struct TodayTab: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            TodayView(viewModel: createViewModel())
        }
    }
    
    private func createViewModel() -> TodayViewModel {
        let repository = try! MoodRepository(modelContainer: modelContext.container)
        return TodayViewModel(moodRepository: repository)
    }
}

// MARK: - Health Tab

struct HealthTab: View {
    let container: AppContainer
    
    var body: some View {
        NavigationStack {
            HealthView(viewModel: HealthViewModel(service: container.healthAPI, logger: container.logger))
        }
    }
}

// MARK: - Settings Tab

struct SettingsTab: View {
    let container: AppContainer
    
    var body: some View {
        NavigationStack {
            SettingsView(viewModel: SettingsViewModel(moodRepository: container.moodRepository))
        }
    }
}

// MARK: - Previews

#Preview {
    RootView(container: .live())
}
