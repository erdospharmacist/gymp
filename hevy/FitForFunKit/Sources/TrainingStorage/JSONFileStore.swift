import Foundation
import TrainingCore

public final class JSONFileStore<Value: Codable> {
    private let fileManager: FileManager
    private let fileURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        filename: String,
        fileManager: FileManager = .default,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.fileManager = fileManager
        self.fileURL = try fileManager.applicationSupportDirectory()
            .appendingPathComponent(filename)
        self.decoder = decoder
        self.encoder = encoder
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func load(default defaultValue: Value) throws -> Value {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return defaultValue
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Value.self, from: data)
    }

    public func save(_ value: Value) throws {
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: .atomic)
    }
}

public extension FileManager {
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
