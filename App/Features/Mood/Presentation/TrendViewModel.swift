import SwiftUI
import SwiftData

/// View model for trend chart data
@MainActor
final class TrendViewModel: ObservableObject {
    @Published var dailyAverages: [DailyMoodAverage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDataPoint: DailyMoodAverage?
    
    private let moodRepository: MoodRepositoryProtocol
    
    init(moodRepository: MoodRepositoryProtocol) {
        self.moodRepository = moodRepository
    }
    
    /// Load 7-day trend data
    func loadTrendData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            dailyAverages = try await calculateDailyAverages(forDays: 7)
        } catch {
            errorMessage = "Failed to load trend data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Calculate daily averages for the specified number of days
    private func calculateDailyAverages(forDays days: Int) async throws -> [DailyMoodAverage] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var averages: [DailyMoodAverage] = []
        
        // Calculate for each day (going backwards from today)
        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            let entries = try await moodRepository.fetch(for: date)
            
            let average: Double?
            if entries.isEmpty {
                average = nil
            } else {
                let sum = entries.reduce(0) { $0 + $1.moodValue }
                average = Double(sum) / Double(entries.count)
            }
            
            let dailyAverage = DailyMoodAverage(
                date: date,
                averageMood: average,
                entryCount: entries.count
            )
            averages.append(dailyAverage)
        }
        
        return averages
    }
    
    /// Check if there's enough data to show meaningful insights
    var hasEnoughData: Bool {
        let totalEntries = dailyAverages.reduce(0) { $0 + $1.entryCount }
        return totalEntries >= 3 // Show chart with at least 3 entries
    }
    
    /// Get the date range string for the chart
    var dateRangeString: String {
        guard let firstDate = dailyAverages.first?.date,
              let lastDate = dailyAverages.last?.date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: firstDate)) – \(formatter.string(from: lastDate))"
    }
}

// MARK: - Daily Mood Average Model

/// Represents the average mood for a single day
struct DailyMoodAverage: Identifiable {
    let id = UUID()
    let date: Date
    let averageMood: Double?
    let entryCount: Int
    
    /// Formatted date string (e.g., "Mon", "Tue")
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    /// Short date label (e.g., "4/7")
    var shortDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    /// Full formatted date for tooltip
    var fullDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Formatted average mood value
    var formattedAverage: String {
        guard let average = averageMood else { return "–" }
        return String(format: "%.1f", average)
    }
    
    /// Emoji representation of the average mood
    var averageEmoji: String {
        guard let average = averageMood else { return "○" }
        let rounded = Int(round(average))
        switch rounded {
        case 1: return "😔"
        case 2: return "😟"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "○"
        }
    }
    
    /// Color for the mood value (gradient from blue-gray to coral)
    var moodColor: Color {
        guard let average = averageMood else { return .gray.opacity(0.3) }
        // Map 1-5 to color gradient (blue-gray → coral)
        let normalized = (average - 1) / 4 // 0 to 1
        return Color(
            red: 0.4 + (0.9 - 0.4) * normalized,  // Blue-gray to coral red
            green: 0.5 + (0.4 - 0.5) * normalized,
            blue: 0.6 + (0.4 - 0.6) * normalized
        )
    }
}

// MARK: - Preview Support

extension TrendViewModel {
    static func preview() -> TrendViewModel {
        let viewModel = TrendViewModel(moodRepository: try! MoodRepository())
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        viewModel.dailyAverages = [
            DailyMoodAverage(date: calendar.date(byAdding: .day, value: -6, to: today)!, averageMood: 3.0, entryCount: 2),
            DailyMoodAverage(date: calendar.date(byAdding: .day, value: -5, to: today)!, averageMood: 4.0, entryCount: 3),
            DailyMoodAverage(date: calendar.date(byAdding: .day, value: -4, to: today)!, averageMood: nil, entryCount: 0),
            DailyMoodAverage(date: calendar.date(byAdding: .day, value: -3, to: today)!, averageMood: 3.5, entryCount: 2),
            DailyMoodAverage(date: calendar.date(byAdding: .day, value: -2, to: today)!, averageMood: 4.5, entryCount: 4),
            DailyMoodAverage(date: calendar.date(byAdding: .day, value: -1, to: today)!, averageMood: 2.5, entryCount: 1),
            DailyMoodAverage(date: today, averageMood: 4.0, entryCount: 3)
        ]
        return viewModel
    }
    
    static func previewEmpty() -> TrendViewModel {
        let viewModel = TrendViewModel(moodRepository: try! MoodRepository())
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        viewModel.dailyAverages = (0..<7).map { dayOffset in
            DailyMoodAverage(
                date: calendar.date(byAdding: .day, value: -dayOffset, to: today)!,
                averageMood: nil,
                entryCount: 0
            )
        }.reversed()
        return viewModel
    }
}
