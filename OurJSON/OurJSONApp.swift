import SwiftUI

@main
struct OurJSONApp: App {
    @State private var workspace = WorkspaceViewModel()

    var body: some Scene {
        WindowGroup("OurJSON") {
            ContentView(viewModel: workspace)
                .frame(minWidth: 1080, minHeight: 680)
        }
        .commands {
            CommandGroup(after: .pasteboard) {
                Button("Copy Generated Code") {
                    workspace.copyOutput()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }

            CommandMenu("Language") {
                ForEach(TargetLanguage.allCases) { language in
                    Button(language.rawValue) {
                        workspace.language = language
                    }
                    .keyboardShortcut(language.shortcut, modifiers: [.option])
                }
            }
        }
        Settings {
            SettingsView()
        }
    }
}
