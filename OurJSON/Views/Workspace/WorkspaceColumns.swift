import SwiftUI
import Inject

// MARK: - Workspace Columns

struct WorkspaceColumns: View {
    // MARK: Dependencies

    @ObservedObject var viewModel: WorkspaceViewModel
    let showOptions: Bool
    @ObserveInjection var inject

    // MARK: Body

    var body: some View {
        HStack(spacing: 0) {
            SourceInputPane(viewModel: viewModel)
            GeneratedOutputPane(viewModel: viewModel)

            if showOptions {
                GeneratorOptionsPane(viewModel: viewModel)
                    .transition(
                        .offset(x: 24)
                        .combined(with: .opacity)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .animation(
            .spring(response: 0.36, dampingFraction: 0.84),
            value: showOptions
        )
        .accessibilityIdentifier("ourjson.workspace.columns")
        .enableInjection()
    }
}

// MARK: - Source Input Pane

struct SourceInputPane: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    var body: some View {
        VStack(spacing: 0) {
            sourceToolbar
            sourceEditor
        }
        .frame(
            minWidth: 320,
            idealWidth: 395,
            maxWidth: 430,
            maxHeight: .infinity
        )
        .clipped()
        .accessibilityIdentifier("ourjson.workspace.sourcePane")
    }

    private var sourceToolbar: some View {
        HStack(spacing: 8) {
            Text("NAME")
                .font(.sectionLabel)
                .foregroundStyle(.secondary)

            TextField("Root model", text: $viewModel.rootName)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white.opacity(0.1))
                }
                .accessibilityIdentifier("ourjson.source.rootName")

            Button {
                viewModel.importJSONFile()
            } label: {
                Image(systemName: "folder")
                    .iconButton()
            }
            .buttonStyle(.plain)
            .help("Import JSON file")
            .accessibilityIdentifier("ourjson.source.import")
        }
        .padding(.horizontal, 14)
        .frame(height: 49)
        .background(Color.castHeader)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.15)
        }
    }

    private var sourceEditor: some View {
        CodeEditorView(
            text: $viewModel.input,
            isEditable: true
        )
        .frame(maxHeight: .infinity)
        .clipped()
        .accessibilityIdentifier("ourjson.source.editor")
    }
}

// MARK: - Generated Output Pane

struct GeneratedOutputPane: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    var body: some View {
        VStack(spacing: 0) {
            outputToolbar
            outputEditor
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .accessibilityIdentifier("ourjson.workspace.outputPane")
    }

    private var outputToolbar: some View {
        HStack {
            Text("Generated \(viewModel.language.rawValue)")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("ourjson.output.title")

            Spacer()

            Text("LIVE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(hex: viewModel.language.accent))
                .accessibilityIdentifier("ourjson.output.live")
        }
        .padding(.horizontal, 16)
        .frame(height: 49)
        .background(Color.castHeader)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.15)
        }
    }

    private var outputEditor: some View {
        ZStack(alignment: .bottomTrailing) {
            CodeEditorView(
                text: Binding(
                    get: { viewModel.output },
                    set: { _ in }
                ),
                isEditable: false
            )

            Button {
                viewModel.copyOutput()
            } label: {
                Label(
                    "Copy \(viewModel.language.rawValue) Code",
                    systemImage: viewModel.copied ? "checkmark" : "doc.on.doc"
                )
                .floatingButton()
            }
            .buttonStyle(.plain)
            .padding(18)
            .accessibilityIdentifier("ourjson.output.copy")
        }
        .frame(maxHeight: .infinity)
        .clipped()
        .accessibilityIdentifier("ourjson.output.editor")
    }
}

// MARK: - Generator Options Pane

struct GeneratorOptionsPane: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                LiquidGlassSegmentedControl(
                    items: ConstructKind.allCases,
                    selection: $viewModel.options.construct,
                    title: \.rawValue,
                    accessibilityIdentifier: "ourjson.options.construct"
                )
                .frame(maxWidth: .infinity)

                Divider().opacity(0.2)

                GeneratorOptionToggle(title: "Make types public", isOn: $viewModel.options.makeTypesPublic)
                GeneratorOptionToggle(title: "Plain types only", isOn: $viewModel.options.plainTypesOnly)
                GeneratorOptionToggle(title: "Generate initializers and mutators", isOn: $viewModel.options.generateInitializers)
                GeneratorOptionToggle(title: "Explicit CodingKey values in Codable types", isOn: $viewModel.options.explicitCodingKeys)
                GeneratorOptionToggle(title: "Use var instead of let for object properties", isOn: $viewModel.options.useVarProperties)
                GeneratorOptionToggle(title: "Unknown enum values become null", isOn: $viewModel.options.unknownEnumValuesAreNull)
                GeneratorOptionToggle(title: "Mark generated models as Sendable", isOn: $viewModel.options.markSendable)
                GeneratorOptionToggle(title: "Make all properties optional", isOn: $viewModel.options.optionalProperties)
            }
            .padding(16)
        }
        .frame(width: 270)
        .background(Color.castHeader)
        .accessibilityIdentifier("ourjson.workspace.optionsPane")
    }
}

// MARK: - Generator Option Toggle

private struct GeneratorOptionToggle: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 5) {
                Text(title)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 11))
        }
        .toggleStyle(
            SwitchToggleStyle(
                tint: Color.castCoral
            )
        )
        .accessibilityIdentifier("ourjson.options.\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
    }
}
