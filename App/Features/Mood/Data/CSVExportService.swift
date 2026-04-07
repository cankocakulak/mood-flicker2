import Foundation

/// Service for exporting mood data to CSV format
@MainActor
final class CSVExportService {
    private let moodRepository: MoodRepositoryProtocol
    
    init(moodRepository: MoodRepositoryProtocol) {
        self.moodRepository = moodRepository
    }
    
    /// Generates a CSV file from all mood entries
    /// - Returns: URL to the generated CSV file
    /// - Throws: Error if export fails
    func exportAllEntries() async throws -> URL {
        let entries = try await moodRepository.fetchAll()
        return try await generateCSV(from: entries)
    }
    
    /// Generates a CSV file from mood entries within a date range
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    /// - Returns: URL to the generated CSV file
    /// - Throws: Error if export fails
    func exportEntries(from startDate: Date, to endDate: Date) async throws -> URL {
        let entries = try await moodRepository.fetch(from: startDate, to: endDate)
        return try await generateCSV(from: entries)
    }
    
    /// Generates CSV data from mood entries
    private func generateCSV(from entries: [MoodEntry]) async throws -> URL {
        // Create CSV content with UTF-8 BOM for Excel compatibility
        var csvContent = "\u{FEFF}" // UTF-8 BOM
        
        // Header row
        csvContent += "Date,Time,Mood (1-5),Mood Emoji,Tag\n"
        
        // Data rows
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        // Process entries in batches for memory efficiency with large datasets
        let batchSize = 100
        var processedCount = 0
        
        while processedCount < entries.count {
            let endIndex = min(processedCount + batchSize, entries.count)
            let batch = entries[processedCount..<endIndex]
            
            for entry in batch {
                let date = dateFormatter.string(from: entry.timestamp)
                let time = timeFormatter.string(from: entry.timestamp)
                let moodValue = entry.moodValue
                let moodEmoji = entry.moodEmoji
                let tag = entry.tag ?? ""
                
                // Escape tag if it contains commas or quotes
                let escapedTag = escapeCSVField(tag)
                
                csvContent += "\(date),\(time),\(moodValue),\(moodEmoji),\(escapedTag)\n"
            }
            
            processedCount = endIndex
        }
        
        // Write to temporary file
        let fileName = "MoodFlicker_Export_\(formattedCurrentDate()).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        guard let data = csvContent.data(using: .utf8) else {
            throw CSVExportError.encodingFailed
        }
        
        try data.write(to: tempURL, options: .atomic)
        
        return tempURL
    }
    
    /// Escapes a field for CSV if necessary
    private func escapeCSVField(_ field: String) -> String {
        // If field contains comma, quote, or newline, wrap in quotes and escape internal quotes
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
    
    /// Returns current date formatted for filename
    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Errors

enum CSVExportError: Error, LocalizedError {
    case encodingFailed
    case fileWriteFailed
    case noEntries
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode CSV data"
        case .fileWriteFailed:
            return "Failed to write CSV file"
        case .noEntries:
            return "No mood entries to export"
        }
    }
}
