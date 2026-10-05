# Onda – Rechtliche Prüfung «Über Onda» und Regulatorik

Stand: 05.10.2026 · Grundlage: Prototyp 1.7 (Apple TV) bzw. 1.6 (iPhone), aktualisiert 06.10.2026 · **Einschätzung, keine Rechtsberatung.** Vor dem Start von einer Anwältin bzw. einem Anwalt für IT-, Urheber- und Datenschutzrecht (CH und EU) prüfen lassen.

## 0. Was wirklich nötig ist (06.10.2026)

**Entscheid Sinan:** kein eigener Server. Cover und Infos fragt die App direkt bei TheTVDB/TMDB ab. Damit entfallen die heikelsten Datenschutzpunkte (Server-Protokolle, IP plus Playlist-Titel beim Anbieter von Onda).

| Stufe | Was | Gilt |
|---|---|---|
| **Immer Pflicht** | Datenschutzerklärung (auch als URL in App Store Connect), App-Datenschutzangaben, Altersfreigabe-Fragebogen, Export-Angabe, LGPL-Hinweise mit Quellcode-Angebot, TMDB-/TheTVDB-Quellenangabe, Neutralität (2c) | auch bei einer Gratis-App |
| **Pflicht mit Einnahmen** | Händlerangaben im EU-App-Store (Adresse öffentlich), Impressum (CH: UWG Art. 3 lit. s; DE: DDG), kommerzielle TMDB-Lizenz bzw. TheTVDB-Stufen, AHV/Steuern | sobald Onda Geld kostet oder einbringt |
| **Unklar bei Gratis-App** | Impressum für ein reines Gratis-Hobbyprojekt (Grauzone); ob TMDB eine Gratis-App im App Store als nicht-kommerziell akzeptiert | bei TMDB nachfragen; Impressum vorsorglich drinlassen |
| **Freiwillig** | eigene Nutzungsbedingungen (Apple-EULA genügt), eigene Seite für Rechteinhaber, EU-Vertreter, Barrierefreiheit über das Übliche hinaus | entfernt bzw. nicht nötig |
| **Unabhängig von der App** | Arbeitsvertrag (Nebenbeschäftigung, geistiges Eigentum) prüfen, Markenprüfung «Onda» | früh |

**Folgen von «kein Server»:** Der API-Schlüssel steckt in der App und lässt sich auslesen; ein Wechsel geht nur per Update; jedes Gerät fragt selbst (Cache auf dem Gerät). Die Datenschutzerklärung nennt TMDB und TheTVDB als direkte Empfänger der IP-Adresse.

## 1. Umgesetzt in den Prototypen (Stand 06.10.2026)

«Über Onda & Rechtliches» hat vier Seiten:

1. **Onda enthält keine Inhalte** (inkl. Nutzungsrecht, Kindersicherung als Hilfe, Verweis auf die Apple-EULA)
2. **Impressum & Kontakt** (Platzhalter; dieselbe Adresse für Rechteinhaber)
3. **Datenschutz** (8 kurze Punkte, ohne Server)
4. **Lizenzen & Quellen** (LGPL mit Quellcode-Angebot, TMDB-Pflichtsatz, TheTVDB, Marken)

Daneben: Trailer-Vorschau (iPhone) Standard «Aus»; «Anbieter-Login» statt «Xtream»; Hinweis bei der Kindersicherung. Die Rechtstexte sind ein deutscher Entwurf.

Die folgende Prüfung vom 05.10.2026 bleibt als Referenz stehen; geänderte Punkte sind markiert.

## 2. Befunde nach Schwere

### Muss vor dem Start

| # | Thema | Befund | Massnahme |
|---|---|---|---|
| 1 | **Öffentliche Händlerangaben (DSA)** | Wer im EU-App-Store verkauft, gilt als Händler. Apple zeigt dann **Adresse, Telefon und E-Mail öffentlich** auf der Produktseite. Bei Einzelpersonen ist das die eigene Adresse. Ohne Händlerstatus entfernt Apple die App aus der EU ([SD Times](https://sdtimes.com/mobile/apple-adds-new-requirements-for-apps-distributed-through-the-app-store-in-the-eu/)) | Entscheiden: Privatadresse veröffentlichen, Geschäftsadresse bzw. Postfach nutzen (für Einzelpersonen zulässig) oder eine Firma gründen (dann gilt die D-U-N-S-Adresse) |
| 2 | **Impressum in der App** | Deutschland (DDG): Pflicht auch für Apps, in der App mit höchstens 2 Klicks erreichbar und zusätzlich im Store-Eintrag ([e-recht24](https://www.e-recht24.de/impressum/10176-app-impressum.html)). Schweiz: UWG Art. 3 Abs. 1 lit. s verlangt klare Identität und E-Mail ([Handelsverband](https://handelsverband.swiss/swiss-online-garantie-zertifizierung-impressum/)) | Platzhalter füllen. Apple TV: Einstellungen › Über Onda › Impressum braucht 2–3 Schritte; kurze Wege ohne Scrollen prüfen |
| 3 | **Datenschutzerklärung** | ~~Heikel ist der Metadaten-Server~~ **Entfällt seit 06.10.2026: kein eigener Server.** Bisheriger Befund: Heikel war der Metadaten-Server: Die **IP-Adresse plus die Titel einer Playlist** sind Personendaten. Bei illegalen Playlists ist das potenziell belastend. Ausserdem könnte es als «Wissen» von Onda über illegale Inhalte ausgelegt werden, was 2c vermeiden will | Server ohne Protokolle (oder max. 7 Tage, ohne IP), keine Nutzerkennung, Zwischenspeicher pro Titel. In der Erklärung Hoster und Standort nennen. Datenschutzerklärung als URL in App Store Connect (Pflicht) |
| 4 | **Bekanntgabe ins Ausland** | TMDB, TheTVDB, Google und Apple bearbeiten Daten in den USA. Nach DSG und DSGVO braucht es dafür eine Grundlage, etwa das Data Privacy Framework (falls zertifiziert) oder Standardvertragsklauseln (**unklar je Empfänger**) | Je Empfänger prüfen und in Punkt 9 eintragen. Bilder allenfalls über den eigenen Server laden, dann geht die IP nicht an TMDB/TheTVDB |
| 5 | **YouTube ohne Einwilligung** | Die automatische Trailer-Vorschau lud Google-Inhalte ohne Zutun. In Deutschland (TDDDG § 25) und der EU braucht das eine Einwilligung; auch der «nocookie»-Modus überträgt die IP-Adresse | **Umgesetzt:** Vorschau standardmässig aus. In Swift optional ganz ohne YouTube (nur Link nach Tippen) |
| 6 | **TMDB-Lizenz und Logo** | Kommerzielle Nutzung braucht eine Lizenz. Vorgeschrieben sind das offizielle TMDB-Logo (weniger prominent als das Onda-Logo) und der Satz «This product uses the TMDB API but is not endorsed or certified by TMDB.» im Bereich Über/Credits ([TMDB FAQ](https://developer.themoviedb.org/docs/faq)) | Satz umgesetzt. Das Logo ist nur ein Platzhalter und muss durch das offizielle TMDB-Logo ersetzt werden; Lizenz anfragen |
| 7 | **TheTVDB-Quellenangabe** | Konkreter Wortlaut nicht geprüft (Seite war nicht abrufbar) | Vorgaben auf thetvdb.com nachlesen und übernehmen |
| 8 | **LGPL (FFmpeg, Player-Engine)** | Auf iOS und tvOS umstritten, weil Nutzer die Bibliothek wegen der Signatur nicht selbst austauschen können ([FFmpeg-Ticket #1229](https://trac.ffmpeg.org/ticket/1229)). Üblich: dynamische Frameworks, Lizenztexte, schriftliches Quellcode-Angebot, Objektdateien zum Neuverlinken. FFmpeg ohne `--enable-gpl` bauen; ob einzelne Komponenten im gewählten Build (z. B. Deinterlacing-Filter) unter GPL stehen, ist **unklar** und muss geprüft werden | Lizenzprüfung des konkreten Builds. Vollständige Lizenztexte in die App. Angebot bereits als Text umgesetzt |
| 9 | **Altersfreigabe** | Neue Apple-Stufen 13+, 16+ und 18+, Fragebogen seit Januar 2026 Pflicht ([iPhone in Canada](https://www.iphoneincanada.ca/2025/07/25/updated-app-store-age-ratings)). Ein Player für beliebige Streams wird je nach Antworten vermutlich hoch eingestuft (**unklar**) | Fragebogen ehrlich beantworten; eine hohe Einstufung schadet einem Player kaum |
| 10 | **Ansprechstelle für Rechteinhaber** | Gesetzlich nicht verlangt (Onda speichert keine Inhalte), aber nützlich gegen Druck auf Apple | Seit 06.10.2026 als Kontakt im Impressum statt eigener Seite; die Adresse muss betreut werden |

### Sollte

| # | Thema | Befund | Massnahme |
|---|---|---|---|
| 11 | **Begriff «Xtream»** | Xtream Codes wurde 2019 bei einer europaweiten Aktion gegen TV-Piraterie abgeschaltet ([Telecompaper](https://www.telecompaper.com/news/italy-coordinating-eu-wide-pirate-streaming-operation-shuts-down-xtream-codes--1308738)). Der Name ist mit Piraterie verbunden | **Umgesetzt:** In der Oberfläche steht nur «Anbieter-Login». Im Store-Text, in Screenshots und Keywords nie «Xtream» verwenden; technisch weiter unterstützen |
| 12 | **Nutzungsbedingungen** | Haftungsausschlüsse gelten nur in Grenzen (CH: OR 100; DE: § 309 Nr. 7 BGB). Ein Gerichtsstand gegenüber Konsumenten ist kaum durchsetzbar | Text ist entsprechend formuliert. In App Store Connect eine eigene EULA hinterlegen oder die Ergänzung verlinken |
| 13 | **Marken** | «Apple TV», «AirPlay», «Dolby Digital» usw. dürfen beschreibend genannt werden, aber nicht im App-Namen und nicht als Logos ohne Lizenz. Dolby-Logos brauchen eine Lizenz | Markenhinweise umgesetzt. Im Store-Text «für Apple TV» statt «Apple TV App»; keine Dolby- oder Apple-Logos |
| 14 | **Patente (Codecs)** | FFmpeg enthält Software-Decoder für patentgeschützte Formate (H.264/HEVC, teils Tonformate). Die Hardware-Decodierung über VideoToolbox ist durch Apple lizenziert, Software-Decodierung nicht ohne Weiteres (**unklar**, Risiko in der Praxis gering, aber vorhanden) | Wo möglich Hardware-Decodierung. Codec-Umfang des FFmpeg-Builds bewusst wählen und mit Fachperson besprechen |
| 15 | **Barrierefreiheit (EAA, seit 28.06.2025)** | Dienste mit Zugang zu audiovisuellen Medien und elektronische Programmführer können erfasst sein. Kleinstunternehmen (unter 10 Personen, unter 2 Mio. EUR Umsatz) sind bei Dienstleistungen ausgenommen ([CCPC-Leitfaden](https://www.ccpc.ie/business/wp-content/uploads/sites/3/2025/04/Microenterprise-Guidelines-Consultation-Draft-1-3.pdf)) | Für dich als Einzelperson voraussichtlich ausgenommen. VoiceOver, Dynamic Type und Untertitel trotzdem sauber unterstützen (auch für die App-Review) |
| 16 | **Export-Kontrolle** | Onda nutzt nur Standard-Verschlüsselung (HTTPS/TLS, Schlüsselbund) | In App Store Connect als ausgenommen deklarieren (`ITSAppUsesNonExemptEncryption = NO`, nach Prüfung) |
| 17 | **EU-Vertreter (Art. 27 DSGVO)** | Ein Schweizer Anbieter, der EU-Personen bedient, braucht einen EU-Vertreter, ausser die Bearbeitung ist gelegentlich und risikoarm (**unklar**). Mit einem protokollfreien Server spricht viel für die Ausnahme | Mit der Fachperson klären |
| 18 | **App-Datenschutzangaben** | Die «Nutrition Labels» in App Store Connect müssen zur Erklärung passen (Kennungen: keine; Nutzungsdaten: keine; Diagnose: nur bei Systemfreigabe) | Beim Einreichen konsistent ausfüllen |

### Persönlich (nicht in der App, aber relevant)

| # | Thema | Massnahme |
|---|---|---|
| 19 | **Arbeitsvertrag** | Nebenbeschäftigung kann eingeschränkt sein (Treuepflicht OR 321a, Regeln zu Nebenbeschäftigung und geistigem Eigentum OR 332). Vertrag und Reglemente prüfen, allenfalls Bewilligung einholen |
| 20 | **Sozialversicherung und Steuern** | Einnahmen aus Onda sind selbständiger Nebenerwerb. Bei der Ausgleichskasse anmelden; kleine Nebeneinkommen sind teilweise nur auf Verlangen beitragspflichtig (Grenze bei der Ausgleichskasse bestätigen lassen). In der Steuererklärung deklarieren. MWST erst ab 100'000 CHF Umsatz; die Abrechnung über Apple prüfen |
| 21 | **Haftung als Einzelperson** | Als Einzelunternehmen haftest du mit dem Privatvermögen. Eine GmbH begrenzt das und liefert gleich eine Geschäftsadresse für die Händlerangaben (#1). Kosten und Nutzen abwägen |
| 22 | **Markenschutz «Onda»** | Bereits im Bauplan (Risiko 9): Swissreg, DPMA, EUIPO prüfen, vor dem Start anmelden |

## 3. Was bereits gut ist

- Klare Neutralität (2c): keine Inhalte, keine Links, keine Anbieternamen, Hilfe ohne Quellen
- Keine Konten, keine Werbung, kein Tracking: wenig Daten, wenig Angriffsfläche
- Zugangsdaten nur auf dem Gerät, im Schlüsselbund
- Die Kindersicherung verspricht nichts, was sie nicht hält

## 4. Offene Platzhalter in den Texten

[Name], [Adresse], [E-Mail], Grundlage der Auslandsbekanntgabe je Empfänger, TheTVDB-Wortlaut, offizielles TMDB-Logo, Name der Player-Engine.
