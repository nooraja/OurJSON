# OurJSON hot reload

OurJSON now targets macOS 26.0 or later. This enables the native SwiftUI Liquid
Glass APIs used by the language selector.

OurJSON uses the [Inject Swift package](https://github.com/krzysztofzablocki/Inject)
with the [InjectionIII app](https://github.com/johnno1962/InjectionIII).

## Verified setup

Hot reload was smoke-tested against this project. A saved change to
`WorkspaceHeader.swift` produced:

```text
💉 Compiling .../WorkspaceHeader.swift
💉 Loading .dylib ...
💉 Interposed 7 function references.
💉 Injected type #1 'OurJSON.WorkspaceHeader'
```

The temporary UI change used for the test was reverted afterward.

## Start hot reload

1. Open `OurJSON.xcodeproj` in Xcode.
2. Start InjectionIII.
3. In InjectionIII, select `Open Project` and choose:

   ```text
   /Users/noor/Documents/Learning/artikel/ios/OurJASON/OurJSON/OurJSON.xcodeproj
   ```

4. In Xcode, select the `OurJSON` scheme and the `Debug` configuration.
5. Run the app with `⌘R` and leave it running.
6. Wait until the Xcode console contains both messages:

   ```text
   💉 InjectionIII connected .../OurJSON.xcodeproj
   💉 Watching files under the directory .../OurJSON
   ```

7. Change the implementation of a SwiftUI view and save it with `⌘S`.
8. Confirm that the console ends with `Injected type ...`.

For the most reliable development loop, launch the app from Xcode. The same
Debug build can also be built and launched from Terminal:

```bash
./script/build_and_run.sh
```

## Project configuration

The Debug target is already configured with:

- `EMIT_FRONTEND_COMMAND_LINES = YES`
- `-Xlinker -interposable`
- App Sandbox disabled
- Hardened Runtime disabled
- `import Inject`, `@ObserveInjection`, and `.enableInjection()` on the main
  workspace views

Release keeps App Sandbox and Hardened Runtime enabled. Do not copy the Debug
injection settings into Release.

## Documents-folder permission warning

Because this project lives inside `Documents`, InjectionIII can print this
warning:

```text
Your project file seems to be in the Desktop or Documents folder and may
prevent InjectionIII working as it has special permissions.
```

The warning is not automatically a failure; hot reload has worked in this
location during the smoke test above. If InjectionIII connects but never prints
`Compiling` after a saved change:

1. Open **System Settings → Privacy & Security → Full Disk Access**.
2. Enable or add `InjectionIII.app`.
3. Quit InjectionIII completely and open it again.
4. Re-select `OurJSON.xcodeproj`, rebuild once with `⌘R`, then retry the edit.

If Full Disk Access is not desirable, move the repository outside protected
`Desktop` or `Documents` folders.

## What can be hot reloaded

Hot reload works best for view body changes, styling, layout, text, and helper
function implementations. Injection hooks currently cover `ContentView`,
`WorkspaceHeader`, `WorkspaceColumns`, and `WorkspaceFooter`.

A normal rebuild is still required after changing dependencies, build settings,
type names, stored-property layouts, function signatures, or app lifecycle code.
`CodeEditorView` bridges to AppKit; recreating its underlying `NSTextView` can
also reset the cursor or scroll position.

## Quick troubleshooting

- No `connected` message: re-select `OurJSON.xcodeproj` in InjectionIII and
  relaunch the Debug app.
- Connected, but no `Compiling`: save with `⌘S` and check the Documents-folder
  permission above.
- Compilation error: undo the last edit or fix the error; InjectionIII cannot
  inject code that does not compile.
- Structural model or view changes: stop the app, rebuild with `⌘R`, then resume
  hot reload.
- Release build: switch back to Debug; injection is intentionally unavailable
  in Release.
