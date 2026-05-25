import Foundation
import TrainingCore

public final class JSONFileStore<Value: Codable> {
    private let fileManager: FileManager
    private let fileURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    //creates a JSON-backed store for one file in Application Support
    public init(
        filename: String,
        fileManager: FileManager = .default,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.fileManager = fileManager
        //all user JSON files live in Application Support so they survive app launches
        self.fileURL = try fileManager.applicationSupportDirectory()
            .appendingPathComponent(filename)
        self.decoder = decoder
        self.encoder = encoder
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    //loads a saved JSON value or returns the caller's default when no file exists yet
    public func load(default defaultValue: Value) throws -> Value {
        //first launch has no file yet, so callers choose the empty/default value they want
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return defaultValue
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Value.self, from: data)
    }

    //saves the current value to disk as formatted JSON
    public func save(_ value: Value) throws {
        let data = try encoder.encode(value)
        //atomic write avoids half-written JSON if the save gets interrupted
        try data.write(to: fileURL, options: .atomic)
    }
}

public extension FileManager {
    //returns the app's Application Support folder, creating it if needed
    func applicationSupportDirectory() throws -> URL {
        let url = urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

        if !fileExists(atPath: url.path) {
            try createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }

        return url
    }
}
