import Combine
import SwiftData
import SwiftUI

/// View model for insights calculations
@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var mostCommonMood: MoodInsight?
    @Published var bestDayOfWeek: DayInsight?
    @Published var totalEntries: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let moodRepository: MoodRepositoryProtocol
    
    /// Minimum entries needed to show meaningful insights
    static let minimumEntriesForInsights = 7
    
    init(moodRepository: MoodRepositoryProtocol) {
        self.moodRepository = moodRepository
    }
    
    /// Load all insights data
    func loadInsights() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allEntries = try await moodRepository.fetchAll()
            totalEntries = allEntries.count
            
            guard totalEntries >= Self.minimumEntriesForInsights else {
                mostCommonMood = nil
                bestDayOfWeek = nil
                isLoading = false
                return
            }
            
            mostCommonMood = calculateMostCommonMood(from: allEntries)
            bestDayOfWeek = calculateBestDayOfWeek(from: allEntries)
            
        } catch {
            errorMessage = "Failed to load insights: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Calculate the most common mood across all entries
    private func calculateMostCommonMood(from entries: [MoodEntry]) -> MoodInsight? {
        guard !entries.isEmpty else { return nil }
        
        // Count occurrences of each mood value
        var moodCounts: [Int: Int] = [:]
        for entry in entries {
            moodCounts[entry.moodValue, default: 0] += 1
        }
        
        // Find the mood with highest count
        guard let mostCommonValue = moodCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        let count = moodCounts[mostCommonValue] ?? 0
        let percentage = Double(count) / Double(entries.count) * 100
        
        return MoodInsight(
            moodValue: mostCommonValue,
            count: count,
            percentage: percentage
        )
    }
    
    /// Calculate the day of week with highest average mood
    private func calculateBestDayOfWeek(from entries: [MoodEntry]) -> DayInsight? {
        guard !entries.isEmpty else { return nil }
        
        let calendar = Calendar.current
        
        // Group entries by day of week
        var dayOfWeekData: [Int: (totalMood: Int, count: Int)] = [:]
        
        for entry in entries {
            let weekday = calendar.component(.weekday, from: entry.timestamp)
            var data = dayOfWeekData[weekday, default: (0, 0)]
            data.totalMood += entry.moodValue
            data.count += 1
            dayOfWeekData[weekday] = data
        }
        
        // Calculate averages and find best day
        var dayAverages: [(weekday: Int, average: Double)] = []
        
        for (weekday, data) in dayOfWeekData where data.count > 0 {
            let average = Double(data.totalMood) / Double(data.count)
            dayAverages.append((weekday: weekday, average: average))
        }
        
        guard let bestDay = dayAverages.max(by: { $0.average < $1.average }) else {
            return nil
        }
        
        return DayInsight(
            weekday: bestDay.weekday,
            averageMood: bestDay.average,
            entryCount: dayOfWeekData[bestDay.weekday]?.count ?? 0
        )
    }
    
    /// Check if we have enough data to show insights
    var hasEnoughDataForInsights: Bool {
        totalEntries >= Self.minimumEntriesForInsights
    }
    
    /// Number of additional entries needed to unlock insights
    var entriesNeeded: Int {
        max(0, Self.minimumEntriesForInsights - totalEntries)
    }
    
    /// Encouraging message for users with fewer entries
    var encouragingMessage: String {
        switch entriesNeeded {
        case 1:
            return "Check in 1 more day to unlock your insights"
        case 2...3:
            return "Check in for \(entriesNeeded) more days to unlock your insights"
        default:
            return "Keep checking in daily to unlock personalized insights"
        }
    }
}

// MARK: - Insight Models

/// Represents insight about the most common mood
struct MoodInsight: Identifiable {
    let id = UUID()
    let moodValue: Int
    let count: Int
    let percentage: Double
    
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
    
    var description: String {
        switch moodValue {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Neutral"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Neutral"
        }
    }
    
    var formattedPercentage: String {
        String(format: "%.0f%%", percentage)
    }
}

/// Represents insight about the best day of the week
struct DayInsight: Identifiable {
    let id = UUID()
    let weekday: Int // 1 = Sunday, 7 = Saturday
    let averageMood: Double
    let entryCount: Int
    
    var dayName: String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[weekday - 1] ?? "Unknown"
    }
    
    var shortDayName: String {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols[weekday - 1] ?? "Unknown"
    }
    
    var formattedAverage: String {
        String(format: "%.1f", averageMood)
    }
    
    var averageEmoji: String {
        let rounded = Int(round(averageMood))
        switch rounded {
        case 1: return "😔"
        case 2: return "😟"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
}

// MARK: - Preview Support

extension InsightsViewModel {
    static func preview() -> InsightsViewModel {
        let viewModel = InsightsViewModel(moodRepository: try! MoodRepository())
        viewModel.totalEntries = 15
        viewModel.mostCommonMood = MoodInsight(moodValue: 4, count: 8, percentage: 53.3)
        viewModel.bestDayOfWeek = DayInsight(weekday: 6, averageMood: 4.2, entryCount: 3)
        return viewModel
    }
    
    static func previewInsufficientData() -> InsightsViewModel {
        let viewModel = InsightsViewModel(moodRepository: try! MoodRepository())
        viewModel.totalEntries = 3
        return viewModel
    }
}
