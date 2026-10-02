import Foundation

/// Version des gemeinsamen Kerns, wird in beiden Apps unter „Über Onda“ angezeigt.
public enum OndaCoreInfo {
    public static let version = "0.1.0"
}

/// Ein Live-Sender aus der Playlist.
public struct Channel: Identifiable, Hashable, Sendable {
    /// Stabiler Schlüssel (tvg-id, sonst Gruppe + Name). Favoriten, ausgeblendete
    /// Sender und die eigene Reihenfolge hängen an diesem Schlüssel, nicht an der Position.
    public let id: String
    public var name: String
    public var group: String
    public var tvgID: String?
    public var logoURL: URL?
    public var streamURL: URL

    public init(id: String, name: String, group: String, tvgID: String?, logoURL: URL?, streamURL: URL) {
        self.id = id
        self.name = name
        self.group = group
        self.tvgID = tvgID
        self.logoURL = logoURL
        self.streamURL = streamURL
    }

    /// Bildet den stabilen Schlüssel wie im Bauplan beschrieben.
    public static func stableKey(tvgID: String?, group: String, name: String) -> String {
        if let tvgID, !tvgID.trimmingCharacters(in: .whitespaces).isEmpty {
            return "tvg:" + tvgID.trimmingCharacters(in: .whitespaces).lowercased()
        }
        return "n:" + group.lowercased() + "|" + name.lowercased()
    }
}

/// Eine Sendung aus dem EPG (XMLTV).
public struct Programme: Hashable, Sendable {
    public var channelID: String
    public var start: Date
    public var end: Date
    public var title: String
    public var summary: String?

    public init(channelID: String, start: Date, end: Date, title: String, summary: String? = nil) {
        self.channelID = channelID
        self.start = start
        self.end = end
        self.title = title
        self.summary = summary
    }

    public func isLive(at date: Date = Date()) -> Bool { start <= date && date < end }

    /// Fortschritt 0…1 für den Balken unter der Sendung.
    public func progress(at date: Date = Date()) -> Double {
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        return min(1, max(0, date.timeIntervalSince(start) / total))
    }
}

/// Art eines Playlist-Eintrags.
public enum ContentKind: String, Sendable {
    case live, movie, series
}
