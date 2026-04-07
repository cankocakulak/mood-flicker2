import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showExportConfirmation: Bool = false
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            Section {
                ExportDataRow(
                    entryCount: viewModel.entryCount,
                    isExporting: viewModel.isExporting,
                    onExport: {
                        Task {
                            await viewModel.exportData()
                        }
                    }
                )
                .disabled(viewModel.entryCount == 0 || viewModel.isExporting)
            } header: {
                Text("Data")
            } footer: {
                if viewModel.entryCount == 0 {
                    Text("Add some mood entries to enable export")
                        .font(.caption)
                } else {
                    Text("Export all \(viewModel.entryCount) mood entries as a CSV file")
                        .font(.caption)
                }
            }
            
            Section {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(buildNumber)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .task {
            await viewModel.loadEntryCount()
        }
        .refreshable {
            await viewModel.loadEntryCount()
        }
        .sheet(isPresented: $viewModel.showShareSheet, onDismiss: {
            viewModel.cleanupExportedFile()
            showExportConfirmation = true
        }) {
            if let fileURL = viewModel.exportedFileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .alert("Export Complete", isPresented: $showExportConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your mood data has been exported successfully.")
        }
    }
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
}

// MARK: - Export Data Row

struct ExportDataRow: View {
    let entryCount: Int
    let isExporting: Bool
    let onExport: () -> Void
    
    var body: some View {
        Button(action: onExport) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundStyle(entryCount > 0 ? .blue : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Data")
                        .font(.body)
                    
                    if entryCount > 0 {
                        Text("\(entryCount) entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if isExporting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(entryCount > 0 ? .primary : .secondary)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(moodRepository: MockMoodRepository()))
    }
}

// MARK: - Mock Repository for Previews

@MainActor
private final class MockMoodRepository: MoodRepositoryProtocol {
    func save(_ entry: MoodEntry) async throws {}
    func delete(_ entry: MoodEntry) async throws {}
    func fetchAll() async throws -> [MoodEntry] { [] }
    func fetch(from startDate: Date, to endDate: Date) async throws -> [MoodEntry] { [] }
    func fetch(for date: Date) async throws -> [MoodEntry] { [] }
    func fetchMostRecent() async throws -> MoodEntry? { nil }
    func count() async throws -> Int { 42 }
    func count(from startDate: Date, to endDate: Date) async throws -> Int { 0 }
    func updateTag(for entry: MoodEntry, tag: String?) async throws {}
}
