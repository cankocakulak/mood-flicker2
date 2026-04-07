import SwiftUI

/// View displaying insights cards
struct InsightsView: View {
    @StateObject private var viewModel: InsightsViewModel
    
    init(viewModel: InsightsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Insights")
                .font(.headline)
                .padding(.horizontal, AppTheme.Spacing.md)
            
            if viewModel.hasEnoughDataForInsights {
                insightsCards
            } else {
                encouragingCard
            }
        }
        .task {
            await viewModel.loadInsights()
        }
    }
    
    private var insightsCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.md) {
                if let mostCommonMood = viewModel.mostCommonMood {
                    MostCommonMoodCard(insight: mostCommonMood)
                }
                
                if let bestDay = viewModel.bestDayOfWeek {
                    BestDayCard(insight: bestDay)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }
    
    private var encouragingCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Insights Coming Soon")
                    .font(.headline)
                
                Text(viewModel.encouragingMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.totalEntries) / CGFloat(InsightsViewModel.minimumEntriesForInsights))
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                Text("\(viewModel.totalEntries)/\(InsightsViewModel.minimumEntriesForInsights)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

// MARK: - Most Common Mood Card

struct MostCommonMoodCard: View {
    let insight: MoodInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.blue)
                Text("Most Common")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(insight.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.description)
                        .font(.headline)
                    Text(insight.formattedPercentage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }
            
            Text("of your moods")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 160)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Best Day Card

struct BestDayCard: View {
    let insight: DayInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.green)
                Text("Best Day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(insight.averageEmoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.dayName)
                        .font(.headline)
                    Text("Avg: \(insight.formattedAverage)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("based on \(insight.entryCount) entries")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 180)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Previews

#Preview("Insights with Data") {
    ScrollView {
        InsightsView(viewModel: InsightsViewModel.preview())
            .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Insights - Insufficient Data") {
    ScrollView {
        InsightsView(viewModel: InsightsViewModel.previewInsufficientData())
            .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Most Common Mood Card") {
    MostCommonMoodCard(
        insight: MoodInsight(moodValue: 4, count: 8, percentage: 53.3)
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Best Day Card") {
    BestDayCard(
        insight: DayInsight(weekday: 6, averageMood: 4.2, entryCount: 3)
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
