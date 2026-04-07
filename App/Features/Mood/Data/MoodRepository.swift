import Foundation
import SwiftData

/// Protocol defining the interface for mood data operations
protocol MoodRepositoryProtocol {
    /// Save a new mood entry
    func save(_ entry: MoodEntry) async throws
    
    /// Delete a mood entry
    func delete(_ entry: MoodEntry) async throws
    
    /// Fetch all mood entries sorted by timestamp (newest first)
    func fetchAll() async throws -> [MoodEntry]
    
    /// Fetch mood entries for a specific date range
    func fetch(from startDate: Date, to endDate: Date) async throws -> [MoodEntry]
    
    /// Fetch mood entries for a specific day
    func fetch(for date: Date) async throws -> [MoodEntry]
    
    /// Fetch the most recent mood entry
    func fetchMostRecent() async throws -> MoodEntry?
    
    /// Get count of all mood entries
    func count() async throws -> Int
    
    /// Get count of entries for a specific date range
    func count(from startDate: Date, to endDate: Date) async throws -> Int
    
    /// Update the tag for a mood entry
    func updateTag(for entry: MoodEntry, tag: String?) async throws
}

/// SwiftData-based implementation of MoodRepository
@MainActor
final class MoodRepository: MoodRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer? = nil) throws {
        if let container = modelContainer {
            self.modelContainer = container
        } else {
            // Use shared app group container for widget access
            let schema = Schema([MoodEntry.self])
            
            // Try to use app group container for widget sharing
            let appGroupID = "group.com.cankocakulak.moodflicker2"
            let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
            
            let configuration: ModelConfiguration
            if let containerURL = url {
                let storeURL = containerURL.appendingPathComponent("MoodFlicker2.store")
                configuration = ModelConfiguration(
                    schema: schema,
                    url: storeURL,
                    isStoredInMemoryOnly: false
                )
            } else {
                // Fallback to default container if app group not available
                configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
            }
            
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        }
        self.modelContext = ModelContext(self.modelContainer)
    }
    
    // MARK: - CRUD Operations
    
    func save(_ entry: MoodEntry) async throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
    
    func delete(_ entry: MoodEntry) async throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    // MARK: - Fetch Operations
    
    func fetchAll() async throws -> [MoodEntry] {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetch(from startDate: Date, to endDate: Date) async throws -> [MoodEntry] {
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.timestamp >= startDate && entry.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetch(for date: Date) async throws -> [MoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return try await fetch(from: startOfDay, to: endOfDay)
    }
    
    func fetchMostRecent() async throws -> MoodEntry? {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
    
    // MARK: - Count Operations
    
    func count() async throws -> Int {
        let descriptor = FetchDescriptor<MoodEntry>()
        return try modelContext.fetchCount(descriptor)
    }
    
    func count(from startDate: Date, to endDate: Date) async throws -> Int {
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.timestamp >= startDate && entry.timestamp <= endDate
            }
        )
        return try modelContext.fetchCount(descriptor)
    }
    
    func updateTag(for entry: MoodEntry, tag: String?) async throws {
        entry.tag = tag
        try modelContext.save()
    }
}

// MARK: - Preview Support

extension MoodRepository {
    /// Creates a repository with sample data for previews
    static func preview() -> MoodRepository {
        // swiftlint:disable:next force_try
        let repository = try! MoodRepository()
        
        // Add sample entries
        let calendar = Calendar.current
        let now = Date()
        
        let sampleEntries = [
            MoodEntry(moodValue: 4, timestamp: now, tag: "Work"),
            MoodEntry(moodValue: 3, timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!),
            MoodEntry(moodValue: 5, timestamp: calendar.date(byAdding: .hour, value: -5, to: now)!, tag: "Social"),
            MoodEntry(moodValue: 2, timestamp: calendar.date(byAdding: .day, value: -1, to: now)!, tag: "Sleep"),
            MoodEntry(moodValue: 4, timestamp: calendar.date(byAdding: .day, value: -2, to: now)!, tag: "Health")
        ]
        
        for entry in sampleEntries {
            Task {
                try? await repository.save(entry)
            }
        }
        
        return repository
    }
}
