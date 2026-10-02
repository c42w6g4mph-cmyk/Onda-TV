# Onda

Premium-IPTV-Player für **Apple TV** und **iPhone/iPad**. Ein gemeinsamer Swift-Kern, zwei Apps, die parallel entwickelt werden.

> Status: Prototypen fertig, Swift-Grundgerüst angelegt. Der vollständige Plan steht in [`docs/Bauplan.md`](docs/Bauplan.md).

## Aufbau

```
onda/
├── prototypes/
│   ├── tvos/index.html     Klick-Prototyp Apple TV (1920×1080, Fernbedienung per Pfeiltasten)
│   └── ios/index.html      Klick-Prototyp iPhone (Touch, hoch und quer)
├── OndaCore/               Gemeinsamer Kern (Swift Package) – für beide Apps
│   ├── Sources/OndaCore    Modelle, M3U-Parser, Trend-Abgleich, Player-Schnittstelle
│   └── Tests/OndaCoreTests
├── Apps/
│   ├── Shared/             Views, die beide Apps nutzen
│   ├── OndaTV/             tvOS-App (Tab-Leiste oben, Focus Engine)
│   └── OndaMobile/         iOS-App (Tab-Leiste unten, Touch, Bild-in-Bild)
├── project.yml             Xcode-Projekt als Text (XcodeGen)
├── docs/Bauplan.md         Entscheidungen, Architektur, Risiken, Meilensteine
└── .github/workflows/ci.yml  Tests und Builds für beide Apps bei jedem Push
```

## Zwei Versionen, ein Repository

tvOS und iOS laufen **parallel**, aber nicht getrennt:

- **Gemeinsam in `OndaCore`**: alles ohne Bildschirm, also Playlist (M3U/Xtream), EPG, Trend-Abgleich, Senderliste, Einstellungen, Player-Logik. Eine Korrektur dort gilt sofort für beide Apps.
- **Getrennt in `Apps/OndaTV` und `Apps/OndaMobile`**: Bedienung und Darstellung (Fokus und Fernbedienung bzw. Touch, Gesten, Bild-in-Bild).
- **Prototypen**: Beide liegen unter `prototypes/` und bleiben die Vorlage für Optik und Abläufe. Änderungen am Bedienkonzept zuerst dort, dann in Swift.

### Arbeitsweise

| Was | Regel |
|---|---|
| Branches | `tvos/…`, `ios/…`, `core/…`, `docs/…` – z. B. `tvos/live-tv`, `core/xtream-client` |
| Labels | `tvOS`, `iOS`, `Kern`, `Prototyp`, `Fehler`, `Funktion` |
| Meilensteine | wie im Bauplan, Abschnitt 9 |
| Merge nach `main` | nur wenn die CI für **beide** Apps grün ist |

Eine Funktion, die beide Apps betrifft (z. B. Favoriten), bekommt ein Issue mit beiden Labels. Zuerst wird der Kern umgesetzt, danach die beiden Oberflächen.

## Prototypen ansehen

`prototypes/tvos/index.html` bzw. `prototypes/ios/index.html` herunterladen und im Browser öffnen. Alle Daten sind Testdaten, es laufen keine echten Streams.

## Bauen

**Mit Mac:** Xcode und [XcodeGen](https://github.com/yonaskolb/XcodeGen) installieren (`brew install xcodegen`), dann:

```bash
xcodegen generate
open Onda.xcodeproj
```

Kern-Tests ohne Xcode-Projekt: `swift test --package-path OndaCore`

**Ohne Mac:** Jeder Push startet die CI (GitHub Actions, macOS). Sie testet den Kern und baut beide Apps für den Simulator. Zum Installieren auf dem eigenen Apple TV bzw. iPhone braucht es TestFlight und damit das Apple Developer Program.

Die Bundle-ID `ch.onda.app` ist ein Platzhalter. Sie ist für beide Apps gleich, damit später ein Kauf für Apple TV, iPhone und iPad gilt (Universal Purchase).

## Noch nicht enthalten

VLCKit, echte Player, EPG-Parser, Xtream-Client und alle Bildschirme. Die App-Targets zeigen vorerst Platzhalter mit der richtigen Tab-Struktur. Die Reihenfolge steht im Bauplan unter Meilensteine.
