# Onda – Bauplan für tvOS und iOS

Stand: 05.10.2026 · Grundlage: Prototyp 1.6 (Apple TV) bzw. 1.5 (iPhone), iOS nach MyTVOnline+-Abläufen (Artifacts „Onda“ für Apple TV und „Onda iPhone“), mit **Neutralitäts-Vorgaben (Abschnitt 2c)** und **Gesamtprüfung (Abschnitt 4e)** und **rechtlicher Prüfung (Abschnitt 4f, Details in `Rechtliches.md`)** · Status: bereit für die Swift-Umsetzung, mit den unten genannten offenen Punkten

---

## 1. Ziel und Rahmen

- Premium-IPTV-Player für Apple TV, dazu iPhone und iPad, im Look eines TV-Anbieters
- Hauptinhalt: **MPEG-TS-Streams (.ts)** über M3U oder Anbieter-Login (Xtream-API)
- Vorgaben: **maximale Bildqualität**, **möglichst keine Lizenzkosten**, App komplett auf **Deutsch und Englisch**, Erscheinungsbild **dunkel, hell oder automatisch**, **übersichtlich und minimalistisch**
- **Neutraler Player:** Onda liefert keine Inhalte, keine Quellen und keine Hilfen zum Finden von Inhalten. Positionierung: „Player für deine eigenen TV-Abos und Playlists“ (Abschnitt 2c)
- Nicht möglich und deshalb nicht vorgesehen: Replay, „Von Anfang an“, Aufnahmen, Werbung überspringen (alles anbieterseitig)

## 2. Getroffene Entscheidungen

| Thema | Entscheidung | Begründung |
|---|---|---|
| Engine für .ts und Dateien | **Testsieger aus Meilenstein 2**, Favorit **MPVKit (LGPL)**, Alternativen **VLCKit 4** und **KSPlayer (LGPL-Lizenz)** | aktuelle FFmpeg-Engines, die verbreitete Apps nutzen (Abschnitt 2a/2b). VLCKit 3 ist veraltet und nur noch Rückfall |
| Engine für HLS | **AVPlayer** | Systemplayer, beste Integration (HDR, Dolby Vision, Bild-in-Bild und AirPlay auf iOS) |
| Auswahl in der App | Automatisch · AVPlayer · zweite Engine (unter **Einstellungen › Erweitert**) | „Automatisch“: HLS → AVPlayer, alles andere → zweite Engine. **Keine weiteren Engines in der Auswahl**: Der Nutzer soll nie eine Engine wählen müssen |
| Weitere Engines | nur im Player-Test vergleichen, nicht im Produkt | siehe Abschnitt 2a |
| Deinterlacing | Automatisch (= Yadif 2x, empfohlen), Aus, Verwerfen, Überblenden, Bob, Yadif, Yadif 2x | entspricht den VLC-Modi; BWDIF gibt es in VLC 3 nicht |
| Einstellungen | **neu geordnet wie Apple/Infuse, nichts entfernt** (Entscheid Sinan, 05.10.2026; ersetzt „unverändert“ vom 02.10.2026) | oft Genutztes oben, Technik unter „Erweitert“ (Abschnitt 4e) |
| Kindersicherung | **echt umgesetzt:** PIN, gesperrte Gruppen (Entscheid Sinan, 05.10.2026) | eine Einstellung ohne Wirkung ist schlimmer als keine |
| Sprache | String Catalog (Localizable.xcstrings), Deutsch und Englisch, plus Umschalter in der App | |
| Erscheinungsbild | Dunkel · Hell · Wie Apple TV bzw. Wie iPhone | über `preferredColorScheme`; Video-Bereiche bleiben immer dunkel |
| Neutralität | **Trends nur aus der eigenen Playlist**, keine Dienst-Charts, kein Merken von nicht Verfügbarem, keine Downloads (Entscheid Sinan, 04.10.2026) | rechtliches Risiko (EuGH „Filmspeler“) und App-Review, Abschnitt 2c |
| Hilfeseite | **„Playlist einrichten“ in beiden Apps**, nur Anleitung, keine Links und keine Anbieternamen (Entscheid Sinan, 04.10.2026) | senkt den Supportaufwand und zeigt den Prüfern den legalen Zweck, ohne dass Onda Quellen vermittelt (2c, Punkt 5) |

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
2. **Ergänzung aus TMDB mit kommerzieller Lizenz** über einen **eigenen kleinen Server** (z. B. Cloudflare Worker): Schlüssel bleibt geheim, Zwischenspeicher, Anbieter später wechselbar ohne App-Update. Bilder: Poster w500/w780, Hintergründe w1280 (iPhone) bzw. original (Apple TV 4K), Titel-Logos (PNG), Trailer als YouTube-Schlüssel. Der Server bekommt nur Titel und IDs, **nie Playlist- oder Stream-URLs**, und speichert keine Anfragen pro Nutzer (Abschnitt 2c).
3. **Lizenzanfrage bei TMDB früh stellen**, sobald das Preismodell steht. Der Preis entscheidet, ob TMDB oder TheTVDB die Hauptquelle wird.

Verworfen: Schlüssel pro Nutzer (wie im Prototyp) – rechtliche Grauzone in einer Bezahl-App und umständlich.

**App Store:** siehe Abschnitt 2c. LGPL-Engines (MPVKit, VLCKit) dynamisch einbinden, Lizenzhinweis in der App (umgesetzt unter „Über Onda › Open-Source-Lizenzen“). Einschätzung, keine Rechtsberatung: vor dem Start prüfen lassen.

**Im Prototyp:** Echte Beispiel-Cover (Wikipedia, TVmaze) für die Optik, nur intern, nie in Screenshots. Mit eigenem TMDB-Schlüssel (nur Prototyp, nicht-kommerziell) zusätzlich Hintergründe, Titel-Logos, Trailer, Handlung, Besetzung und Folgen. Detailseite im Stil der Apple TV App. Die Schlüssel-Eingabe steht nur noch unter „Cover & Infos (Prototyp)“; in der fertigen App gibt es dort nichts einzustellen.

## 2c. Neutralität: rechtlich und App Store (04.10.2026)

**Warum:** Ein reiner Player ist grundsätzlich zulässig. Riskant wird es, wenn die App erkennbar darauf ausgerichtet ist, illegale Inhalte zu finden oder zu nutzen. Massstab ist das EuGH-Urteil „Filmspeler“ (C-527/15, 26.04.2017): Der Verkauf eines Players mit vorinstallierten Links zu illegalen Quellen, beworben mit „gratis schauen“, war eine Urheberrechtsverletzung ([Zusammenfassung otto-schmidt.de](https://www.otto-schmidt.de/news/wirtschaftsrecht/vertrieb-eines-mediaplayers-fur-illegales-streaming-verstosst-gegen-urheberrecht-2017-04-27.html)). Grösseres praktisches Risiko ist die Entfernung aus dem Store: Apple lehnt Streaming-Apps nach Richtlinie 5.2.3 ab, und im März 2026 wurden 36 IPTV-Apps (u. a. IPTV Smarters Pro, XCIPTV) auf Druck eines Rechteinhabers aus Google Play und App Store entfernt ([Storyboard18](https://www.storyboard18.com/ott-news/google-play-ios-purge-36-iptv-apps-with-26-million-downloads-taken-down-amid-t20-world-cup-91220.htm)).

Ziel: Niemand soll Onda nachweisen können, auf illegale Nutzung **ausgerichtet** zu sein. Ganz ausschliessen lässt sich Missbrauch bei keinem Player.

**1. Produkt (muss)**

| Bisher | Neu |
|---|---|
| Trend-Liste: Top 10 aller Dienste plus Netflix-Trends, abgeglichen gegen die Playlist („In deiner Playlist“) | **„Beliebt in deiner Mediathek“**: nur Titel aus der eigenen Playlist, sortiert nach allgemeiner Popularität (TMDB/TheTVDB). Rang, Hero und Cover bleiben. Keine Dienstnamen, keine Charts fremder Kataloge, kein Hinweis „verfügbar“ |
| „＋ Merken“ für nicht verfügbare Titel, Detailseite „Trend mit Verfügbarkeit“ | **entfällt**. Meine Liste nur für Titel aus der eigenen Playlist |
| – | **Keine Download- oder Offline-Funktion** für Filme und Serien, auch künftig nicht (direkter Ablehnungsgrund nach 5.2.3) |
| – | **Keine versteckten oder regional abweichenden Funktionen** (Apple sperrt dafür Entwicklerkonten) |

**2. Begriffe und Oberfläche**

- „Xtream Codes“ → **„Anbieter-Login“** (seit 05.10.2026 ohne Zusatz «Xtream-API» in der Oberfläche; technisch weiter unterstützt, siehe `Rechtliches.md` #11)
- „User-Agent“ unter **„Erweitert › HTTP-Header“**, nicht prominent
- Leerer Zustand: „Füge die Playlist deines TV-Anbieters hinzu“, ohne Links und ohne Anbieternamen
- Prototyp-Cover (Wikipedia, TVmaze) und echte Senderlogos nur intern, nie in Screenshots oder Marketing

**3. App-Store-Auftritt**

- Beschreibung: „Player für deine eigenen TV-Abos und Playlists“. Kein „gratis“, keine Sender, keine Ligen, kein Sport-Bezug, keine Dienstnamen
- Screenshots nur mit Testdaten und Fantasie-Sendern
- Demo-Playlist mit nachweislich legalen Streams für die Prüfer, kurze Erklärung im Feld „Notes for Review“
- Keine Anbieter-Empfehlungen, auch nicht auf Website, Social Media oder im Support

**4. Rechtliches und Betrieb**

- Nutzungsbedingungen: Nutzung nur für Inhalte mit Nutzungsrecht; Kontaktadresse für Rechteinhaber mit schneller Reaktion
- **Keine Playlist- oder Stream-URLs serverseitig speichern oder loggen**, keine Telemetrie mit Sendernamen oder Quellen. Was Onda nicht weiss, kann nicht als Wissen ausgelegt werden
- Support: keine Hilfe bei Problemen mit konkreten Anbietern
- Impressum, Datenschutzerklärung, LGPL-Hinweise (Platzhalter in den Prototypen unter „Über Onda“)
- Vor dem Start: eine Beratung bei einer Anwältin bzw. einem Anwalt für Urheber- und IT-Recht (CH und EU), zusammen mit der Markenprüfung „Onda“

**5. Hilfeseite „Playlist einrichten“ (Entscheid Sinan, 04.10.2026, umgesetzt)**

Erreichbar über **Einstellungen › Playlists › „Hilfe: Playlist einrichten“** (direkt unter „＋ Playlist hinzufügen“) und über „Wo bekomme ich eine Playlist? ›“ im Formular „Playlist hinzufügen“. Inhalt, nur als Anleitung:

- **Was du brauchst:** M3U-Adresse oder Anbieter-Login (Server, Benutzername, Passwort), optional TV-Guide-Adresse (XMLTV)
- **Woher die Playlist kommt:** eigener TV- oder Internetanbieter (Kundenkonto), Gerät im Heimnetz, das Kabel, Satellit oder Antenne als Playlist bereitstellt, eigener Medienserver
- **So fügst du sie hinzu:** tvOS per QR-Code oder Fernbedienung, iOS per Formular und „An Apple TV senden“
- **Wenn etwas nicht klappt:** Playlist lädt nicht (Zugangsdaten, User-Agent unter Erweitert), keine Sendungsdaten (TV-Guide-Quelle), Bild ruckelt (Engine und Deinterlacing auf Automatisch)
- **Gut zu wissen:** Onda enthält keine Sender und empfiehlt keine Anbieter; nur Inhalte mit Nutzungsrecht; bei Fragen zu Sendern hilft der Anbieter
- Schluss-Knopf „＋ Playlist hinzufügen“

**Regeln:** keine Links, keine Anbieter- oder Gerätenamen, keine mitgelieferten Streams – sonst wird Onda selbst zum Vermittler von Inhalten. Konkrete Beispiele (z. B. Anbieter mit offizieller M3U-Playlist) höchstens im Feld „Notes for Review“ für die Prüfer, nicht in der App.

**Unverändert (USP):** Senderwechsel unter 1 s, automatische Bildwiederholrate und Deinterlacing, EPG mit Auto-Zuordnung, QR-Einrichtung, Minimal-UI, Senderliste bearbeiten, Detailseiten mit Metadaten, iCloud-Sync, iOS-App.

**Umgesetzt in den Prototypen (04.10.2026, beide Apps):** Start zeigt „Beliebte Filme“ und „Beliebte Serien“ nur aus der eigenen Playlist, mit Rang und „Alle anzeigen“ (Liste mit Hinweis auf die Sortierung). „＋ Merken“, Trend-Detailseite und Netflix/FlixPatrol-Texte sind entfernt; Meine Liste enthält nur eigene Titel. „Anbieter-Login (Xtream-API)“ statt „Xtream Codes“ (gespeicherte Playlists werden umbenannt), User-Agent unter „Erweitert (HTTP-Header)“, Formular beginnt mit „Füge die Playlist deines TV-Anbieters hinzu“. Unter „Über Onda“ steht „Onda enthält keine Inhalte“. Hilfeseite „Playlist einrichten“ (Punkt 5) in beiden Apps. Die Beliebtheit ist im Prototyp simuliert. Geprüft im Browser, Deutsch und Englisch, ohne Skriptfehler.

Einschätzung, keine Rechtsberatung.

## 3. Architektur

Ein gemeinsames Swift Package **OndaCore** für tvOS und iOS, darüber zwei schlanke App-Targets.

```
OndaCore (Swift Package)
├── Models          Channel, Group, Programme, Movie, Series, Episode, Playlist, PopularItem
├── Playlist        M3U-Parser (zeilenweise, streamend), Xtream-API-Client
├── EPG             XMLTV-Parser (SAX/XMLParser, streamend), gz-Entpacken, Zeitzonen, Zeitversatz pro Playlist
├── Matching        Titel-Normalisierung + Index (eigene Playlist ↔ Metadaten/Popularität)
├── Popularity      Popularitätswerte aus der Metadaten-Quelle, nur für Titel der eigenen Playlist; keine Dienst-Charts (2c)
├── Metadata        Anbieter-Daten + TMDB über eigenen Server (nur Titel/IDs, keine URLs), Cache 7 Tage, Bildgrössen je Gerät
├── Storage         SQLite/SwiftData im Caches-Ordner, iCloud für Favoriten/Einstellungen/Senderliste, Keychain für Zugangsdaten und PIN
├── ParentalControl PIN (Keychain), gesperrte Gruppen, Entsperrung bis App-Ende; wirkt als Filter auf alle Senderlisten
├── Player          Protokoll PlayerEngine + AVPlayerEngine + FFmpeg-Engine (Testsieger), Stream-Analyse, vorheriger Sender, bevorzugte Ton-/Untertitelsprache
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
- **Bild im Player-Menü** (Bildformat, Deinterlacing) gilt nur für die laufende Wiedergabe; der Standard kommt aus den Einstellungen.
- **Ton/Untertitel:** beim Start nach „Bevorzugte Tonsprache“ und „Untertitel“ vorwählen (Sprachcode der Spur), im Player pro Wiedergabe änderbar.

### Einrichtung per QR-Code (ohne Server, ohne Kosten)

1. Das Apple TV startet beim Öffnen von „Playlist hinzufügen“ einen kleinen Webserver im Heimnetz (`NWListener` aus dem Network-Framework).
2. Der QR-Code enthält die lokale Adresse und einen Einmal-Code, z. B. `http://192.168.1.42:8080/setup?code=7H8F-6WWV`.
3. Das iPhone öffnet die Seite in Safari, ohne App. Dort gibt man M3U-URL oder Anbieter-Login (Xtream-API), EPG-URL und unter „Erweitert“ HTTP-Header (User-Agent) ein.
4. Die Daten gehen direkt ans Apple TV. Sie landen dort im Keychain, danach stoppt der Webserver. Der Code verfällt nach etwa 10 Minuten. **Die neue Playlist ist sofort aktiv.**
5. Die iOS-App von Onda findet das Apple TV per Bonjour (`NWBrowser`) und überträgt eine gespeicherte Playlist ganz ohne QR-Code („An Apple TV senden“, im iPhone-Prototyp gezeigt).

### Senderliste bearbeiten

- Ausgeblendete Gruppen und Sender sowie die eigene Reihenfolge werden pro Playlist gespeichert, und zwar über einen **stabilen Schlüssel** (tvg-id, sonst Name plus Gruppe), nicht über die Position. So bleibt die Anpassung erhalten, wenn der Anbieter die Playlist aktualisiert.
- tvOS: OK blendet ein oder aus. ⏯ (Play/Pause) startet das Verschieben, dann ▲ ▼ und OK zum Ablegen.
- iOS: Schalter pro Gruppe und Sender, Sortieren per Ziehen (`.onMove`). Zusätzlich „Ausblenden“ direkt im Kontextmenü eines Senders.
- Bei aktiver Kindersicherung nur nach PIN-Eingabe.

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
10. **Vorheriger Sender.** tvOS: **2× OK** im Live-Player (auch über Player-Sitzungen hinweg); ◀ öffnet die Kanalliste mit Fokus auf dem vorherigen Sender; zusätzlich Player-Menü „Mehr“. Die Info-Leiste zeigt den Hinweis. iOS: Knopf ↩ im Player.

## 3b. Fokus und Fernbedienung in Swift

- Jede Spalte bzw. jeder Bereich ist eine eigene `.focusSection()` und merkt sich das zuletzt fokussierte Element (`@FocusState`, `.defaultFocus`). Der Prototyp bildet das nach. So springt ◀ aus der Vorschau in die Kanalliste statt in die Gruppen.
- **Tab-Leiste nur über ▲ vom oberen Inhaltsrand;** ◀/▶ aus Inhalten springen nie in die Tabs, und ◀/▶ verlassen eine Zeile nur in einen anderen Fokusbereich (keine Schrägsprünge in andere Regale). ▼ aus der Tab-Leiste landet auf dem zuletzt fokussierten Element bzw. einem festen Einstieg pro Ansicht (`.defaultFocus`).
- **TV-Guide:** ◀/▶ bleiben in der Senderzeile und blättern am Rand eine Stunde weiter; ▲/▼ halten die Zeitposition.
- Beim Wechsel zurück in einen Tab bleibt die Position erhalten.
- Auswahl folgt dem Fokus nur verzögert (ca. 150 ms), damit beim schnellen Durchscrollen nichts neu geladen wird.
- Fernbedienung: `onMoveCommand`, `onPlayPauseCommand`, `onExitCommand`. Es gibt keine Live-Taste, deshalb heisst „Zurück zu Live“: ▶ bei zeitversetzter Wiedergabe. Auf dem Clickpad Wischen und Klicken unterscheiden, damit versehentliches Wischen nicht den Sender wechselt.

## 4. Bildschirme tvOS (Prototyp → Swift)

| Prototyp | tvOS-Umsetzung |
|---|---|
| Tab-Leiste: Start, Live TV, TV-Guide, Mediathek, Suche (Symbol), Einstellungen (Symbol) | `TabView` (oben, Liquid Glass ab tvOS 26), Suche als `Tab(role: .search)` |
| Start: „Jetzt live“ (Titel, Sender, Zeit, ein Knopf), Meine Sender (Favoriten + zuletzt gesehen), Weiterschauen (setzt direkt fort), **Beliebte Filme / Beliebte Serien** (nur eigene Playlist, mit Rang, 2c) | `ScrollView` + `LazyHStack`-Regale, `.focusSection()` |
| Live TV: Gruppen · Kanalliste · Vorschau, ohne Zähler und Spaltentitel, Qualität nur bei 4K; gesperrte Gruppen mit 🔒 | drei Spalten, Vorschau mit kleinem Player (stummgeschaltet) |
| TV-Guide: eine Chip-Zeile mit Tag (Heute ⇄ Morgen), Jetzt, 20:15 und Gruppen; Raster mit Jetzt-Linie | eigenes Raster-Layout, horizontal virtualisiert |
| Mediathek: Filme · Serien · Meine Liste (nur Filme und Serien); Hero + Playlist-Regale (Alle, Neueste, Kategorien) | Regale mit `.buttonStyle(.card)` |
| Detailseiten: ein Hauptknopf, Favorit als Symbol; Serien öffnen bei der Staffel mit Fortschritt, gesehene Folgen ✓, aktuelle mit Balken | eigene Views |
| Player: Info-Leiste mit Hinweis (◀ Senderliste · ▶ Menü · 2× OK vorheriger Sender), Kanalliste (◀), Player-Menü (▶ / ▼) | eigener Player-Overlay (nicht `AVPlayerViewController`, da VLC) |
| Player-Menü mit vier Reitern: Ton & Untertitel · Bild (nur diese Wiedergabe) · Mehr (vorheriger Sender, Sleep-Timer) · Info (Stream-Details, durchscrollbar) | Overlay mit Tabs |
| Einstellungen: links App-Symbol, rechts eine Liste (Abschnitt 4e) | `List` + eigene Auswahl-Sheets, wie die tvOS-Einstellungen |
| Playlist hinzufügen: QR-Code (Standard), M3U, Anbieter-Login (Xtream-API), Erweitert (HTTP-Header), Link zur Hilfe; „Nur speichern“ mit Pflichtfeld-Prüfung | Sheet; QR über `CIFilter.qrCodeGenerator` |
| Playlist-Blatt: Quelle (URL bzw. Server/Benutzer/Passwort), Automatisch aktualisieren, TV-Guide-Quelle, Zeitversatz, Name, User-Agent, Speichern, Verwenden, Entfernen (mit Bestätigung) | Sheet |
| Kindersicherung: PIN-Ziffernblock, Blatt „Gesperrte Gruppen“ | eigene Views, PIN im Keychain |
| Hilfe „Playlist einrichten“: fünf Karten, mit ▲▼ durchblättern, Knopf „＋ Playlist hinzufügen“ | Sheet mit `ScrollView` und fokussierbaren Abschnitten |
| Senderliste bearbeiten: zwei Spalten, ein-/ausblenden, verschieben | eigene Ansicht mit Verschiebe-Modus |

## 4a. Minimal-Umbau (02.10.2026, beide Apps)

Ziel: übersichtlicher, weniger Information auf dem Bildschirm, gleiche Funktionalität. (Die Einstellungen wurden damals bewusst nicht angefasst; seit 05.10.2026 neu geordnet, siehe 4e.)

| Bereich | Entfernt | Neu oder geändert |
|---|---|---|
| Navigation (tvOS) | 8 Tabs | 4 Tabs + Suche und Einstellungen als Symbole; Filme, Serien und Favoriten liegen in der Mediathek |
| Start | Qualitäts-Etikett, „Danach“, TV-Guide-Knopf im Banner, Reihe „Zuletzt gesehen“ | „Meine Sender“ = Favoriten + zuletzt gesehen |
| Live TV | Zähler, Spaltentitel bzw. Zeile „Schweiz · 14 Kanäle“, FHD/HD/SD-Etiketten, TV-Guide-Knopf in der Vorschau, Stern in jeder Zeile (iOS) | nur 4K bleibt sichtbar; iOS: Sender gedrückt halten → Abspielen, Favorit, Programm, Ausblenden |
| TV-Guide | zweite Chip-Zeile, Zeitsprünge 06:00/12:00/18:00/22:00 | eine Zeile: Heute ⇄ Morgen, Jetzt, 20:15, Gruppen |
| Mediathek | getrennte Reihen „Aktuell im Trend“ und „Top 10“, Filter-Chip, Quellenhinweis, Zeile „Mein Anbieter · 21 Filme“, FHD auf Postern | ~~eine Trend-Liste (Top 10 aller Dienste, ergänzt um Netflix-Trends)~~ → **ersetzt durch „Beliebt in deiner Mediathek“ (2c)**; Rang auf der Karte bleibt |
| Detail | Eyebrow „Film · Im Trend“, technische Zeile „Gefunden als …“ | ein Hauptknopf, Favorit als Symbol; ~~„＋ Merken“ für nicht Verfügbares~~ → **entfällt (2c)** |
| Player | iOS: vier Kacheln und Qualitäts-Etiketten unter dem Video | Menü mit Reitern; Vorheriger Sender; iOS hochkant nur das wichtigste Qualitäts-Etikett (gemäss Einstellung „Qualitäts-Anzeige“) |

## 4b. Review-Umsetzung (03.10.2026, beide Apps)

- **Weiterschauen:** Fortschritt wird gespeichert (beim Stoppen, alle 15 s). Ab 95 % gilt ein Film als gesehen bzw. springt die Serie zur nächsten Folge. Einstellung «Fortsetzen»: Fortsetzen oder von vorne / Immer fortsetzen / Immer von vorne.
- **Zeitversatz** wirkt auf das EPG (Anzeige und Fortschritt), seit 05.10.2026 pro Playlist in 30-Minuten-Schritten (−3 h bis +3 h).
- **Mediathek:** «Alle Filme/Serien», «Neueste», Kategorie-Reihen mit «Alle N ›» und Raster (sortierbar Neueste/A–Z, nachladen in 60er-Schritten). Beliebt-Reihen nur auf Start.
- **TV-Guide:** Gruppenwahl wie bei Live TV.
- **EPG-Quelle pro Playlist:** Automatisch (Xtream xmltv.php) / Eigene URL / Datei, im Playlist-Editor.
- **Schnellstart + Refresh-Intervall:** Die geparste Playlist liegt im Cache (IndexedDB), der Start lädt nicht neu. «Automatisch aktualisieren» pro Playlist: Bei jedem Start / Täglich / Alle 3 Tage (Standard) / Alle 7 Tage / Nur manuell. Ist ein Update fällig und der automatische Abruf nicht möglich, erscheint ein Hinweis auf Start.
- **EPG-Zuordnung (Fix):** Mehrere Sender mit derselben tvg-id (HD/SD/Backup, Länder-Gruppen) bekommen alle die Sendungen; Gross-/Kleinschreibung und Leerzeichen egal; ohne oder mit falscher tvg-id greift der Name. Gespeichert wird pro EPG-Kanal einmal (Format v2). Die Playlist zeigt «x von y Sendern» und listet Sender ohne Daten.
- **Einstellungen entflochten:** Alles zu Quelle und Aktualisierung liegt bei der Playlist (Status, Quelle, TV-Guide-Quelle, Zeitversatz, Aktualisierung, Erweitert).
- **Einheitliche Anzeige:** Ohne Sendungsdaten steht überall «Keine Sendungsdaten» (nicht mehr Gruppe/Land). Start zeigt bevorzugt einen Sender mit EPG.

## 4c. Metadaten-Strategie (Cover, Infos) für den Verkauf

1. **Primär: Daten des Anbieters** über Xtream `get_vod_info` / `get_series_info` (Cover, Backdrop, Handlung, Besetzung, Bewertung, tmdb_id). Kostenlos, keine eigene Lizenz nötig, gängige Praxis.
2. **Ergänzung: TheTVDB** (kommerziell gratis unter 50'000 USD Umsatz/Jahr, mit Attribution; darüber 1'000 USD/Jahr). Stärker bei Serien.
3. **TMDB nur mit Vertrag** (kommerziell = Lizenz nötig; Preis nicht öffentlich, Sekundärquelle nennt ca. 149 USD/Monat – unbestätigt). Offerte anfragen, bevor gerechnet wird. Kein Modell «Nutzer bringt eigenen Key» als Standard (Grauzone).
**Umgesetzt im Prototyp (03.10.2026, beide Apps):** Kette Anbieter → TheTVDB → TMDB, jede Quelle füllt nur, was fehlt. Anbieter: `get_vod_info` pro Film, `get_series` (einmal, gecacht nach Aktualisierungs-Intervall) + `get_series_info` mit Folgen. TheTVDB v4: Login mit Projekt-Schlüssel, Suche + `extended` (Übersetzung, Hintergrund, Besetzung, Trailer). Quellenangabe je Titel unten in der Detailseite und unter „Über Onda › Quellenangaben“ (inkl. TMDB-Pflichthinweis). Einstellungen › «Cover & Infos (Prototyp)» zeigt Status der drei Quellen. Im Browser-Prototyp blockiert ein http-Anbieter den Abruf – die native App nicht.

4. Ausgeschlossen: OMDb (nicht kommerziell), IMDb (zu teuer), Watchmode (zu teuer), Wikimedia-Poster (meist nicht frei).

Metadaten werden nur für Titel geladen, die in der eigenen Playlist stehen (2c).

## 4d. Design-Review (04.10.2026, Referenz: Apple TV, Netflix, blue TV, Sunrise TV, MyTV Online)

- **Erster Start:** Live TV und TV-Guide öffnen «Alle Kanäle» statt der ersten (oft kleinen) Gruppe; leere Favoriten fallen auf «Alle Kanäle» zurück.
- **Detailseiten:** Titel in Systemschrift (fett) statt Zierschrift; keine Einrichtungs-Hinweise mehr auf Detailseiten (nur in Einstellungen); Gruppen wie «SERIEN» nicht mehr als Genre; tvOS: kein «0 Min.» / «seit null», kein Platzhaltertext als Beschreibung, «Ähnliches in deiner Playlist» auch bei Filmen.
- **Begriffe vereinheitlicht:** «Meine Liste» nur für Filme und Serien; «Favoriten» nur für Sender (seit 05.10.2026 keine Senderfavoriten mehr in Mediathek › Meine Liste).
- **Langes Drücken auf Film/Serie (iOS):** Abspielen/Fortsetzen, Details, Meine Liste, Aus «Weiterschauen» entfernen – wie bei Netflix/Apple TV.
- **Platzhalter-Cover:** Titel werden nicht mehr mitten im Wort getrennt, Schrift passt sich an.
- **TV-Guide:** Sendungstitel bleiben beim seitlichen Scrollen links sichtbar.
- **Suche:** Feld ist beim Öffnen aktiv, «Zuletzt gesucht», Vorschläge aus der eigenen Playlist, einheitliche Überschriften.
- **Heller Modus:** Detailkopf mit dunkler Schrift statt weiss auf hell.

## 4e. Gesamtprüfung (05.10.2026, beide Apps)

Vorgehen: zwei unabhängige Prüfer (je einer pro App) testeten alle Bildschirme in Deutsch/Englisch und hell/dunkel; danach Umbau, anschliessend eine zweite unabhängige Prüfrunde und Korrektur der dort gefundenen Punkte.

**Einstellungen – neue Struktur (nichts entfernt, Entscheid Sinan)**

| Gruppe | Apple TV | iPhone |
|---|---|---|
| Playlists | Playlists (aktive markiert), ＋ Playlist hinzufügen, Hilfe | dazu „An Apple TV senden“ |
| Live TV | Senderliste bearbeiten, Senderwechsel mit ▲ ▼, Beim Start öffnen (Start, Live TV, TV-Guide, Mediathek, **Letzter Sender**) | Senderwechsel durch Wischen (Schalter), Beim Start öffnen |
| Wiedergabe | Fortsetzen, **Bevorzugte Tonsprache**, **Untertitel** | dazu Bild-in-Bild automatisch (Schalter), Mobile Daten |
| Video & Audio bzw. Bild | Bildwiederholrate anpassen, Dynamikbereich anpassen, Bildformat, Surround-Ton | HDR-Wiedergabe (Schalter), Bildformat, Qualitäts-Anzeige |
| Darstellung | Erscheinungsbild, Sprache, Qualitäts-Anzeige | Erscheinungsbild, Sprache |
| Kindersicherung | Ein/Aus, Gesperrte Gruppen, PIN ändern | gleich (Schalter) |
| iCloud & Backup | – | iCloud-Sync (Schalter), Backup sichern, Backup wiederherstellen |
| Erweitert | Player-Engine, Hardware-Decoding, Live-Puffer, Deinterlacing | gleich (Hardware-Decoding als Schalter) |
| Cover & Infos (Prototyp) | Anbieter, TheTVDB, TMDB | gleich |
| Über Onda & Rechtliches | Onda enthält keine Inhalte, Impressum, Datenschutzerklärung, Nutzungsbedingungen, Hinweise für Rechteinhaber, Open-Source-Lizenzen, Quellenangaben und Marken, Version; zusätzlich Knopf «Über Onda & Rechtliches ›» links unter dem App-Symbol | gleich, dazu Trailer-Vorschau (Standard Aus) |

Pro Playlist (nicht mehr global): Quelle (URL bzw. Server/Benutzer/Passwort, bearbeitbar), Automatisch aktualisieren, TV-Guide-Quelle, Zeitversatz, Name, User-Agent. Zeilen zeigen nur noch den Wert; Erklärungen stehen im Auswahlfenster bzw. als kurze Fusszeile unter der Gruppe. Ja/Nein auf dem iPhone als Schalter.

**Behobene Fehler (Auswahl)**

| Bereich | Vorher | Jetzt |
|---|---|---|
| Fokus (tvOS) | ▲ aus Regalen sprang in die Tab-Leiste und übersprang Regale; ◀/▶ sprangen schräg in andere Regale oder Tabs; Fokusverlust nach Suchvorschlag, Speichern, Löschen; Suche per ▼ nicht erreichbar | Tabs nur über ▲ vom oberen Rand; ◀/▶ nur innerhalb der Zeile oder in einen anderen Bereich; fester Einstieg pro Ansicht; kein Fokusverlust |
| TV-Guide (tvOS) | ◀/▶ wechselten die Zeile, Blättern sprang zurück (Endlosschleife), ◀ am Anfang landete in den Chips | bleibt in der Zeile, blättert stundenweise vor/zurück, ▲/▼ halten die Zeit |
| Playlist entfernen | Liste aktualisierte sich nicht, danach Skriptfehler (tvOS); Browser-Dialog | eigenes Bestätigungsblatt, Liste und Fokus korrekt |
| Playlist-Formular (iOS) | EPG-URL und User-Agent gingen beim Laden verloren | alle Felder werden übernommen; „Nur speichern“ mit Pflichtfeld-Prüfung (beide Apps) |
| QR-Einrichtung (tvOS) | neue Playlist inaktiv | sofort aktiv |
| Zeitversatz/Aktualisierung | auf der Playlist-Seite, wirkten aber global; nur ±1 h | pro Playlist, −3 h bis +3 h in 30-Min.-Schritten |
| Player-Menü „Bild“ | änderte die globale Einstellung dauerhaft | gilt nur für die laufende Wiedergabe |
| Player-Menü „Info“ (tvOS) | Stream-Details abgeschnitten, nicht erreichbar | eigener Reiter, durchscrollbar |
| Querformat (iOS) | Gruppe in der Kanalliste nicht wechselbar | Gruppen-Chips in der Kanalliste |
| Tabs (iOS) | Tab-Wechsel verwarf geöffnete Seiten; Tab-Leiste von Unterseiten verdeckt | jeder Tab behält seinen Seitenstapel, Tab-Leiste immer bedienbar |
| Serien | öffneten immer Staffel 1, Folgen ohne Status | aktuelle Staffel, gesehene Folgen ✓, aktuelle mit Balken |
| Fortschritt | Detailseite/Regale nach dem Player veraltet | werden neu gezeichnet |
| Kindersicherung | ohne Funktion | echt umgesetzt (siehe unten) |
| Englisch | viele deutsche Reste (Einstellungen, Blätter, Dauer, «bis 12:45», «F3») | systematisch gescannt und ergänzt |
| Kontrast/Tippziele | Hinweistexte 2,4–3,4:1, LIVE-Badge 3,3:1, Tippziele ab 17 pt | Farben angehoben, Tippflächen vergrössert |

**Neu**

- **Kindersicherung:** vierstellige PIN (zweimal bestätigen), gesperrte Gruppen. Gesperrte Gruppen erscheinen in Live TV mit 🔒, ihre Sender sind ohne PIN unsichtbar (auch Suche, TV-Guide, Start, Favoriten). PIN entsperrt bis zum Beenden der App. Ausschalten, PIN ändern und Senderliste bearbeiten verlangen die PIN.
- **Playlist bearbeiten:** URL bzw. Server/Benutzer/Passwort direkt änderbar.
- **Bevorzugte Ton- und Untertitelsprache**, beim Start jeder Wiedergabe vorgewählt.
- **Beim Start öffnen › Letzter Sender** (startet direkt den Player).
- **Vorheriger Sender mit 2× OK** (tvOS), ◀-Liste mit Fokus auf dem vorherigen Sender.
- **Weiterschauen setzt direkt fort** (Details über die Detailseite bzw. langes Drücken).
- **Über Onda & Rechtliches:** sieben Seiten (Abschnitt 4f) – Texte sind Entwürfe bis zur anwaltlichen Prüfung.

## 4e-1. Mini-Player und Bild-in-Bild (iPhone, Prototyp 1.5, 05.10.2026)

Zwei getrennte Wege, wie bei YouTube bzw. Apple:

- **Mini-Player (in der App):** Video nach unten ziehen (folgt dem Finger, wird kleiner) oder Pfeil ⌄ oben links → Leiste über der Tab-Leiste mit Vorschaubild, Sender bzw. Titel, Sendung, Fortschritt, ⏯ und ✕. Antippen oder nach oben wischen = wieder gross; nach unten oder seitlich wischen bzw. ✕ = beenden. Man kann dabei frei durch Start, Live TV, TV-Guide und Mediathek navigieren. Kurzes Ziehen federt zurück. Im Querformat: nach unten wischen dreht zurück und verkleinert.
- **Bild-in-Bild (System):** ▣ öffnet das echte Bild-in-Bild-Fenster von iOS, das auch ausserhalb der App bleibt; mit «Bild-in-Bild automatisch» beim Verlassen der App, soweit unterstützt. Nach dem Schliessen des System-Fensters erscheint der Mini-Player. Wo das System-Fenster nicht verfügbar ist (z. B. im Artifact-Fenster auf claude.ai), öffnet ▣ den Mini-Player.
- **Geändert:** Nach unten wischen beendet die Wiedergabe nicht mehr, sondern verkleinert sie (wie bei YouTube). Beenden: ✕ im Mini-Player.
- **Grenze des Prototyps:** Ob Safari das System-Fenster im Hintergrund weiter aktualisiert und ob «automatisch» in der Home-Bildschirm-Version greift, ist **unklar** und muss auf dem iPhone getestet werden.
- **Swift:** Mini-Player als eigener Zustand über dem `TabView` (z. B. `safeAreaInset(edge: .bottom)` bzw. `tabViewBottomAccessory` ab iOS 26, mit `matchedGeometryEffect` für den Übergang); System-Bild-in-Bild über `AVPictureInPictureController` mit `canStartPictureInPictureAutomaticallyFromInline` (AVPlayer), für die FFmpeg-Engine siehe Risiko 16.

## 4f. Rechtliche Prüfung «Über Onda» (05.10.2026, Prototyp 1.6 bzw. 1.4)

Vollständige Befunde (22 Punkte, Muss/Sollte/Persönlich, mit Quellen) in [`Rechtliches.md`](Rechtliches.md). Umgesetzt in beiden Apps:

- **Über Onda & Rechtliches** mit sieben Seiten: Onda enthält keine Inhalte, Impressum (Platzhalter), Datenschutzerklärung (DSG/DSGVO, 12 Punkte), Nutzungsbedingungen (Ergänzung zur Apple-EULA), Hinweise für Rechteinhaber, Open-Source-Lizenzen (LGPL-Quellcode-Angebot), Quellenangaben und Marken (TMDB-Pflichtsatz)
- Erreichbar über **Einstellungen › Über Onda & Rechtliches**; auf Apple TV zusätzlich als Knopf links unter dem App-Symbol (Impressum in wenigen Schritten, DDG)
- **Trailer-Vorschau (iPhone)** als Einstellung, Standard **Aus**: kein YouTube-Abruf ohne Zutun (TDDDG § 25)
- «Anbieter-Login» ohne «Xtream» in der Oberfläche
- Kindersicherung mit Hinweis «Ein Hilfsmittel, kein vollständiger Schutz»

Offen vor dem Start: Händlerangaben (DSA, Adresse öffentlich), Platzhalter füllen, Server ohne Protokolle, Auslandsbekanntgabe je Empfänger, TMDB-Lizenz und offizielles Logo, TheTVDB-Wortlaut, LGPL-Prüfung des konkreten Builds, Altersfreigabe, Arbeitsvertrag/AHV/Steuern. Einschätzung, keine Rechtsberatung.

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

Nach dem Neutralitäts-Umbau (04.10.2026): 1'500 zufällige Fernbedienungs-Eingaben (tvOS) und 400 zufällige Taps (iOS) ohne Skriptfehler. Nach Einbau der Hilfeseite nochmals gleich viele, ebenfalls ohne Skriptfehler.

Gesamtprüfung 05.10.2026 (Prototyp 1.5 bzw. 1.3): erste Prüfrunde rund 30 Befunde, alle umgesetzt; zweite unabhängige Prüfrunde 29 Befunde (davon 3 schwer), die relevanten umgesetzt. Abschluss: Regressionstests aller Abläufe (Einstellungen, Kindersicherung, Playlists, Fokus, TV-Guide, Player, Serien, Hilfe) plus Zufallstests mit 2'500 Fernbedienungs-Eingaben (tvOS) und 500 Taps (iOS), ohne Skriptfehler; die Prüfer kamen zusätzlich auf rund 3'700 bzw. 2'600 Zufallsaktionen ohne Skriptfehler.

**Bewusst offen gelassen (klein):** aria-Beschriftungen nur teilweise übersetzt (in Swift automatisch über den String Catalog); im hellen Modus ist die Uhrzeit der iPhone-Statusleiste auf dunklen Detailbildern schwach lesbar (in iOS regelt das `preferredStatusBarStyle`); einige Kontraste im hellen Modus knapp unter 4,5:1 (Stern, Prototyp-Badge).

Bewusste Vereinfachungen im Prototyp (in Swift richtig lösen):

- Alle Daten sind Testdaten. Streams, EPG, Statistiken und Beliebtheit sind simuliert, die Abgleich-Logik ist aber echt und übertragbar.
- Die Übersetzung erfolgt im Prototyp beim Anzeigen. In Swift wird das ein String Catalog.
- Die Fokussteuerung ist nachgebaut. Die tvOS Focus Engine verhält sich anders und muss auf dem Gerät feinjustiert werden.
- Gespeichert wird im Browser. tvOS garantiert keinen dauerhaften lokalen Speicher, siehe Risiken. Die beiden Prototypen teilen keine Daten. Die PIN liegt im Prototyp im Browser-Speicher, in Swift im Keychain.
- Nur als Oberfläche vorhanden, ohne Funktion: Mobile Daten, iCloud-Sync, Bild-in-Bild automatisch (iOS). Diese müssen in Swift umgesetzt werden.
- Übersetzung: In Swift einen String Catalog mit Pluralregeln verwenden. Inhalte des Anbieters (Titel, Sender, Playlist-Namen) werden nie übersetzt.
- iOS: Sortieren der Senderliste mit Pfeilen statt Ziehen; Kamera-Scan des QR-Codes nur als Hinweis.

## 6. Technische Risiken und offene Punkte

| # | Risiko | Massnahme |
|---|---|---|
| 1 | **Unverschlüsselte http-Streams und -Playlists** (bei IPTV üblich) | `NSAllowsArbitraryLoadsForMedia` reicht nur für AVFoundation. VLC und die Playlist-Abrufe brauchen `NSAllowsArbitraryLoads` mit Begründung in der App-Review ([Apple-Forum](https://developer.apple.com/forums/thread/83834)) |
| 2 | **Speicher auf tvOS** wird vom System geleert | Playlist und EPG im Caches-Ordner, jederzeit neu ladbar. Favoriten und Einstellungen in iCloud, Zugangsdaten und PIN im Keychain |
| 3 | **EPG-Grösse** (oft > 50 MB, gezippt) | streamend parsen, nur ±2 Tage behalten, Zeitzonen und Sommerzeit aus XMLTV korrekt umrechnen |
| 4 | **Live pausieren** mit VLC | Puffer nur wenige Minuten. Auf dem Gerät prüfen, sonst entfernen |
| 5 | **Senderwechsel-Tempo** mit VLC bei .ts | Puffer klein halten, auf dem Gerät messen. Vergleich gemäss Abschnitt 2a |
| 6 | **LGPL-Pflichten (MPVKit, VLCKit)** | als dynamisches Framework einbinden, Lizenzhinweis in der App (vorgesehen unter „Über Onda“), Quellcode-Hinweis. Kurz rechtlich prüfen |
| 7 | **Metadaten und Popularität:** TMDB ist nur für nicht-kommerzielle Nutzung kostenlos | kommerzielle Lizenz anfragen, Anbieter-Daten zuerst, TheTVDB als Alternative (Abschnitt 2b) |
| 8 | **App-Review bei IPTV-Apps** ist streng (Richtlinie 5.2.3) | Massnahmen gemäss Abschnitt 2c: keine Inhalte, kein „gratis“, Demo-Playlist mit legalen Streams, Screenshots mit Testdaten, keine Downloads, Hilfeseite ohne Links |
| 9 | **Markenrecht „Onda“** | Swissreg, DPMA und EUIPO vor dem Launch prüfen, Namen in App Store Connect reservieren |
| 10 | **Bildqualität** VLC vs. Infuse-Niveau | Vergleich mit eigenen Sendern (1080i, 720p50, 4K) auf Apple TV 4K |
| 11 | **Lokaler Webserver für die QR-Einrichtung** | prüfen, ob tvOS eine Freigabe für das lokale Netzwerk verlangt (Info.plist-Begründung). Falls der Server nicht möglich ist: Ausweichen auf die iOS-App |
| 12 | **Einstellungen „Bildwiederholrate/Dynamikbereich anpassen“** | die App kann den Modus nur anfordern. Er greift nur, wenn am Apple TV „Inhalt anpassen“ aktiv ist. Das steht als Fusszeile unter „Video & Audio“ |
| 13 | **Surround-Ton** | Dolby Digital wird nach Systemeinstellung weitergegeben. DTS kann das Apple TV nicht als Bitstream ausgeben, VLC wandelt es in PCM um (auf dem Gerät prüfen) |
| 14 | **Zeitversetzt/Pause bei Live** | VLC braucht dafür einen Zwischenspeicher, AVPlayer kann nur im Zeitfenster der HLS-Playlist zurück. Auf dem Gerät prüfen |
| 15 | **QR-Einrichtung über unverschlüsseltes http im Heimnetz** | Einmal-Code mit kurzer Gültigkeit. Sicherer über die iOS-App (verschlüsselte Verbindung per Bonjour) |
| 16 | **Bild-in-Bild mit der FFmpeg-Engine (iOS)** | AVPlayer kann es sicher, VLCKit 4 laut Projekt, KSPlayer ja, MPVKit eingeschränkt. Im Player-Test prüfen; sonst Umpacken nach HLS (2a) |
| 17 | **AirPlay mit VLC (iOS)** | Bild und Ton sicher nur mit AVPlayer. Mit VLC vermutlich nur Ton oder Bildschirmsynchronisierung ([VLCKit-Ticket](https://code.videolan.org/videolan/VLCKit/-/issues/624), ohne klare Antwort). Auf dem Gerät testen |
| 18 | **Hintergrund und Mobilfunk (iOS)** | Bild-in-Bild und Ton im Hintergrund brauchen `UIBackgroundModes: audio` und `AVAudioSession(.playback)`. Einstellung „Mobile Daten“ mit `NWPathMonitor` umsetzen |
| 19 | **Langes Drücken (iOS)** ist schlecht auffindbar | Hinweis im leeren Zustand von „Meine Liste“ und Favoriten; in Swift `.contextMenu` verwenden, dann zeigt iOS die Vorschau und das Menü wie gewohnt |
| 20 | **Haftung als Anbieter eines Players** (EuGH „Filmspeler“) | neutral bleiben gemäss 2c: keine Quellen, keine Suchhilfen für fremde Kataloge, kein Marketing mit Inhalten; Nutzungsbedingungen; Beratung vor dem Start |
| 21 | **Entfernung aus dem Store auf Druck von Rechteinhabern** (z. B. März 2026, 36 IPTV-Apps) | trifft auch neutrale Player und ist kaum beeinflussbar. Neutraler Auftritt senkt das Risiko; Kontakt für Rechteinhaber; Einnahmen nicht allein auf den App Store stützen (Klumpenrisiko) |
| 22 | **Kindersicherung umgehbar**, wenn die App gelöscht und neu installiert wird | PIN im Keychain (überlebt Neuinstallation nicht zwingend); für Eltern zusätzlich auf die Bildschirmzeit von Apple verweisen |

## 7. Funktionsumfang

**In den Prototypen vorhanden:** Startseite, Live TV, TV-Guide (heute/morgen), Mediathek (Filme, Serien, Meine Liste), „Beliebte Filme/Serien“ nur aus der eigenen Playlist (2c), Favoriten, Meine Liste, Zuletzt gesehen, Weiterschauen (setzt direkt fort), Vorheriger Sender (tvOS 2× OK), Suche, Erinnerungen, Live pausieren, Player-Menü (Ton & Untertitel, Bild, Mehr, Info), Qualitäts-Badges, Engine-Wahl, Deinterlacing, Bildwiederholrate und Dynamikbereich anpassen (tvOS), Surround-Ton (tvOS), mehrere Playlists, **Playlist bearbeiten** (Quelle, Aktualisierung, TV-Guide, Zeitversatz pro Playlist), **Einrichtung per QR-Code mit dem iPhone**, **HTTP-Header (User-Agent) pro Playlist**, **Senderliste bearbeiten**, **Kindersicherung mit PIN und gesperrten Gruppen**, **bevorzugte Ton- und Untertitelsprache**, **Beim Start: letzter Sender**, **Hilfeseite „Playlist einrichten“**, Über Onda & Rechtliches (Impressum, Datenschutz, Nutzungsbedingungen, Rechteinhaber, Lizenzen, Quellenangaben), Deutsch/Englisch, Hell/Dunkel. **Zusätzlich auf dem iPhone:** Player hoch und quer (Kanalliste mit Gruppen), Wischgesten, Kontextmenü pro Sender, Bild-in-Bild, AirPlay-Auswahl, „An Apple TV senden“, Nächste Folge im Player, Seitenstapel pro Tab.

**Bewusst nicht vorgesehen (2c):** Download/Offline, Charts fremder Dienste, Merken nicht verfügbarer Titel, mitgelieferte Quellen, Links oder Anbieternamen in der Hilfe.

**Bei Mitbewerbern verbreitet, bei Onda noch offen** (Vorschlag für die Priorität):

| Funktion | Priorität | Bemerkung |
|---|---|---|
| Weitere HTTP-Header pro Playlist (z. B. Referer) | mittel | unter „Erweitert“, User-Agent ist bereits vorgesehen |
| EPG-Zuordnung manuell (tvg-id) und mehrere EPG-Quellen | hoch | häufige Fehlerquelle bei IPTV |
| iCloud-Sync (Favoriten, Einstellungen, Weiterschauen, Senderliste) | mittel | im iPhone-Prototyp als Schalter vorhanden |
| Top Shelf (Weiterschauen/Lieblingssender auf dem Homescreen) | mittel | starkes Premium-Merkmal; iOS-Gegenstück: Widgets |
| Nächste Folge automatisch abspielen (mit Einblendung) | mittel | Gesehen-Status der Folgen ist bereits da |
| Suche auch in kommenden Sendungen (Erinnerung direkt aus der Suche) | mittel | heute nur laufende Sendungen |
| Erinnerungen: Übersicht, Vorlaufzeit, Mitteilung | mittel | |
| Profile | mittel | |
| Multiview (2–4 Sender) | später | rechenintensiv, mit VLC auf dem Gerät testen |
| iPad-Layout (Seitenleiste, Live TV dreispaltig) | mittel | im Prototyp noch nicht gezeigt |
| Verlauf löschen (Weiterschauen, Zuletzt gesehen) | niedrig | |

## 8. iOS-App

**Prototyp:** Artifact „Onda iPhone“. Gleiche Testdaten, gleiche Abgleich-Logik, gleiche Einstellungs-Schlüssel und gleiche Farb- und Schriftwelt wie tvOS. Der grösste Teil (Daten, Parser, EPG, Abgleich, Senderliste, Kindersicherung, Player-Kern, Übersetzungen) liegt in OndaCore und wird geteilt.

| Prototyp iPhone | iOS-Umsetzung |
|---|---|
| Tab-Leiste unten: Start, Live TV, TV-Guide, Mediathek + Suche als eigener Kreis; jeder Tab behält seinen Seitenstapel, Leiste auch auf Unterseiten bedienbar | `TabView` mit Liquid Glass (iOS 26), je Tab ein `NavigationStack`, Suche als `Tab(role: .search)` |
| Einstellungen über Knopf oben rechts in jedem Tab (Struktur siehe 4e) | Push in `NavigationStack`, `Toggle` für Ja/Nein |
| Mediathek mit Segmenten Filme · Serien · Meine Liste | `Picker(.segmented)` |
| „Beliebte Filme/Serien“ als wischbares Regal mit Rang, „Alle ›“ öffnet die Liste (nur eigene Playlist, 2c) | `ScrollView(.horizontal)` + `.scrollTargetBehavior(.paging)` |
| Live TV: Gruppen-Chips (gesperrte mit 🔒), Kanalliste; Sender gedrückt halten → Abspielen, Favorit, Programm, Ausblenden | `List` + `.contextMenu` |
| TV-Guide: eine Chip-Zeile, Raster mit fixer Senderspalte, Sendung antippen → Sheet | eigenes Raster in zwei Richtungen scrollbar, `.sheet` mit `presentationDetents` |
| Detailseiten (Film, Serie mit Staffeln; aktuelle Staffel, gesehene Folgen ✓), nur Titel aus der eigenen Playlist | Push-Seiten |
| Player hochkant: Video oben, darunter Sendung, vorheriger Sender, Kanalliste | eigene View, `UIViewRepresentable` für VLC-View bzw. `AVPlayerLayer` |
| Player quer: Vollbild, Steuerung ein-/ausblenden, Kanalliste links (mit Gruppen-Chips), Menü rechts | Ausrichtung über `UIInterfaceOrientationMask` nur im Player |
| Gesten: tippen = Steuerung, seitlich wischen = Senderwechsel, nach unten wischen = schliessen | `DragGesture` |
| Player-Menü (Ton & Untertitel · Bild · Mehr · Info) | Sheet hochkant, Seitenleiste quer |
| Bild-in-Bild, AirPlay | `AVPictureInPictureController`, `AVRoutePickerView` (Risiken 16, 17) |
| Senderliste bearbeiten | `List` mit `EditButton` und `.onMove` |
| Kindersicherung: PIN-Ziffernblock als Sheet, Seite „Gesperrte Gruppen“ mit Schaltern | eigene Views, PIN im Keychain |
| „An Apple TV senden“ | `NWBrowser` (Bonjour) + gleiche lokale Schnittstelle wie die QR-Einrichtung |

Einstellungen nur auf iOS: HDR-Wiedergabe, Bild-in-Bild automatisch, Mobile Daten, iCloud-Sync, Senderwechsel durch Wischen. Entfällt auf iOS: „Bildwiederholrate anpassen“ (`AVDisplayManager` gibt es nur auf tvOS) und Surround-Ton.

**Empfehlung:** zuerst tvOS fertigstellen, iOS danach als zweites Target. Universal Purchase: ein Kauf für Apple TV, iPhone und iPad.

### 8a. Umbau nach MyTVOnline+-Abläufen (02.–03.10.2026, Prototyp iPhone)

| Bereich | Neu |
|---|---|
| Start | Live-Karte 16:9 mit Titel im Bild, Meine Sender als Logo-Kacheln, Weiterschauen, Beliebte Filme, Beliebte Serien (nur eigene Playlist, mit Rang, 2c), Regale seitenweise mit Punkten |
| Live TV | öffnet die zuletzt genutzte Gruppe; Gruppen-Leiste («Gruppe · Name · Anzahl · ↕») führt zur Gruppenliste mit «Zuletzt genutzt» und Playlist-Umschalter |
| Player hochkant | Video oben, Sendungszeile (Tippen klappt das Programm auf, ersetzt einen Guide-Knopf), Gruppen-Leiste, darunter scrollt nur die Senderliste; oben Ton/Untertitel, Favorit, AirPlay, Bild-in-Bild; Mitte vorheriger/nächster Sender |
| Tab-Leiste | gleitende Markierung, erneutes Tippen: Übersicht → nach oben → Gruppen |
| Detailseite | Apple-TV-Stil: grosses Bild mit stummer Trailer-Vorschau, Titel-Logo, Abspielen/Fortsetzen, Meine Liste, Trailer, Folgen-Karussell, Besetzung, Ähnliches, Info |
| Bedienung | Tipp-Schutz beim Scrollen, Home-Bildschirm-Modus mit eigenem App-Symbol |

Für tvOS sinngemäss übernehmen; dort bleibt der Player im Vollbild.

## 9. Vorgehen (Meilensteine)

1. **Voraussetzungen:** Entweder ein Mac (Apple Silicon, 16 GB RAM) mit Xcode: Mit einer Gratis-Apple-ID läuft die App 7 Tage und wird dann neu installiert. Oder ohne Mac: Build in der Cloud (GitHub) und TestFlight, dafür ist das Apple Developer Program nötig (99 USD/Jahr).
2. **Player-Test:** fünf Kandidaten gemäss Abschnitt 2a (AVPlayer, MPVKit, VLCKit 4, KSPlayer, AVPlayer mit Umpacken) mit denselben eigenen Sendern und Filmen auf Apple TV 4K und iPhone. Messen: Startzeit, Umschaltzeit, Aussetzer/Neuverbindungen, Bildqualität und Deinterlacing (1080i, 720p50, 4K), Bildwiederholrate, HDR/Dolby Vision, Ton (AC3, E-AC3, DTS), Untertitel, Akku; iPhone zusätzlich Bild-in-Bild und AirPlay. Ergebnis: eine FFmpeg-Engine neben AVPlayer
3. **Live-Kern:** Playlist (M3U/Anbieter-Login, bearbeiten), Live TV, Player, Favoriten, Kindersicherung
4. **TV-Guide:** XMLTV, Zeitversatz pro Playlist, Erinnerungen
5. **Mediathek:** VOD, „Beliebt in deiner Mediathek“, Metadaten (Anbieter-Daten + TMDB über eigenen Server, Abschnitt 2b)
6. **Einstellungen (Struktur 4e), Sprache, Erscheinungsbild, Hilfeseite, Über Onda**
7. **TestFlight** auf dem eigenen Apple TV
8. **iOS-Target**
9. **App Store:** Markenprüfung, rechtliche Beratung (2c), Nutzungsbedingungen und Kontakt für Rechteinhaber, Datenschutz, Review-Demo-Playlist mit legalen Streams, neutrale Beschreibung und Screenshots

## 10. Was Onda von der Konkurrenz abheben soll

1. **Fundament:** Senderwechsel unter 1 Sekunde, automatisches Neuverbinden bei Abbruch, korrekte Bildwiederholrate und korrektes Deinterlacing ohne Einstellen, grosse Playlists flüssig, EPG ordnet sich selbst zu
2. **Bedienung:** wenig auf dem Bildschirm, aufgeräumte Einstellungen wie bei Apple, QR-Einrichtung, Siri-Remote-Gesten, Senderliste bearbeiten, vorheriger Sender mit 2× OK, Top Shelf
3. **Premium:** „Beliebt in deiner Mediathek“ mit Rang, Detailseiten wie die Apple TV App, Startseite wie ein TV-Anbieter, iCloud-Sync plus iOS-App, Multiview, Profile
4. **Vertrauen:** klar neutraler, seriöser Auftritt mit Hilfeseite statt Quellen (2c), echte Kindersicherung – Abgrenzung zu Apps, die mit Inhalten werben
5. **Prüfstein:** direkter Vergleich mit iPlay TV und denselben Sendern auf dem eigenen Apple TV, bevor weitere Funktionen gebaut werden

## 11. Offene Entscheidungen

- Soll Onda kostenlos, kostenpflichtig oder mit Abo erscheinen? Davon hängen die TMDB-Lizenz und das Thema Markenschutz ab.
- TMDB-Lizenz anfragen (Preis unklar) oder TheTVDB als Hauptquelle (auch für die Popularitätswerte)?
- Bei KSPlayer als Testsieger: LGPL-Lizenz kaufen (Preis anfragen)?
- „Beliebt in deiner Mediathek“ behalten, wenn die Datenquelle Kosten verursacht? (Rückfall: Sortierung nach „Neueste“)
- Live pausieren behalten, wenn der Puffer auf dem Gerät nur kurz ist?
- iOS: Bild-in-Bild auch für .ts-Streams, falls die gewählte FFmpeg-Engine es nicht kann? (Dann Umpacken nach HLS.)
- Sprache in der App umschaltbar lassen oder (iOS-üblich) nur über die Systemeinstellung „Sprache pro App“?
