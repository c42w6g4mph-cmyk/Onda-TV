import SwiftUI
import OndaCore

/// Onda für Apple TV. Tab-Leiste oben (Liquid Glass ab tvOS 26),
/// Suche und Einstellungen als Symbole – wie im Prototyp prototypes/tvos.
@main
struct OndaTVApp: App {
    var body: some Scene {
        WindowGroup {
            TVRootView()
        }
    }
}

struct TVRootView: View {
    var body: some View {
        TabView {
            ForEach(OndaSection.allCases) { section in
                PlaceholderScreen(title: section.rawValue, note: section.note)
                    .tabItem { Text(section.rawValue) }
            }
            PlaceholderScreen(title: "Suche", note: "Kanal, Sendung, Film oder Serie")
                .tabItem { Image(systemName: "magnifyingglass") }
            PlaceholderScreen(title: "Einstellungen", note: "Playlists, Senderliste, Player, Bild, Ton, TV-Guide, Darstellung")
                .tabItem { Image(systemName: "gearshape") }
        }
    }
}
