# shae-objective-c-macos-notes — Guía de instalación y uso (Español)

SHAE Notes — una aplicación de notas para macOS en Objective-C (Foundation).

Aplicado el **Sistema de Diseño SHAE Field Manual**: fondo papel cálido
`#F2EEE5`, texto tinta `#191712`, una señal óxido `#B3341B` por vista,
`0px` de radio, bordes de `1px`, tarjetas definidas por borde, objetivos
táctiles de `44px`, anillos de enfoque óxido y movimiento de `140–240ms`.
Véase `DESIGN.md`.

## Características

- Crear nota (título, contenido)
- Listar todas las notas (las más recientes primero)
- Ver/editar contenido de una nota
- Eliminar nota
- Guardar/cargar en JSON
  (`~/Library/Application Support/SHAE/notes.json`)

## Requisitos

- clang con soporte Objective-C (Herramientas de línea de comandos de Xcode en macOS)
- Framework Foundation (SDK de macOS)

> **Nota:** clang está presente en este entorno pero el SDK de Foundation no,
> por lo que la app no puede compilarse ni probarse localmente aquí. Véase
> `scripts/install.sh`.

## Instalación

```bash
git clone https://github.com/spdedsec/shae-objective-c-macos-notes.git
cd shae-objective-c-macos-notes
./scripts/install.sh
```

## Compilación y ejecución (macOS)

```bash
cd src
clang -fobjc-arc -framework Foundation Notes.m -o Notes
./Notes
```

## Uso

```objc
Notes *store = [Notes sharedManager];

// Crear
Note *n = [store createNoteWithTitle:@"Reunión" content:@"Hablar de SHAE tier-3" error:nil];

// Listar
for (Note *note in [store allNotes]) {
    NSLog(@"%ld: %@", (long)note.identifier, note.title);
}

// Actualizar
[store updateNote:n title:@"Reunión" content:@"Hablar de proyectos SHAE tier-3" error:nil];

// Eliminar
[store deleteNoteWithIdentifier:n.identifier error:nil];
```

Las notas se guardan como JSON en `~/Library/Application Support/SHAE/notes.json`.

## Licencia

MIT. Véase `LICENSE`.
