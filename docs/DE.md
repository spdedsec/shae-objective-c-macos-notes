# shae-objective-c-macos-notes — Installations- und Nutzungsanleitung (Deutsch)

SHAE Notes — eine macOS-Notizen-App in Objective-C (Foundation).

Entsprechend dem **SHAE Field Manual Design System**: warmer Papierton
`#F2EEE5`, Tinte `#191712`, ein Oxid-Rot `#B3341B` Signal pro Ansicht,
`0px` Radius, `1px` Ränder, randdefinierte Karten, `44px` Touch-Ziele,
Oxid-Fokusringe und `140–240ms` Bewegung. Siehe `DESIGN.md`.

## Features

- Notiz erstellen (Titel, Inhalt)
- Alle Notizen auflisten (neueste zuerst)
- Notizinhalt ansehen/bearbeiten
- Notiz löschen
- Speichern/Laden als JSON
  (`~/Library/Application Support/SHAE/notes.json`)

## Voraussetzungen

- clang mit Objective-C-Unterstützung (Xcode Command Line Tools auf macOS)
- Foundation Framework (macOS-SDK)

> **Hinweis:** clang ist in dieser Umgebung vorhanden, das Foundation-SDK
> nicht, sodass die App hier nicht kompiliert oder getestet werden kann.
> Siehe `scripts/install.sh`.

## Installation

```bash
git clone https://github.com/spdedsec/shae-objective-c-macos-notes.git
cd shae-objective-c-macos-notes
./scripts/install.sh
```

## Build & Ausführen (macOS)

```bash
cd src
clang -fobjc-arc -framework Foundation Notes.m -o Notes
./Notes
```

## Nutzung

```objc
Notes *store = [Notes sharedManager];

// Erstellen
Note *n = [store createNoteWithTitle:@"Meeting" content:@"SHAE tier-3 besprechen" error:nil];

// Auflisten
for (Note *note in [store allNotes]) {
    NSLog(@"%ld: %@", (long)note.identifier, note.title);
}

// Aktualisieren
[store updateNote:n title:@"Meeting" content:@"SHAE tier-3 Projekte besprechen" error:nil];

// Löschen
[store deleteNoteWithIdentifier:n.identifier error:nil];
```

Notizen werden als JSON in `~/Library/Application Support/SHAE/notes.json`
gespeichert.

## Lizenz

MIT. Siehe `LICENSE`.
