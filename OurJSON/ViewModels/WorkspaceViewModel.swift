import AppKit
import Combine
import SwiftUI

// MARK: - Workspace View Model

@MainActor
final class WorkspaceViewModel: ObservableObject {
    // MARK: Input State

    @Published var rootName = "TestIni" { didSet { regenerate() } }
    @Published var input: String { didSet { regenerate() } }

    // MARK: Generation State

    @Published var language: TargetLanguage = .swift { didSet { regenerate() } }
    @Published var options = GeneratorOptions() { didSet { regenerate() } }
    @Published private(set) var output = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var modelCount = 0
    @Published var copied = false

    // MARK: Dependencies

    private let inference = JSONInference()
    private let generator = CodeGenerator()

    // MARK: Lifecycle

    init() {
        input = Self.loadBundledInput()
        regenerate()
    }

    // MARK: Derived State

    var activeFileName: String {
        let name = rootName.isEmpty ? "Model" : rootName
        let extensionName = language == .swift ? "swift" : language == .kotlin ? "kt" : "dart"
        return "\(name).\(extensionName)"
    }

    // MARK: Actions

    func regenerate() {
        do {
            let result = try inference.infer(data: Data(input.utf8), rootName: rootName)
            modelCount = result.models.count
            output = generator.generate(result, language: language, options: options)
            errorMessage = nil
            Telemetry.shared.track("generate_\(language.rawValue.lowercased())")
        } catch {
            output = "// Fix the JSON input to generate models.\n"
            errorMessage = error.localizedDescription
            modelCount = 0
        }
    }

    func copyOutput() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(output, forType: .string)
        copied = true
        Telemetry.shared.track("copy_output")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.copied = false }
    }

    func importJSONFile() {
        let panel = NSOpenPanel()
        panel.allowsOtherFileTypes = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url,
              let contents = readableText(from: url) else { return }
        input = contents
        rootName = url.deletingPathExtension().lastPathComponent
        regenerate()
        Telemetry.shared.track("import_json")
    }

    private func readableText(from url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }

        if let plainText = String(data: data, encoding: .utf8),
           !plainText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{\\rtf") {
            return plainText
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtf
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil).string
    }

    private static func loadBundledInput() -> String {
        guard let fileURL = Bundle.main.url(
            forResource: "test_ini",
            withExtension: "json"
        ),
        let contents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return "{}"
        }

        return contents
    }
}
