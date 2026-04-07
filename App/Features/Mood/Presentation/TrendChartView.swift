import SwiftUI
import Charts

/// 7-day mood trend chart view
struct TrendChartView: View {
    @StateObject private var viewModel: TrendViewModel
    
    init(viewModel: TrendViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            header
            
            if viewModel.hasEnoughData {
                chartContent
            } else {
                insufficientDataView
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .task {
            await viewModel.loadTrendData()
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("7-Day Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(viewModel.dateRangeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    private var chartContent: some View {
        Chart(viewModel.dailyAverages) { day in
            if let average = day.averageMood {
                BarMark(
                    x: .value("Day", day.dayLabel),
                    y: .value("Mood", average)
                )
                .foregroundStyle(day.moodColor.gradient)
                .cornerRadius(4)
                .annotation(position: .top) {
                    Text(day.averageEmoji)
                        .font(.caption)
                }
            } else {
                // Placeholder for days with no data
                BarMark(
                    x: .value("Day", day.dayLabel),
                    y: .value("Mood", 0.1)
                )
                .foregroundStyle(Color.gray.opacity(0.15))
                .cornerRadius(4)
            }
        }
        .chartYScale(domain: 0...5.5)
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        moodEmoji(for: intValue)
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let stringValue = value.as(String.self) {
                        Text(stringValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        if let date: String = chartProxy.value(atX: location.x) {
                            if let selectedDay = viewModel.dailyAverages.first(where: { $0.dayLabel == date }) {
                                withAnimation(.spring(duration: 0.3)) {
                                    viewModel.selectedDataPoint = selectedDay
                                }
                            }
                        }
                    }
            }
        }
        .frame(height: 180)
        .overlay(alignment: .bottom) {
            if let selected = viewModel.selectedDataPoint {
                dataPointTooltip(for: selected)
            }
        }
    }
    
    private var insufficientDataView: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text("Not enough data yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Check in a few more times to see your trends")
                .font(.caption)
                .foregroundStyle(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
    private func dataPointTooltip(for day: DailyMoodAverage) -> some View {
        VStack(spacing: 4) {
            Text(day.fullDateLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                Text(day.averageEmoji)
                Text("Average: \(day.formattedAverage)")
                    .fontWeight(.semibold)
                Text("(\(day.entryCount) entries)")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 8)
        .onAppear {
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    viewModel.selectedDataPoint = nil
                }
            }
        }
    }
    
    private func moodEmoji(for value: Int) -> Text {
        switch value {
        case 1: return Text("😔")
        case 2: return Text("😟")
        case 3: return Text("😐")
        case 4: return Text("🙂")
        case 5: return Text("😄")
        default: return Text("○")
        }
    }
}

// MARK: - Compact Chart View (for smaller spaces)

struct CompactTrendChartView: View {
    @StateObject private var viewModel: TrendViewModel
    
    init(viewModel: TrendViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Chart(viewModel.dailyAverages) { day in
            if let average = day.averageMood {
                LineMark(
                    x: .value("Day", day.dayLabel),
                    y: .value("Mood", average)
                )
                .foregroundStyle(moodGradient)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                AreaMark(
                    x: .value("Day", day.dayLabel),
                    y: .value("Mood", average)
                )
                .foregroundStyle(moodGradient.opacity(0.1))
                
                PointMark(
                    x: .value("Day", day.dayLabel),
                    y: .value("Mood", average)
                )
                .foregroundStyle(day.moodColor)
                .symbolSize(50)
            }
        }
        .chartYScale(domain: 0.5...5.5)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let stringValue = value.as(String.self) {
                        Text(stringValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(height: 80)
        .task {
            await viewModel.loadTrendData()
        }
    }
    
    private var moodGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.5, blue: 0.6), // Blue-gray
                Color(red: 0.9, green: 0.4, blue: 0.4)  // Coral
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Previews

#Preview("Trend Chart - With Data") {
    TrendChartView(viewModel: TrendViewModel.preview())
        .padding()
}

#Preview("Trend Chart - Empty") {
    TrendChartView(viewModel: TrendViewModel.previewEmpty())
        .padding()
}

#Preview("Compact Chart") {
    CompactTrendChartView(viewModel: TrendViewModel.preview())
        .padding()
        .frame(height: 120)
}
