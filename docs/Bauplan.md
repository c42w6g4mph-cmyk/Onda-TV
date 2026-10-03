# Onda – Bauplan für tvOS und iOS

Stand: 03.10.2026 · Grundlage: Prototyp 1.2 nach Minimal-Umbau, iOS nach MyTVOnline+-Abläufen (Artifacts „Onda“ für Apple TV und „Onda iPhone“) · Status: bereit für die Swift-Umsetzung, mit den unten genannten offenen Punkten

---

## 1. Ziel und Rahmen

- Premium-IPTV-Player für Apple TV, dazu iPhone und iPad, im Look eines TV-Anbieters
- Hauptinhalt: **MPEG-TS-Streams (.ts)** über M3U oder Xtream Codes
- Vorgaben: **maximale Bildqualität**, **möglichst keine Lizenzkosten**, App komplett auf **Deutsch und Englisch**, Erscheinungsbild **dunkel, hell oder automatisch**, **übersichtlich und minimalistisch**
- Nicht möglich und deshalb nicht vorgesehen: Replay, „Von Anfang an“, Aufnahmen, Werbung überspringen (alles anbieterseitig)

## 2. Getroffene Entscheidungen

| Thema | Entscheidung | Begründung |
|---|---|---|
| Engine für .ts und Dateien | **Testsieger aus Meilenstein 2**, Favorit **MPVKit (LGPL)**, Alternativen **VLCKit 4** und **KSPlayer (LGPL-Lizenz)** | aktuelle FFmpeg-Engines, die verbreitete Apps nutzen (Abschnitt 2a/2b). VLCKit 3 ist veraltet und nur noch Rückfall |
| Engine für HLS | **AVPlayer** | Systemplayer, beste Integration (HDR, Dolby Vision, Bild-in-Bild und AirPlay auf iOS) |
| Auswahl in der App | Automatisch · AVPlayer · zweite Engine (Einstellung unverändert, nur die Bezeichnung folgt dem Testsieger) | „Automatisch“: HLS → AVPlayer, alles andere → zweite Engine. **Keine weiteren Engines in der Auswahl**: Der Nutzer soll nie eine Engine wählen müssen |
| Weitere Engines | nur im Player-Test vergleichen, nicht im Produkt | siehe Abschnitt 2a |
| Deinterlacing | Automatisch (= Yadif 2x), Aus, Verwerfen, Überblenden, Bob, Yadif, Yadif 2x | entspricht den VLC-Modi; BWDIF gibt es in VLC 3 nicht |
| Einstellungen | **bleiben vollständig wie bisher** (Entscheid Sinan, 02.10.2026) | Der Minimal-Umbau betrifft nur die Bildschirme, nicht die Einstellungen |
| Sprache | String Catalog (Localizable.xcstrings), Deutsch und Englisch, plus Umschalter in der App | |
| Erscheinungsbild | Dunkel · Hell · Wie Apple TV bzw. Wie iPhone | über `preferredColorScheme`; Video-Bereiche bleiben immer dunkel |

## 2a. Player-Engines im Vergleich (Stand 03.10.2026)

| Engine | Lizenz | Live-.ts | Bild-in-Bild / AirPlay | Stand |
|---|---|---|---|---|
| AVPlayer | gratis (System) | nur über HLS | voll | stabil |
| VLCKit 3.7.3 | LGPL, gratis | ja, mit Yadif | Bild-in-Bild nein, AirPlay unklar | stabil |
| VLCKit 4 | LGPL 2.1, gratis | ja | Bild-in-Bild ja (iOS, macOS) | Alpha: 4.0.0-alpha.21 (Juli 2026), offizielles Swift-Paket ab alpha.22 |
| KSPlayer | GPL gratis, LGPL kostenpflichtig (Preis auf Anfrage) | ja | ja, inkl. HDR und Dolby Vision | aktiv; genutzt von IPTV-Apps wie APTV und Smart IPTV |
| MPVKit (libmpv) | LGPL (GPL optional) | ja | eingeschränkt | Metal nur inoffiziell, laut Projekt „nur zum Lernen“; trotzdem in Streamyfin und Moonfin (Jellyfin-Clients) im Einsatz |
| AVPlayer mit lokalem Umpacken | gratis | ja, wenn Codecs Apple-kompatibel | voll | Eigenbau: .ts auf dem Gerät ohne Neukodierung in HLS umpacken (so macht es LiquidFin). Kein MPEG-2-Video, kein MP2-Ton, Deinterlacing nur durch das System |
| Infuse-Engine | proprietär | – | – | nicht verfügbar |

Verbreitung: Infuse nutzt einen eigenen Player auf FFmpeg-Basis (seit 2010). Streamyfin und Moonfin nutzen MPVKit, Swiftfin VLCKit und AVPlayer, APTV und Smart IPTV KSPlayer.

**Entscheid (03.10.2026):** zwei Engines, die Onda automatisch wählt. **AVPlayer** für HLS (Bild-in-Bild, AirPlay, HDR, Dolby Vision, geringster Akkuverbrauch) und **eine FFmpeg-Engine** für alles andere (MPEG-TS, MKV, AC3/DTS, Untertitel). Welche, entscheidet der Player-Test (Meilenstein 2) mit **fünf Kandidaten**: AVPlayer (Referenz für HLS), **MPVKit** (Favorit), **VLCKit 4** (aktuelle Alpha), **KSPlayer** (GPL nur intern testen, im Produkt nur mit LGPL-Lizenz) und AVPlayer mit Umpacken. VLCKit 3 fällt aus dem Test, weil veraltet. Gegenszenario: Gewinnt KSPlayer klar, kostet das Lizenzgebühren (Preis beim Anbieter anfragen). Ist VLCKit 4 bis zum Start nicht stabil, scheidet es aus.

Quellen: [VLCKit-4-Paket](https://github.com/virtualox/vlckit-spm) · [VLC 4.0 Beta für iOS](https://www.igen.fr/app-store/2026/06/vlc-40-passe-en-beta-sous-ios-avec-de-nombreuses-nouveautes-156783) · [VLCKit-Versionen](https://code.videolan.org/videolan/VLCKit/-/tags) · [KSPlayer](https://swiftpackageregistry.com/kingslay/KSPlayer) · [MPVKit](https://github.com/mpvkit/MPVKit) · [Engines der Jellyfin-Clients für tvOS](https://perfectmediaserver.com/jellyfinjune/clients/tvos/) · [Infuse-Engine](https://community.firecore.com/t/what-player-does-infuse-use/38003/3)

## 2b. Verkauf im App Store: Metadaten und Engine (03.10.2026)

Ziel: Cover, Hintergrund, Handlung, Besetzung und Trailer in guter Qualität bei jedem Film und jeder Serie, rechtlich sauber in einer kostenpflichtigen App.

**Fakten**

| Quelle | Kosten bei kommerzieller App | Bemerkung |
|---|---|---|
| Daten des Anbieters (Xtream `get_vod_info`, `get_series_info`) | keine | Cover, Handlung, Besetzung, Trailer-Link, oft die TMDB-ID. Qualität schwankt je Anbieter |
| TMDB | eigene kommerzielle Lizenz nötig, Preis nicht öffentlich (**unklar**, Verkauf anfragen) | gratis nur nicht-kommerziell mit Quellenangabe ([TMDB FAQ](https://developer.themoviedb.org/docs/faq)). Bilder bis Originalauflösung |
| TheTVDB | gratis mit Quellenangabe bis 50'000 $ Umsatz/Jahr, 1'000 $/Jahr bis 250'000 $, 10'000 $/Jahr bis 1 Mio. $ ([TheTVDB](https://www.thetvdb.com/api-information)) | stark bei Serien, schwächer bei Filmen |

**Entscheid: drei Stufen**

1. **Anbieter-Daten zuerst.** Gratis; mit der mitgelieferten TMDB-ID ist der Treffer eindeutig.
2. **Ergänzung aus TMDB mit kommerzieller Lizenz** über einen **eigenen kleinen Server** (z. B. Cloudflare Worker): Schlüssel bleibt geheim, Zwischenspeicher, Anbieter später wechselbar ohne App-Update. Bilder: Poster w500/w780, Hintergründe w1280 (iPhone) bzw. original (Apple TV 4K), Titel-Logos (PNG), Trailer als YouTube-Schlüssel.
3. **Lizenzanfrage bei TMDB früh stellen**, sobald das Preismodell steht. Der Preis entscheidet, ob TMDB oder TheTVDB die Hauptquelle wird.

Verworfen: Schlüssel pro Nutzer (wie im Prototyp) – rechtliche Grauzone in einer Bezahl-App und umständlich.

**App Store:** Screenshots ohne echte Cover und Senderlogos (Testdaten), keine Inhalte und keine Anbieter-Empfehlungen in der App. LGPL-Engines (MPVKit, VLCKit) dynamisch einbinden, Lizenzhinweis in der App. Einschätzung, keine Rechtsberatung: vor dem Start prüfen lassen.

**Im Prototyp:** Echte Beispiel-Cover (Wikipedia, TVmaze) für die Optik. Mit eigenem TMDB-Schlüssel (nur Prototyp, nicht-kommerziell) zusätzlich Hintergründe, Titel-Logos, Trailer, Handlung, Besetzung und Folgen. Detailseite im Stil der Apple TV App.

## 3. Architektur

Ein gemeinsames Swift Package **OndaCore** für tvOS und iOS, darüber zwei schlanke App-Targets.

```
OndaCore (Swift Package)
├── Models          Channel, Group, Programme, Movie, Series, Episode, Playlist, TrendItem
├── Playlist        M3U-Parser (zeilenweise, streamend), Xtream-API-Client
├── EPG             XMLTV-Parser (SAX/XMLParser, streamend), gz-Entpacken, Zeitzonen
├── Matching        Titel-Normalisierung + Index (Trends ↔ Playlist)
├── Trends          Client für Film-Datenbank (TMDB o. ä.), täglicher Cache, eine zusammengeführte Trend-Liste
├── Metadata        Anbieter-Daten + TMDB über eigenen Server, Cache 7 Tage, Bildgrössen je Gerät
├── Storage         SQLite/SwiftData im Caches-Ordner, iCloud für Favoriten/Einstellungen/Senderliste, Keychain für Zugangsdaten
├── Player          Protokoll PlayerEngine + AVPlayerEngine + FFmpeg-Engine (Testsieger), Stream-Analyse, vorheriger Sender
├── Display         Bildwiederholrate/Dynamikbereich (AVDisplayCriteria, nur tvOS)
└── Localization    String Catalog
OndaTV (tvOS-Target)     SwiftUI, Focus Engine, Tab-Leiste oben, Top Shelf, QR-Einrichtung
OndaMobile (iOS-Target)  SwiftUI, Touch, Tab-Leiste unten, Kontextmenüs, Bild-in-Bild, AirPlay, „An Apple TV senden“
```

### Player-Abstraktion (Kern)

```swift
protocol PlayerEngine: AnyObject {
    func load(_ url: URL, options: PlaybackOptions)
    func play(); func pause(); func stop()
    var stats: StreamStats { get }          // Auflösung, fps, Codec, Bitrate, verworfene Frames, Puffer
    var audioTracks: [Track] { get }; func selectAudio(_ id: Int)
    var subtitleTracks: [Track] { get }; func selectSubtitle(_ id: Int?)
}
```

- **VLC-Deinterlacing** als Medienoption, z. B. `:deinterlace=1` und `:deinterlace-mode=yadif2x` (Werte: discard, blend, bob, yadif, yadif2x)
- **Bildwiederholrate anpassen (tvOS):** Bei VLC gibt es kein AVAsset. Deshalb wird `AVDisplayCriteria(refreshRate:formatDescription:)` selbst erzeugt und auf `window.avDisplayManager.preferredDisplayCriteria` gesetzt ([Apple-Doku](https://developer.apple.com/documentation/avfoundation/avdisplaycriteria)). Die fps stammen aus der VLC-Trackinfo (bei 1080i mit Yadif 2x → 50 Hz).
- **Stream-Details:** Werte aus VLC-Medienstatistik und Trackinfo bzw. aus `AVPlayerItem.accessLog()`

### Einrichtung per QR-Code (ohne Server, ohne Kosten)

1. Das Apple TV startet beim Öffnen von „Playlist hinzufügen“ einen kleinen Webserver im Heimnetz (`NWListener` aus dem Network-Framework).
2. Der QR-Code enthält die lokale Adresse und einen Einmal-Code, z. B. `http://192.168.1.42:8080/setup?code=7H8F-6WWV`.
3. Das iPhone öffnet die Seite in Safari, ohne App. Dort gibt man M3U-URL oder Xtream-Zugang, EPG-URL und User-Agent ein.
4. Die Daten gehen direkt ans Apple TV. Sie landen dort im Keychain, danach stoppt der Webserver. Der Code verfällt nach etwa 10 Minuten.
5. Die iOS-App von Onda findet das Apple TV per Bonjour (`NWBrowser`) und überträgt eine gespeicherte Playlist ganz ohne QR-Code („An Apple TV senden“, im iPhone-Prototyp gezeigt).

### Senderliste bearbeiten

- Ausgeblendete Gruppen und Sender sowie die eigene Reihenfolge werden pro Playlist gespeichert, und zwar über einen **stabilen Schlüssel** (tvg-id, sonst Name plus Gruppe), nicht über die Position. So bleibt die Anpassung erhalten, wenn der Anbieter die Playlist aktualisiert.
- tvOS: OK blendet ein oder aus. ⏯ (Play/Pause) startet das Verschieben, dann ▲ ▼ und OK zum Ablegen.
- iOS: Schalter pro Gruppe und Sender, Sortieren per Ziehen (`.onMove`). Zusätzlich „Ausblenden“ direkt im Kontextmenü eines Senders.

## 3a. Schneller Senderwechsel (Ziel: unter 1 Sekunde)

Der wichtigste Qualitätseindruck einer IPTV-App. Im Prototyp ist der Ablauf nachgebildet, und die Stream-Details zeigen die Umschaltzeit.

1. **Sofort reagieren, später laden.** Beim Tastendruck sofort Logo, Sendername und laufende Sendung aus der lokalen Datenbank zeigen. Den Stream erst nach etwa 250–300 ms ohne weiteren Tastendruck starten und einen laufenden Start abbrechen. Wer ▲ gedrückt hält, löst nicht für jeden Sender einen Stream aus.
2. **Ein Player, Medium tauschen.** Einen `VLCMediaPlayer` samt Zeichenfläche wiederverwenden und nur das Medium wechseln, nicht jedes Mal neu aufbauen.
3. **Kleiner Live-Puffer.** Etwa 0,5–1 s (`:network-caching`/`:live-caching`, Optionsnamen je nach VLCKit-Version prüfen). Für Filme bleibt ein grösserer Puffer. Hardware-Decoding über VideoToolbox.
4. **Grenze Keyframe.** Das erste Bild kommt frühestens mit dem nächsten Keyframe, bei IPTV meist alle 1–2 s. Unter 1 s hängt deshalb auch vom Anbieter ab.
5. **Eine Engine pro Playlist.** Bei Xtream ein Ausgabeformat für alle Sender wählen (ts → VLC), damit benachbarte Sender nicht zwischen den Engines wechseln. Die Entscheidung pro Sender zwischenspeichern, bei einem Fehler automatisch auf die andere Engine ausweichen.
6. **Vorladen mit Vorsicht.** Viele Xtream-Konten erlauben nur eine Verbindung (`max_connections`). Ein zweiter, „warmer“ Player für den nächsten Sender nur dann, wenn mehrere Verbindungen erlaubt sind. Sonst nur DNS/TLS und Weiterleitungen vorbereiten.
7. **Bildwiederholrate stabil halten.** Ein Wechsel 50 Hz ↔ 59,94 Hz bedeutet 1–3 s Schwarzbild am Fernseher. Die Display-Kriterien nur ändern, wenn sich Bildratenfamilie oder SDR/HDR wirklich ändern.
8. **Rückmeldung.** Das letzte Bild abgedunkelt stehen lassen, einen Ladekreis erst nach 500 ms zeigen, bei Fehlern klar mit „Erneut versuchen“. Nach einem Abbruch automatisch neu verbinden.
9. **Umschalten frei von schwerer Arbeit halten.** Kein Speichern bei jedem Tastendruck (gebündelt nach etwa 1 s), keine Netzwerkabfragen für die Info-Leiste.
10. **Vorheriger Sender.** Der zuletzt gesehene Sender ist mit einem Schritt erreichbar (tvOS: Kanalliste ◀ und Player-Menü „Mehr“, iOS: Knopf ↩ im Player).

## 3b. Fokus und Fernbedienung in Swift

- Jede Spalte bzw. jeder Bereich ist eine eigene `.focusSection()` und merkt sich das zuletzt fokussierte Element (`@FocusState`, `.defaultFocus`). Der Prototyp bildet das nach. So springt ◀ aus der Vorschau in die Kanalliste statt in die Gruppen.
- Beim Wechsel zurück in einen Tab bleibt die Position erhalten.
- Auswahl folgt dem Fokus nur verzögert (ca. 150 ms), damit beim schnellen Durchscrollen nichts neu geladen wird.
- Fernbedienung: `onMoveCommand`, `onPlayPauseCommand`, `onExitCommand`. Es gibt keine Live-Taste, deshalb heisst „Zurück zu Live“: ▶ bei zeitversetzter Wiedergabe. Auf dem Clickpad Wischen und Klicken unterscheiden, damit versehentliches Wischen nicht den Sender wechselt.

## 4. Bildschirme tvOS (Prototyp → Swift)

| Prototyp | tvOS-Umsetzung |
|---|---|
| Tab-Leiste: Start, Live TV, TV-Guide, Mediathek, Suche (Symbol), Einstellungen (Symbol) | `TabView` (oben, Liquid Glass ab tvOS 26), Suche als `Tab(role: .search)` |
| Start: „Jetzt live“ (Titel, Sender, Zeit, ein Knopf), Meine Sender (Favoriten + zuletzt gesehen), Weiterschauen, Im Trend (nur Verfügbares) | `ScrollView` + `LazyHStack`-Regale, `.focusSection()` |
| Live TV: Gruppen · Kanalliste · Vorschau, ohne Zähler und Spaltentitel, Qualität nur bei 4K | drei Spalten, Vorschau mit kleinem Player (stummgeschaltet) |
| TV-Guide: eine Chip-Zeile mit Tag (Heute ⇄ Morgen), Jetzt, 20:15 und Gruppen; Raster mit Jetzt-Linie | eigenes Raster-Layout, horizontal virtualisiert |
| Mediathek: Filme · Serien · Meine Liste; Hero + eine Trend-Reihe (nur Verfügbares, „Alle anzeigen“ am Ende) + Playlist-Regale | Regale mit `.buttonStyle(.card)` |
| Detailseiten: ein Hauptknopf, Favorit als Symbol | eigene Views |
| Player: Info-Leiste, Kanalliste (◀), Player-Menü (▶ / ▼) | eigener Player-Overlay (nicht `AVPlayerViewController`, da VLC) |
| Player-Menü mit drei Reitern: Ton & Untertitel · Bild · Mehr (vorheriger Sender, Sleep-Timer, Stream-Details) | Overlay mit Tabs |
| Einstellungen mit Auswahlfenstern (Qualitätsbalken, Vor-/Nachteile), unverändert | `List` + eigene Auswahl-Sheets |
| Playlist hinzufügen: QR-Code (Standard), M3U, Xtream, User-Agent | Sheet; QR über `CIFilter.qrCodeGenerator` |
| Senderliste bearbeiten: zwei Spalten, ein-/ausblenden, verschieben | eigene Ansicht mit Verschiebe-Modus |

## 4a. Minimal-Umbau (02.10.2026, beide Apps)

Ziel: übersichtlicher, weniger Information auf dem Bildschirm, gleiche Funktionalität. Die Einstellungen bleiben bewusst unverändert.

| Bereich | Entfernt | Neu oder geändert |
|---|---|---|
| Navigation (tvOS) | 8 Tabs | 4 Tabs + Suche und Einstellungen als Symbole; Filme, Serien und Favoriten liegen in der Mediathek |
| Start | Qualitäts-Etikett, „Danach“, TV-Guide-Knopf im Banner, Reihe „Zuletzt gesehen“ | „Meine Sender“ = Favoriten + zuletzt gesehen |
| Live TV | Zähler, Spaltentitel bzw. Zeile „Schweiz · 14 Kanäle“, FHD/HD/SD-Etiketten, TV-Guide-Knopf in der Vorschau, Stern in jeder Zeile (iOS) | nur 4K bleibt sichtbar; iOS: Sender gedrückt halten → Abspielen, Favorit, Programm, Ausblenden |
| TV-Guide | zweite Chip-Zeile, Zeitsprünge 06:00/12:00/18:00/22:00 | eine Zeile: Heute ⇄ Morgen, Jetzt, 20:15, Gruppen |
| Mediathek | getrennte Reihen „Aktuell im Trend“ und „Top 10“, Filter-Chip, Quellenhinweis, Zeile „Mein Anbieter · 21 Filme“, FHD auf Postern | eine Trend-Liste (Top 10 aller Dienste, ergänzt um Netflix-Trends), Rang im Hero bzw. auf der Karte, standardmässig nur Verfügbares, „Alle anzeigen“ am Ende |
| Detail | Eyebrow „Film · Im Trend“, technische Zeile „Gefunden als …“ | ein Hauptknopf, Favorit als Symbol, „＋ Merken“ für nicht Verfügbares |
| Player | iOS: vier Kacheln und Qualitäts-Etiketten unter dem Video | Menü mit 3 statt 5 Reitern; Vorheriger Sender; iOS hochkant nur das wichtigste Qualitäts-Etikett (gemäss Einstellung „Qualitäts-Anzeige“) |

Geprüft im Browser: alle geänderten Bildschirme beider Apps, Deutsch und Englisch, dunkel und hell, Fernbedienung (tvOS) und Touch inkl. langem Drücken (iOS). Keine Skriptfehler.

## 4b. Review-Umsetzung (03.10.2026, beide Apps)

- **Weiterschauen:** Fortschritt wird gespeichert (beim Stoppen, alle 15 s). Ab 95 % gilt ein Film als gesehen bzw. springt die Serie zur nächsten Folge. Einstellung «Filme fortsetzen»: Fragen / Immer / Nie.
- **Zeitversatz** wirkt auf das EPG (Anzeige und Fortschritt).
- **Mediathek:** «Alle Filme/Serien», «Neueste», Kategorie-Reihen mit «Alle N ›» und Raster (sortierbar Neueste/A–Z, nachladen in 60er-Schritten). Trends nur noch auf Start.
- **TV-Guide:** Gruppenwahl wie bei Live TV.
- **EPG-Quelle pro Playlist:** Automatisch (Xtream xmltv.php) / Eigene URL / Datei, im Playlist-Editor.
- **Schnellstart + Refresh-Intervall:** Die geparste Playlist liegt im Cache (IndexedDB), der Start lädt nicht neu. Einstellung «Playlist & EPG aktualisieren»: Bei jedem Start / Täglich / Alle 3 Tage (Standard) / Alle 7 Tage / Nur manuell. Ist ein Update fällig und der automatische Abruf nicht möglich, erscheint ein Hinweis auf Start.

- **EPG-Zuordnung (Fix):** Mehrere Sender mit derselben tvg-id (HD/SD/Backup, Länder-Gruppen) bekommen alle die Sendungen; Gross-/Kleinschreibung und Leerzeichen egal; ohne oder mit falscher tvg-id greift der Name. Gespeichert wird pro EPG-Kanal einmal (Format v2). Die Playlist zeigt «x von y Sendern» und listet Sender ohne Daten.
- **Einstellungen entflochten:** Alles zu Quelle und Aktualisierung liegt bei der Playlist (Status, TV-Guide-Quelle, laden, neu laden, Erweitert). Unter «TV-Guide» bleibt nur der Zeitversatz. «Automatisch aktualisieren» steht bei den Playlists.
- **Einheitliche Anzeige:** Ohne Sendungsdaten steht überall «Keine Sendungsdaten» (nicht mehr Gruppe/Land). Start zeigt bevorzugt einen Sender mit EPG.

## 4c. Metadaten-Strategie (Cover, Infos) für den Verkauf

1. **Primär: Daten des Anbieters** über Xtream `get_vod_info` / `get_series_info` (Cover, Backdrop, Handlung, Besetzung, Bewertung, tmdb_id). Kostenlos, keine eigene Lizenz nötig, gängige Praxis.
2. **Ergänzung: TheTVDB** (kommerziell gratis unter 50'000 USD Umsatz/Jahr, mit Attribution; darüber 1'000 USD/Jahr). Stärker bei Serien.
3. **TMDB nur mit Vertrag** (kommerziell = Lizenz nötig; Preis nicht öffentlich, Sekundärquelle nennt ca. 149 USD/Monat – unbestätigt). Offerte anfragen, bevor gerechnet wird. Kein Modell «Nutzer bringt eigenen Key» als Standard (Grauzone).
4. Ausgeschlossen: OMDb (nicht kommerziell), IMDb (zu teuer), Watchmode (zu teuer), Wikimedia-Poster (meist nicht frei).

## 5. End-to-End-Prüfung des Prototyps

Getestet in einem Browser: alle Bildschirme, Deutsch und Englisch, dunkel und hell, dazu ein Zufallstest mit 2'800 Fernbedienungs-Eingaben. **Ergebnis: keine Skriptfehler, der Fokus geht nie verloren.**

Während der Prüfung gefunden und behoben:

| Problem | Auswirkung | Status |
|---|---|---|
| CSS-Klasse „live“ doppelt verwendet | Live-Zellen im TV-Guide zu hoch, LIVE-Etikett über die ganze Breite | behoben |
| Englisch: Dezimalkomma bei fps | „49,99 fps“ statt „49.99 fps“ | behoben |
| TV-Guide wählte zuerst eine vergangene Sendung | falsche Detailanzeige beim Öffnen | behoben |
| Gespeicherte Einstellungen nach Optionsänderung ungültig | mögliche leere Anzeige | abgesichert (Rückfall auf Standard) |

Zweite Gesamtprüfung (Prototyp 1.2) mit einem unabhängigen Prüfer: Er fand 18 Fehler und UX-Probleme. Alle relevanten sind behoben und mit automatischen Tests nachgewiesen. Danach liefen 3'600 zufällige Eingaben ohne Fehler durch.

| Behoben | Vorher |
|---|---|
| Senderwahl aus der Kanalliste im Player | Pause-Zustand blieb hängen, „Zuletzt gesehen“ wurde nicht aktualisiert |
| ▲▼ nach Wahl aus „Zuletzt gesehen“ | sprang auf einen falschen Sender |
| ausgeblendete Sender | waren beim Durchschalten trotzdem erreichbar |
| Xtream-Passwortfeld | war mit der Fernbedienung nicht erreichbar |
| ◀ aus der Live-Vorschau | sprang in die Gruppen und wechselte die Gruppe |
| Live TV über ▼ betreten | setzte die Gruppe auf „Favoriten“ zurück |
| Zurück aus dem Player | zeigte den Start-Sender statt den zuletzt gesehenen |
| Tonspur/Untertitel | als Position gespeichert statt als Sprache, falsch nach Senderwechsel |
| Favorit in Detailseite | Rückkehr landete im falschen Regal |
| Sprache EN → DE | Teile blieben englisch, Sendungstitel wurden mitübersetzt |
| Favoriten-Zähler | zählte ausgeblendete Sender mit |
| Detail aus Detail | Zurück schloss alles statt eine Ebene zurück |
| TV-Guide | Sackgasse am rechten Rand (jetzt blättert er weiter), Durchlaufen der Zeit-Chips verstellte die Zeit |
| Mitternacht | Programmdaten und „Heute/Morgen“ wurden nicht neu berechnet |
| Erinnerungen und Film-Fortschritt | wurden nicht gespeichert bzw. nie ausgelöst |
| Heller Modus: grünes „In deiner Playlist“ im Hero | war grau (Minimal-Umbau) |

Bewusste Vereinfachungen im Prototyp (in Swift richtig lösen):

- Alle Daten sind Testdaten. Streams, EPG, Statistiken und Trend-Abgleich sind simuliert, die Abgleich-Logik ist aber echt und übertragbar.
- Die Übersetzung erfolgt im Prototyp beim Anzeigen. In Swift wird das ein String Catalog.
- Die Fokussteuerung ist nachgebaut. Die tvOS Focus Engine verhält sich anders und muss auf dem Gerät feinjustiert werden.
- Gespeichert wird im Browser. tvOS garantiert keinen dauerhaften lokalen Speicher, siehe Risiken. Die beiden Prototypen teilen keine Daten.
- Nur als Oberfläche vorhanden, ohne Funktion: EPG-Quelle, Zeitversatz, Beim Start aktualisieren, Kindersicherung, Filme fortsetzen. Diese müssen in Swift umgesetzt werden.
- Übersetzung: In Swift einen String Catalog mit Pluralregeln verwenden. Inhalte des Anbieters (Titel, Sender, Playlist-Namen) werden nie übersetzt.
- iOS: Sortieren der Senderliste mit Pfeilen statt Ziehen; Kamera-Scan des QR-Codes nur als Hinweis.

## 6. Technische Risiken und offene Punkte

| # | Risiko | Massnahme |
|---|---|---|
| 1 | **Unverschlüsselte http-Streams und -Playlists** (bei IPTV üblich) | `NSAllowsArbitraryLoadsForMedia` reicht nur für AVFoundation. VLC und die Playlist-Abrufe brauchen `NSAllowsArbitraryLoads` mit Begründung in der App-Review ([Apple-Forum](https://developer.apple.com/forums/thread/83834)) |
| 2 | **Speicher auf tvOS** wird vom System geleert | Playlist und EPG im Caches-Ordner, jederzeit neu ladbar. Favoriten und Einstellungen in iCloud, Zugangsdaten im Keychain |
| 3 | **EPG-Grösse** (oft > 50 MB, gezippt) | streamend parsen, nur ±2 Tage behalten, Zeitzonen und Sommerzeit aus XMLTV korrekt umrechnen |
| 4 | **Live pausieren** mit VLC | Puffer nur wenige Minuten. Auf dem Gerät prüfen, sonst entfernen |
| 5 | **Senderwechsel-Tempo** mit VLC bei .ts | Puffer klein halten, auf dem Gerät messen. Vergleich gemäss Abschnitt 2a |
| 6 | **LGPL-Pflichten (MPVKit, VLCKit)** | als dynamisches Framework einbinden, Lizenzhinweis in der App, Quellcode-Hinweis. Kurz rechtlich prüfen |
| 7 | **Metadaten und Trends:** TMDB ist nur für nicht-kommerzielle Nutzung kostenlos | kommerzielle Lizenz anfragen, Anbieter-Daten zuerst, TheTVDB als Alternative (Abschnitt 2b) |
| 8 | **App-Review bei IPTV-Apps** ist streng | keine Inhalte mitliefern, kein „Free TV“, Demo-Playlist mit legalen Streams für die Prüfer, Screenshots ohne geschützte Senderlogos |
| 9 | **Markenrecht „Onda“** | Swissreg, DPMA und EUIPO vor dem Launch prüfen, Namen in App Store Connect reservieren |
| 10 | **Bildqualität** VLC vs. Infuse-Niveau | Vergleich mit eigenen Sendern (1080i, 720p50, 4K) auf Apple TV 4K |
| 11 | **Lokaler Webserver für die QR-Einrichtung** | prüfen, ob tvOS eine Freigabe für das lokale Netzwerk verlangt (Info.plist-Begründung). Falls der Server nicht möglich ist: Ausweichen auf die iOS-App |
| 12 | **Einstellungen „Bildwiederholrate/Dynamikbereich anpassen“** | die App kann den Modus nur anfordern. Er greift nur, wenn am Apple TV „Inhalt anpassen“ aktiv ist. Das ist in der App so beschrieben |
| 13 | **Surround-Ton** | Dolby Digital wird nach Systemeinstellung weitergegeben. DTS kann das Apple TV nicht als Bitstream ausgeben, VLC wandelt es in PCM um (auf dem Gerät prüfen) |
| 14 | **Zeitversetzt/Pause bei Live** | VLC braucht dafür einen Zwischenspeicher, AVPlayer kann nur im Zeitfenster der HLS-Playlist zurück. Auf dem Gerät prüfen |
| 15 | **QR-Einrichtung über unverschlüsseltes http im Heimnetz** | Einmal-Code mit kurzer Gültigkeit. Sicherer über die iOS-App (verschlüsselte Verbindung per Bonjour) |
| 16 | **Bild-in-Bild mit der FFmpeg-Engine (iOS)** | AVPlayer kann es sicher, VLCKit 4 laut Projekt, KSPlayer ja, MPVKit eingeschränkt. Im Player-Test prüfen; sonst Umpacken nach HLS (2a) |
| 17 | **AirPlay mit VLC (iOS)** | Bild und Ton sicher nur mit AVPlayer. Mit VLC vermutlich nur Ton oder Bildschirmsynchronisierung ([VLCKit-Ticket](https://code.videolan.org/videolan/VLCKit/-/issues/624), ohne klare Antwort). Auf dem Gerät testen |
| 18 | **Hintergrund und Mobilfunk (iOS)** | Bild-in-Bild und Ton im Hintergrund brauchen `UIBackgroundModes: audio` und `AVAudioSession(.playback)`. Einstellung „Mobile Daten“ mit `NWPathMonitor` umsetzen |
| 19 | **Langes Drücken (iOS)** ist schlecht auffindbar | Hinweis im leeren Favoriten-Zustand; in Swift `.contextMenu` verwenden, dann zeigt iOS die Vorschau und das Menü wie gewohnt |

## 7. Funktionsumfang

**In den Prototypen vorhanden:** Startseite, Live TV, TV-Guide (heute/morgen), Mediathek (Filme, Serien, Meine Liste) mit einer Trend-Liste inkl. Abgleich gegen die Playlist, Favoriten, Merkliste, Zuletzt gesehen, Vorheriger Sender, Suche, Erinnerungen, Live pausieren, Player-Menü (Ton & Untertitel, Bild, Mehr), Qualitäts-Badges, Engine-Wahl, Deinterlacing, Bildwiederholrate und Dynamikbereich anpassen (tvOS), Surround-Ton (tvOS), mehrere Playlists, **Einrichtung per QR-Code mit dem iPhone**, **User-Agent pro Playlist**, **Senderliste bearbeiten**, Deutsch/Englisch, Hell/Dunkel. **Zusätzlich auf dem iPhone:** Player hoch und quer, Wischgesten, Kontextmenü pro Sender, Bild-in-Bild, AirPlay-Auswahl, „An Apple TV senden“, Nächste Folge im Player.

**Bei Mitbewerbern verbreitet, bei Onda noch offen** (Vorschlag für die Priorität):

| Funktion | Priorität | Bemerkung |
|---|---|---|
| Weitere HTTP-Header pro Playlist (z. B. Referer) | mittel | User-Agent ist bereits vorgesehen |
| EPG-Zuordnung manuell (tvg-id) und mehrere EPG-Quellen | hoch | häufige Fehlerquelle bei IPTV |
| Automatische Playlist- und EPG-Aktualisierung | hoch | |
| iCloud-Sync (Favoriten, Einstellungen, Weiterschauen, Senderliste) | mittel | im iPhone-Prototyp als Einstellung vorhanden |
| Top Shelf (Weiterschauen/Lieblingssender auf dem Homescreen) | mittel | starkes Premium-Merkmal; iOS-Gegenstück: Widgets |
| Nächste Folge automatisch abspielen | mittel | |
| Profile | mittel | |
| Multiview (2–4 Sender) | später | rechenintensiv, mit VLC auf dem Gerät testen |
| Echte Kindersicherung mit PIN | mittel | im Prototyp nur angedeutet |
| iPad-Layout (Seitenleiste, Live TV dreispaltig) | mittel | im Prototyp noch nicht gezeigt |
| Backup/Export der Einstellungen | niedrig | |

## 8. iOS-App

**Prototyp:** Artifact „Onda iPhone“. Gleiche Testdaten, gleiche Abgleich-Logik, gleiche Einstellungs-Schlüssel und gleiche Farb- und Schriftwelt wie tvOS. Der grösste Teil (Daten, Parser, EPG, Abgleich, Senderliste, Player-Kern, Übersetzungen) liegt in OndaCore und wird geteilt.

| Prototyp iPhone | iOS-Umsetzung |
|---|---|
| Tab-Leiste unten: Start, Live TV, TV-Guide, Mediathek + Suche als eigener Kreis | `TabView` mit Liquid Glass (iOS 26), Suche als `Tab(role: .search)` |
| Einstellungen über Knopf oben rechts in jedem Tab | Push in `NavigationStack` |
| Mediathek mit Segmenten Filme · Serien · Meine Liste | `Picker(.segmented)` |
| Im Trend als wischbares Karussell mit Rang, „Alle anzeigen“ am Ende | `ScrollView(.horizontal)` + `.scrollTargetBehavior(.paging)` |
| Live TV: Gruppen-Chips, Kanalliste; Sender gedrückt halten → Abspielen, Favorit, Programm, Ausblenden | `List` + `.contextMenu` |
| TV-Guide: eine Chip-Zeile, Raster mit fixer Senderspalte, Sendung antippen → Sheet | eigenes Raster in zwei Richtungen scrollbar, `.sheet` mit `presentationDetents` |
| Detailseiten (Film, Serie mit Staffeln, Trend mit Verfügbarkeit) | Push-Seiten |
| Player hochkant: Video oben, darunter Sendung, vorheriger Sender, Kanalliste | eigene View, `UIViewRepresentable` für VLC-View bzw. `AVPlayerLayer` |
| Player quer: Vollbild, Steuerung ein-/ausblenden, Kanalliste links, Menü rechts | Ausrichtung über `UIInterfaceOrientationMask` nur im Player |
| Gesten: tippen = Steuerung, seitlich wischen = Senderwechsel, nach unten wischen = schliessen | `DragGesture` |
| Player-Menü (Ton & Untertitel · Bild · Mehr) | Sheet hochkant, Seitenleiste quer |
| Bild-in-Bild, AirPlay | `AVPictureInPictureController`, `AVRoutePickerView` (Risiken 16, 17) |
| Senderliste bearbeiten | `List` mit `EditButton` und `.onMove` |
| „An Apple TV senden“ | `NWBrowser` (Bonjour) + gleiche lokale Schnittstelle wie die QR-Einrichtung |

Einstellungen nur auf iOS: HDR-Wiedergabe, Bild-in-Bild beim Verlassen, Mobile Daten, iCloud-Sync, Senderwechsel durch Wischen. Entfällt auf iOS: „Bildwiederholrate anpassen“ (`AVDisplayManager` gibt es nur auf tvOS) und Surround-Ton.

**Empfehlung:** zuerst tvOS fertigstellen, iOS danach als zweites Target. Universal Purchase: ein Kauf für Apple TV, iPhone und iPad.

### 8a. Umbau nach MyTVOnline+-Abläufen (02.–03.10.2026, Prototyp iPhone)

| Bereich | Neu |
|---|---|
| Start | Live-Karte 16:9 mit Titel im Bild, Meine Sender als Logo-Kacheln, Weiterschauen, Trendfilme, Trendserien (ohne Platznummern), Regale seitenweise mit Punkten |
| Live TV | öffnet die zuletzt genutzte Gruppe; Gruppen-Leiste («Gruppe · Name · Anzahl · ↕») führt zur Gruppenliste mit «Zuletzt genutzt» und Playlist-Umschalter |
| Player hochkant | Video oben, Sendungszeile (Tippen klappt das Programm auf, ersetzt einen Guide-Knopf), Gruppen-Leiste, darunter scrollt nur die Senderliste; oben Ton/Untertitel, Favorit, AirPlay, Bild-in-Bild; Mitte vorheriger/nächster Sender |
| Tab-Leiste | gleitende Markierung, schrumpft beim Runterscrollen, erneutes Tippen: Übersicht → nach oben → Gruppen |
| Detailseite | Apple-TV-Stil: grosses Bild mit stummer Trailer-Vorschau, Titel-Logo, Abspielen/Fortsetzen, Merkliste, Trailer, Folgen-Karussell, Besetzung, Ähnliches, Info |
| Bedienung | Tipp-Schutz beim Scrollen, Home-Bildschirm-Modus mit eigenem App-Symbol |

Für tvOS sinngemäss übernehmen; dort bleibt der Player im Vollbild.

## 9. Vorgehen (Meilensteine)

1. **Voraussetzungen:** Entweder ein Mac (Apple Silicon, 16 GB RAM) mit Xcode: Mit einer Gratis-Apple-ID läuft die App 7 Tage und wird dann neu installiert. Oder ohne Mac: Build in der Cloud (GitHub) und TestFlight, dafür ist das Apple Developer Program nötig (99 USD/Jahr).
2. **Player-Test:** fünf Kandidaten gemäss Abschnitt 2a (AVPlayer, MPVKit, VLCKit 4, KSPlayer, AVPlayer mit Umpacken) mit denselben eigenen Sendern und Filmen auf Apple TV 4K und iPhone. Messen: Startzeit, Umschaltzeit, Aussetzer/Neuverbindungen, Bildqualität und Deinterlacing (1080i, 720p50, 4K), Bildwiederholrate, HDR/Dolby Vision, Ton (AC3, E-AC3, DTS), Untertitel, Akku; iPhone zusätzlich Bild-in-Bild und AirPlay. Ergebnis: eine FFmpeg-Engine neben AVPlayer
3. **Live-Kern:** Playlist (M3U/Xtream), Live TV, Player, Favoriten
4. **TV-Guide:** XMLTV, Erinnerungen
5. **Mediathek:** VOD, Trends mit Abgleich, Metadaten (Anbieter-Daten + TMDB über eigenen Server, Abschnitt 2b)
6. **Einstellungen, Sprache, Erscheinungsbild**
7. **TestFlight** auf dem eigenen Apple TV
8. **iOS-Target**
9. **App Store:** Markenprüfung, Datenschutz, Review-Demo-Playlist

## 10. Was Onda von der Konkurrenz abheben soll

1. **Fundament:** Senderwechsel unter 1 Sekunde, automatisches Neuverbinden bei Abbruch, korrekte Bildwiederholrate und korrektes Deinterlacing ohne Einstellen, grosse Playlists flüssig, EPG ordnet sich selbst zu
2. **Bedienung:** wenig auf dem Bildschirm, QR-Einrichtung, Siri-Remote-Gesten, Senderliste bearbeiten, vorheriger Sender, Top Shelf
3. **Premium:** Trends mit Verfügbarkeit, Startseite wie ein TV-Anbieter, iCloud-Sync plus iOS-App, Multiview, Profile
4. **Prüfstein:** direkter Vergleich mit iPlay TV und denselben Sendern auf dem eigenen Apple TV, bevor weitere Funktionen gebaut werden

## 11. Offene Entscheidungen

- Soll Onda kostenlos, kostenpflichtig oder mit Abo erscheinen? Davon hängen die TMDB-Lizenz und das Thema Markenschutz ab.
- TMDB-Lizenz anfragen (Preis unklar) oder TheTVDB als Hauptquelle?
- Bei KSPlayer als Testsieger: LGPL-Lizenz kaufen (Preis anfragen)?
- Trends behalten, wenn die Datenquelle Kosten verursacht?
- Live pausieren behalten, wenn der Puffer auf dem Gerät nur kurz ist?
- iOS: Bild-in-Bild auch für .ts-Streams, falls die gewählte FFmpeg-Engine es nicht kann? (Dann Umpacken nach HLS.)
