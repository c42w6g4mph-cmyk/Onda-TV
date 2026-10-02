import Foundation

/// Abgleich „Im Trend“ ↔ Playlist. Gleiche Logik wie in den Prototypen:
/// Titel normalisieren, dann exakt, Präfix oder Ähnlichkeit (Bigramme), Jahr als Bremse.
public enum TitleMatcher {

    public struct Match: Equatable, Sendable {
        public let index: Int
        public let score: Double
    }

    /// Entfernt Sprachpräfixe (DE |, EN |, MULTI:), Jahreszahlen in Klammern,
    /// Qualitäts- und Versionszusätze sowie Sonderzeichen.
    public static func normalize(_ raw: String) -> String {
        // Sprachpräfix nur in Grossbuchstaben („DE |“, „MULTI:“), damit „Dune: Part Two“ ganz bleibt
        var x = replace(raw, #"^\s*[A-Z]{2,5}\s*[|:]\s*"#, "")
        x = x.lowercased().folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US_POSIX"))
        x = replace(x, #"[\(\[](19|20)\d\d[\)\]]"#, " ")
        x = replace(x, #"\b(4k|uhd|fhd|hd|sd|hevc|h265|multi[\s-]?sub|extended cut|directors cut|imax edition|s\d\d(e\d\d)?)\b"#, " ")
        x = replace(x, #"[^a-z0-9]+"#, " ")
        return x.trimmingCharacters(in: .whitespaces)
    }

    /// Jahreszahl in Klammern, z. B. „(2022)“ oder „[2025]“.
    public static func year(in raw: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: #"[\(\[]((19|20)\d\d)[\)\]]"#),
              let m = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
              let r = Range(m.range(at: 1), in: raw) else { return nil }
        return Int(raw[r])
    }

    /// Dice-Koeffizient über Zeichen-Bigramme (Leerzeichen entfernt).
    public static func dice(_ a: String, _ b: String) -> Double {
        let A = bigrams(a), B = bigrams(b)
        guard !A.isEmpty, !B.isEmpty else { return 0 }
        var pool = B
        var hits = 0
        for g in A {
            if let j = pool.firstIndex(of: g) { hits += 1; pool.remove(at: j) }
        }
        return 2 * Double(hits) / Double(A.count + B.count)
    }

    /// Bester Treffer für einen Trend-Titel in den Playlist-Einträgen, ab Score 0.86.
    public static func bestMatch(title: String, year: Int?, isMovie: Bool, in rawEntries: [String]) -> Match? {
        let nt = normalize(title)
        var best: Match?
        for (i, raw) in rawEntries.enumerated() {
            let no = normalize(raw)
            var score: Double
            if no == nt { score = 1 }
            else if no.hasPrefix(nt + " ") || nt.hasPrefix(no + " ") { score = 0.92 }
            else { score = dice(no, nt) }
            if isMovie, let y = self.year(in: raw), let ty = year, abs(y - ty) > 1 { score -= 0.5 }
            if score > (best?.score ?? 0) { best = Match(index: i, score: score) }
        }
        guard let b = best, b.score >= 0.86 else { return nil }
        return b
    }

    private static func bigrams(_ s: String) -> [String] {
        let c = Array(s.replacingOccurrences(of: " ", with: ""))
        guard c.count > 1 else { return [] }
        return (0..<(c.count - 1)).map { String(c[$0]) + String(c[$0 + 1]) }
    }

    private static func replace(_ s: String, _ pattern: String, _ with: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
        return regex.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: with)
    }
}
