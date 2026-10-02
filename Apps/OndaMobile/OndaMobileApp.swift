import SwiftUI
import OndaCore

/// Onda für iPhone (und vorerst iPad). Tab-Leiste unten, Suche als eigener Tab,
/// Einstellungen über den Knopf oben rechts – wie im Prototyp prototypes/ios.
@main
struct OndaMobileApp: App {
    var body: some Scene {
        WindowGroup {
            MobileRootView()
        }
    }
}

struct MobileRootView: View {
    @State private var showSettings = false

    var body: some View {
        TabView {
            ForEach(OndaSection.allCases) { section in
                NavigationStack {
                    PlaceholderScreen(title: section.rawValue, note: section.note)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showSettings = true
                                } label: {
                                    Image(systemName: "slider.horizontal.3")
                                }
                                .accessibilityLabel("Einstellungen")
                            }
                        }
                }
                .tabItem { Label(section.rawValue, systemImage: section.symbol) }
            }
            NavigationStack {
                PlaceholderScreen(title: "Suche", note: "Kanal, Sendung, Film oder Serie")
            }
            .tabItem { Label("Suche", systemImage: "magnifyingglass") }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                PlaceholderScreen(title: "Einstellungen", note: "Playlists, An Apple TV senden, Senderliste, Player, Bild, Wiedergabe, TV-Guide, Darstellung, Sync")
            }
        }
    }
}
