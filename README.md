# OurJSON

OurJSON is a native macOS utility that turns a JSON sample into model code for Dart, Kotlin, or Swift. It keeps the developer loop in one window: paste JSON, choose a language, inspect generated code, and copy it.

## Features

- Infers nested objects, arrays, strings, integers, doubles, booleans, and null values from JSON.
- Generates Swift `Codable` structs or classes, Kotlin `data class` models, and Dart classes with `fromJson` helpers.
- Updates output when JSON, root model name, language, or generator options change.
- Shows JSON validity, model count, output file name, and concise parse errors.
- Imports local JSON files and copies output to the macOS pasteboard.
- Supports `Option-1`, `Option-2`, and `Option-3` for language switching, plus `Command-C` for copying.
- Runs conversion locally. JSON payload contents are not uploaded or logged.
- Uses SwiftUI Liquid Glass for language and type controls on macOS 26.

## Requirements

- macOS 26 or later
- Xcode with the macOS 26 SDK

## Run

Open `OurJSON.xcodeproj` in Xcode, select the **OurJSON** scheme, then run it. The project includes a bundled JSON fixture for its first launch.

## Test

In Xcode, run the **OurJSONTests** scheme with `Command-U`.

## Scope

OurJSON focuses on JSON model generation. It does not include accounts, cloud storage, schema URLs, GraphQL, custom templates, or full quicktype compatibility.

## Current limits

- Inference uses one JSON sample, not a complete JSON Schema.
- Arrays infer element type from the first item.
- Kotlin and Dart emitters currently use basic key naming and serialization output.
- Some options are shared in the UI before all emitters support them equally.

## Stack

- SwiftUI for application structure and controls
- SwiftUI Liquid Glass for segmented controls
- AppKit through `NSViewRepresentable` for code editing and line numbers
- Foundation `JSONSerialization` for parsing
- Xcode project and XCTest for build and test

## License

No license has been selected yet.
