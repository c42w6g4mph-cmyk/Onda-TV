import SwiftUI
import OndaCore

/// Platzhalter für einen Bereich, bis er nach Bauplan umgesetzt ist.
/// Wird von OndaTV und OndaMobile gemeinsam genutzt.
struct PlaceholderScreen: View {
    let title: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.largeTitle.bold())
            Text(note)
                .foregroundStyle(.secondary)
            Text("OndaCore \(OndaCoreInfo.version)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(40)
    }
}

/// Die vier Hauptbereiche, gleich auf tvOS und iOS.
enum OndaSection: String, CaseIterable, Identifiable {
    case home = "Start"
    case live = "Live TV"
    case guide = "TV-Guide"
    case library = "Mediathek"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "house"
        case .live: return "tv"
        case .guide: return "calendar"
        case .library: return "film"
        }
    }

    var note: String {
        switch self {
        case .home: return "Jetzt live, Meine Sender, Weiterschauen, Im Trend"
        case .live: return "Gruppen, Kanalliste, Vorschau bzw. Player"
        case .guide: return "Raster mit Jetzt-Linie, Heute ⇄ Morgen, Jetzt, 20:15, Gruppen"
        case .library: return "Filme · Serien · Meine Liste, eine Trend-Liste"
        }
    }
}
