import SwiftUI
import SwiftData

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var entryShowingTagSelector: UUID?
    @Published var showAddContextPrompt: Bool = false
    @Published var recentWidgetEntry: MoodEntry?
    
    let moodRepository: MoodRepositoryProtocol
    private let keyValueStore: KeyValueStore
    
    /// Preset context tags available for mood entries
    let presetTags: [String] = MoodEntry.presetTags
    
    init(moodRepository: MoodRepositoryProtocol, keyValueStore: KeyValueStore = UserDefaultsStore(userDefaults: .standard)) {
        self.moodRepository = moodRepository
        self.keyValueStore = keyValueStore
    }
    
    func loadEntries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            entries = try await moodRepository.fetch(for: Date())
            checkForRecentWidgetCheckIn()
        } catch {
            errorMessage = "Failed to load entries: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func checkForRecentWidgetCheckIn() {
        guard let lastCheckIn = keyValueStore.date(forKey: "lastWidgetCheckIn") else {
            return
        }
        
        let fiveMinutesAgo = Date().addingTimeInterval(-5 * 60)
        
        // Check if widget check-in happened within last 5 minutes
        guard lastCheckIn > fiveMinutesAgo else {
            return
        }
        
        // Find the most recent entry without a tag
        if let recentUntaggedEntry = entries.first(where: { $0.tag == nil && $0.timestamp >= fiveMinutesAgo }) {
            recentWidgetEntry = recentUntaggedEntry
            showAddContextPrompt = true
        }
    }
    
    func dismissAddContextPrompt() {
        showAddContextPrompt = false
        recentWidgetEntry = nil
    }
    
    func addContextToRecentEntry(_ tag: String) async {
        guard let entry = recentWidgetEntry else { return }
        await updateTag(for: entry, tag: tag)
        dismissAddContextPrompt()
    }
    
    func deleteEntry(_ entry: MoodEntry) async {
        do {
            try await moodRepository.delete(entry)
            await loadEntries()
        } catch {
            errorMessage = "Failed to delete entry: \(error.localizedDescription)"
        }
    }
    
    func updateTag(for entry: MoodEntry, tag: String?) async {
        do {
            try await moodRepository.updateTag(for: entry, tag: tag)
            await loadEntries()
        } catch {
            errorMessage = "Failed to update tag: \(error.localizedDescription)"
        }
    }
    
    func toggleTagSelector(for entryId: UUID) {
        if entryShowingTagSelector == entryId {
            entryShowingTagSelector = nil
        } else {
            entryShowingTagSelector = entryId
        }
    }
    
    func hideTagSelector() {
        entryShowingTagSelector = nil
    }
    
    var isEmpty: Bool {
        entries.isEmpty && !isLoading
    }
}

// MARK: - Preview Support

extension TodayViewModel {
    static func preview() -> TodayViewModel {
        let viewModel = TodayViewModel(moodRepository: try! MoodRepository())
        viewModel.entries = [
            MoodEntry(moodValue: 4, timestamp: Date(), tag: "Work"),
            MoodEntry(moodValue: 3, timestamp: Date().addingTimeInterval(-7200)),
            MoodEntry(moodValue: 5, timestamp: Date().addingTimeInterval(-18000), tag: "Social")
        ]
        return viewModel
    }
    
    static func previewEmpty() -> TodayViewModel {
        TodayViewModel(moodRepository: try! MoodRepository())
    }
}
