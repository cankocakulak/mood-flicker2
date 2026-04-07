import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel
    private let trendViewModel: TrendViewModel
    private let insightsViewModel: InsightsViewModel
    
    init(viewModel: TodayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.trendViewModel = TrendViewModel(moodRepository: viewModel.moodRepository)
        self.insightsViewModel = InsightsViewModel(moodRepository: viewModel.moodRepository)
    }
    
    var body: some View {
        Group {
            if viewModel.isEmpty {
                EmptyStateView()
            } else {
                entriesList
            }
        }
        .navigationTitle("Today")
        .refreshable {
            await viewModel.loadEntries()
            await trendViewModel.loadTrendData()
            await insightsViewModel.loadInsights()
        }
        .task {
            await viewModel.loadEntries()
            await trendViewModel.loadTrendData()
            await insightsViewModel.loadInsights()
        }
        .sheet(isPresented: $viewModel.showAddContextPrompt) {
            AddContextPromptView(
                presetTags: viewModel.presetTags,
                onTagSelected: { tag in
                    Task {
                        await viewModel.addContextToRecentEntry(tag)
                        await trendViewModel.loadTrendData()
                        await insightsViewModel.loadInsights()
                    }
                },
                onDismiss: {
                    viewModel.dismissAddContextPrompt()
                }
            )
        }
    }
    
    private var entriesList: some View {
        List {
            // Insights Section
            Section {
                InsightsView(viewModel: insightsViewModel)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            // 7-Day Trend Chart Section
            Section {
                TrendChartView(viewModel: trendViewModel)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            // Today's Entries Section
            Section(header: Text("Today's Entries").font(.caption)) {
                ForEach(viewModel.entries, id: \.id) { entry in
                    EntryRowView(
                        entry: entry,
                        isShowingTagSelector: viewModel.entryShowingTagSelector == entry.id,
                        presetTags: viewModel.presetTags,
                        onAddContextTap: {
                            viewModel.toggleTagSelector(for: entry.id)
                        },
                        onTagSelected: { tag in
                            Task {
                                await viewModel.updateTag(for: entry, tag: tag)
                                viewModel.hideTagSelector()
                                await insightsViewModel.loadInsights()
                            }
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteEntry(entry)
                                await trendViewModel.loadTrendData()
                                await insightsViewModel.loadInsights()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Entry Row

struct EntryRowView: View {
    let entry: MoodEntry
    let isShowingTagSelector: Bool
    let presetTags: [String]
    let onAddContextTap: () -> Void
    let onTagSelected: (String?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.md) {
                Text(entry.moodEmoji)
                    .font(.system(size: 36))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedTime(entry.timestamp))
                        .font(.headline)
                    
                    if let tag = entry.tag {
                        Button {
                            onTagSelected(nil)
                        } label: {
                            Text(tag)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            onAddContextTap()
                        } label: {
                            Text("Add Context")
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            
            if isShowingTagSelector {
                TagSelectorView(
                    selectedTag: entry.tag,
                    presetTags: presetTags,
                    onTagSelected: onTagSelected
                )
                .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Tag Selector

struct TagSelectorView: View {
    let selectedTag: String?
    let presetTags: [String]
    let onTagSelected: (String?) -> Void
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(presetTags, id: \.self) { tag in
                TagPillButton(
                    tag: tag,
                    isSelected: selectedTag == tag,
                    onTap: {
                        if selectedTag == tag {
                            onTagSelected(nil)
                        } else {
                            onTagSelected(tag)
                        }
                    }
                )
            }
        }
    }
}

struct TagPillButton: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(tag)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Add Context Prompt

struct AddContextPromptView: View {
    let presetTags: [String]
    let onTagSelected: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("Add Context to Your Check-In")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("You just logged a mood from the widget. Would you like to add context?")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                FlowLayout(spacing: 12) {
                    ForEach(presetTags, id: \.self) { tag in
                        Button {
                            onTagSelected(tag)
                        } label: {
                            Text(tag)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, AppTheme.Spacing.xl)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        onDismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "sun.max.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("No moods today")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add the MoodFlicker2 widget to your home screen for quick check-ins")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("With Entries") {
    NavigationStack {
        TodayView(viewModel: TodayViewModel.preview())
    }
}

#Preview("Empty State") {
    NavigationStack {
        TodayView(viewModel: TodayViewModel.previewEmpty())
    }
}

#Preview("Entry Row - No Tag") {
    List {
        EntryRowView(
            entry: MoodEntry(moodValue: 4, timestamp: Date()),
            isShowingTagSelector: false,
            presetTags: MoodEntry.presetTags,
            onAddContextTap: {},
            onTagSelected: { _ in }
        )
    }
}

#Preview("Entry Row - With Tag") {
    List {
        EntryRowView(
            entry: MoodEntry(moodValue: 4, timestamp: Date(), tag: "Work"),
            isShowingTagSelector: false,
            presetTags: MoodEntry.presetTags,
            onAddContextTap: {},
            onTagSelected: { _ in }
        )
    }
}

#Preview("Entry Row - Tag Selector Open") {
    List {
        EntryRowView(
            entry: MoodEntry(moodValue: 4, timestamp: Date()),
            isShowingTagSelector: true,
            presetTags: MoodEntry.presetTags,
            onAddContextTap: {},
            onTagSelected: { _ in }
        )
    }
}

#Preview("Tag Selector") {
    TagSelectorView(
        selectedTag: "Work",
        presetTags: MoodEntry.presetTags,
        onTagSelected: { _ in }
    )
    .padding()
}
