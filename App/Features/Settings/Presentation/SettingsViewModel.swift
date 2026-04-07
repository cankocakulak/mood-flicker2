import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var entryCount: Int = 0
    @Published var isExporting: Bool = false
    @Published var exportResult: ExportResult?
    @Published var showShareSheet: Bool = false
    @Published var exportedFileURL: URL?
    
    private let moodRepository: MoodRepositoryProtocol
    private let csvExportService: CSVExportService
    
    enum ExportResult: Equatable {
        case success(message: String)
        case failure(message: String)
    }
    
    init(moodRepository: MoodRepositoryProtocol) {
        self.moodRepository = moodRepository
        self.csvExportService = CSVExportService(moodRepository: moodRepository)
    }
    
    /// Loads the current entry count
    func loadEntryCount() async {
        do {
            entryCount = try await moodRepository.count()
        } catch {
            entryCount = 0
        }
    }
    
    /// Exports all mood entries to CSV
    func exportData() async {
        guard entryCount > 0 else { return }
        
        isExporting = true
        defer { isExporting = false }
        
        do {
            let fileURL = try await csvExportService.exportAllEntries()
            exportedFileURL = fileURL
            showShareSheet = true
            exportResult = .success(message: "Export ready to share")
        } catch CSVExportError.noEntries {
            exportResult = .failure(message: "No entries to export")
        } catch {
            exportResult = .failure(message: "Export failed: \(error.localizedDescription)")
        }
    }
    
    /// Clears the export result
    func clearExportResult() {
        exportResult = nil
    }
    
    /// Cleans up temporary exported file
    func cleanupExportedFile() {
        if let url = exportedFileURL {
            try? FileManager.default.removeItem(at: url)
            exportedFileURL = nil
        }
    }
}
