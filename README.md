# shae-objective-c-macos-notes

SHAE Notes — a macOS notes app written in Objective-C (Foundation).

Built to the **SHAE Field Manual Design System** (applied to a Cocoa/Desktop
UI): warm paper `#F2EEE5`, ink `#191712`, one oxide-red `#B3341B` signal per
view, `0px` radius, `1px` borders, border-defined cards, `44px` touch targets,
oxide focus rings, `140–240ms` motion. See `DESIGN.md`.

## Features

- Create note (title, content)
- List all notes (newest first)
- View / edit note content
- Delete note
- Save/load to JSON (`~/Library/Application Support/SHAE/notes.json`)

## Requirements

- clang with Objective-C support (Xcode Command Line Tools on macOS)
- Foundation framework (macOS SDK)

> **Note:** clang is present in this environment but the Foundation SDK is
> not, so the app cannot be compiled or tested locally here. See
> `scripts/install.sh`.

## Install

```bash
git clone https://github.com/spdedsec/shae-objective-c-macos-notes.git
cd shae-objective-c-macos-notes
./scripts/install.sh
```

## Build & run (macOS)

```bash
cd src
clang -fobjc-arc -framework Foundation Notes.m -o Notes
./Notes
```

## Usage

The `Notes` class (Foundation) provides the full CRUD model:

```objc
Notes *store = [Notes sharedManager];

// Create
Note *n = [store createNoteWithTitle:@"Meeting" content:@"Discuss SHAE tier-3" error:nil];

// List
for (Note *note in [store allNotes]) {
    NSLog(@"%ld: %@", (long)note.identifier, note.title);
}

// Update
[store updateNote:n title:@"Meeting" content:@"Discuss SHAE tier-3 projects" error:nil];

// Delete
[store deleteNoteWithIdentifier:n.identifier error:nil];
```

Notes persist to JSON in `~/Library/Application Support/SHAE/notes.json`.

## Project structure

```
src/
  Notes.h   # Note model + Notes store interface
  Notes.m   # Implementation (create/list/view/edit/delete + JSON persistence)
scripts/install.sh
Makefile
README.md
DESIGN.md
.github/workflows/release.yml
docs/DE.md
docs/ES.md
LICENSE
```

## Release

Releases are created from git tags (`v*`) via
`.github/workflows/release.yml` and packaged as a zip of `src/`.

## License

MIT. See `LICENSE`.
