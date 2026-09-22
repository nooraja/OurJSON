# OurJSON for macOS — Product Requirements Document

## Product summary

OurJSON is a native macOS developer utility inspired by quicktype. It turns a JSON sample into readable, copy-ready model code for Swift, Kotlin, or Dart. The first release prioritizes a fast keyboard-driven loop: paste JSON, inspect generated code, change the target language, and copy the result.

## Problem

Developers repeatedly hand-write model types from JSON payloads. Existing web tools are useful, but a focused desktop app can keep samples private, feel instant, and expose macOS-native shortcuts and window chrome.

## Goals

- Generate usable model types from a JSON object or array.
- Support Swift Codable, Kotlin data classes, and Dart classes with JSON serialization helpers.
- Make the primary workflow fit in one window and match the supplied Figma design.
- Provide visible validation, generated model count, copy feedback, and option toggles.
- Work offline for the core conversion flow.

## Non-goals for MVP

- Full quicktype parity (schema URLs, GraphQL, database schemas, custom templates).
- Network uploads, accounts, or cloud persistence.
- Perfect preservation of every exotic JSON edge case.

## Primary flow

1. Launch OurJSON.
2. Paste or edit JSON in the left editor.
3. The app validates and infers a root model automatically.
4. Select Swift, Kotlin, or Dart from the top bar (Option-1/2/3).
5. Review generated code in the center editor.
6. Toggle generation options in the right inspector.
7. Copy the complete output (Command-Shift-C) or share it through the macOS share sheet.

## MVP requirements

### Input

- Editable JSON text area with line numbers.
- Sample Pokedex payload preloaded on first launch.
- JSON object and top-level array support.
- Inline valid/invalid state with a concise error message.

### Generation

- Infer nested objects, arrays, nullable values, booleans, strings, integers, and doubles.
- Stable singularization for array model names.
- Swift: `Codable` structs and `CodingKeys` when keys are not Swift-safe.
- Kotlin: `data class` models with nullable types.
- Dart: classes with `fromJson`/`toJson` helpers.
- Option toggles for public types, initializers/mutators, explicit coding keys, and optional properties.

### Desktop UX

- Native `NavigationSplitView`-style three-pane layout.
- Dark adaptive palette based on the Figma design.
- Toolbar language pills, copy/share actions, and Options toggle.
- Keyboard shortcuts and a dedicated Settings scene for future preferences.
- Copy feedback and telemetry events through `OSLog` only; no payload contents are logged.

## Success criteria

- A valid sample produces code in all three languages without a network request.
- Invalid JSON never crashes the app and explains the failure in the status bar.
- Copy action places generated code on the pasteboard and confirms success.
- `swift build` succeeds and the bundled app launches through `script/build_and_run.sh`.

## Delivery plan

1. Foundation: package, app scene, PRD, telemetry, JSON inference model.
2. Core workflow: editor, language switching, code generation, copy/share.
3. Figma fidelity: dark surfaces, type scale, toolbar pills, inspector toggles.
4. Verification: unit tests for inference and generation, build/run script, smoke test.

## Future roadmap

- Custom root type name and schema naming rules.
- Format and indentation controls.
- Persisted documents and recent samples.
- More targets (TypeScript, Python, Rust) via a template protocol.
- AppKit text storage for token-level syntax highlighting and large-file performance.
