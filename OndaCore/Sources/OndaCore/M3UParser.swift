import Foundation

/// Ein roher Eintrag aus einer M3U-Datei.
public struct M3UEntry: Hashable, Sendable {
    public var title: String
    public var attributes: [String: String]
    public var url: URL

    public var tvgID: String? { attributes["tvg-id"].flatMap { $0.isEmpty ? nil : $0 } }
    public var group: String { attributes["group-title"] ?? "" }
    public var logoURL: URL? { attributes["tvg-logo"].flatMap(URL.init(string:)) }
}

/// Zeilenweiser M3U-Parser. Grosse Playlists werden später streamend eingelesen;
/// die Zeilenlogik bleibt dieselbe.
public enum M3UParser {

    public static func parse(_ text: String) -> [M3UEntry] {
        var entries: [M3UEntry] = []
        var pendingTitle: String?
        var pendingAttributes: [String: String] = [:]
        var pendingGroup: String?

        for rawLine in text.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#EXTM3U") { continue }

            if line.hasPrefix("#EXTINF") {
                let (attributes, title) = parseExtInf(line)
                pendingAttributes = attributes
                pendingTitle = title
                pendingGroup = nil
            } else if line.hasPrefix("#EXTGRP:") {
                pendingGroup = String(line.dropFirst("#EXTGRP:".count)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("#") {
                continue
            } else if let title = pendingTitle, let url = URL(string: line) {
                var attributes = pendingAttributes
                if attributes["group-title"] == nil, let group = pendingGroup { attributes["group-title"] = group }
                entries.append(M3UEntry(title: title, attributes: attributes, url: url))
                pendingTitle = nil
                pendingAttributes = [:]
                pendingGroup = nil
            }
        }
        return entries
    }

    /// Macht aus den Einträgen Live-Sender. Filme und Serien erkennt die echte App
    /// am Xtream-Typ bzw. an der Dateiendung; hier zählt alles ohne .mp4/.mkv als Live.
    public static func channels(from entries: [M3UEntry]) -> [Channel] {
        entries.filter { kind(of: $0) == .live }.map { entry in
            Channel(id: Channel.stableKey(tvgID: entry.tvgID, group: entry.group, name: entry.title),
                    name: entry.title, group: entry.group, tvgID: entry.tvgID,
                    logoURL: entry.logoURL, streamURL: entry.url)
        }
    }

    public static func kind(of entry: M3UEntry) -> ContentKind {
        let path = entry.url.path.lowercased()
        if path.contains("/series/") { return .series }
        if path.contains("/movie/") || path.hasSuffix(".mp4") || path.hasSuffix(".mkv") { return .movie }
        return .live
    }

    /// Zerlegt `#EXTINF:-1 tvg-id="x" group-title="y",Name` in Attribute und Titel.
    static func parseExtInf(_ line: String) -> ([String: String], String) {
        var attributes: [String: String] = [:]
        let chars = Array(line)
        var i = 0
        var inQuotes = false
        var titleStart: Int?
        // Titel beginnt nach dem ersten Komma ausserhalb von Anführungszeichen
        while i < chars.count {
            if chars[i] == "\"" { inQuotes.toggle() }
            if chars[i] == ",", !inQuotes { titleStart = i + 1; break }
            i += 1
        }
        let head = titleStart.map { String(chars[0..<($0 - 1)]) } ?? line
        let title = titleStart.map { String(chars[$0...]).trimmingCharacters(in: .whitespaces) } ?? ""

        // Attribute der Form key="value"
        var rest = Substring(head)
        while let eq = rest.range(of: "=\"") {
            let keyPart = rest[rest.startIndex..<eq.lowerBound]
            let key = keyPart.split(separator: " ").last.map(String.init) ?? ""
            let afterQuote = rest[eq.upperBound...]
            guard let close = afterQuote.firstIndex(of: "\"") else { break }
            let value = String(afterQuote[afterQuote.startIndex..<close])
            if !key.isEmpty { attributes[key.lowercased()] = value }
            rest = afterQuote[afterQuote.index(after: close)...]
        }
        return (attributes, title)
    }
}
