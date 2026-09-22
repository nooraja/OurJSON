import SwiftUI
import Inject

// MARK: - Workspace Footer

struct WorkspaceFooter: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @ObserveInjection var inject

    var body: some View {
        HStack(spacing: 8) {
            statusIndicator
            statusText
            separator
            Text("\(viewModel.modelCount) models generated")
            separator
            Text(viewModel.activeFileName)
                .foregroundStyle(.secondary)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .lineLimit(1)
            }

            Spacer()
            shortcut("Copy Model", "⌘C")
            shortcut("Options", "⌥O")
        }
        .font(.system(size: 10, design: .monospaced))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .frame(height: 28)
        .background(Color.castHeader)
        .accessibilityIdentifier("ourjson.footer")
        .enableInjection()
    }

    private var statusIndicator: some View {
        Circle()
            .fill(viewModel.errorMessage == nil ? Color.green : Color.red)
            .frame(width: 6, height: 6)
            .accessibilityIdentifier("ourjson.footer.statusIndicator")
    }

    private var statusText: some View {
        Text(viewModel.errorMessage == nil ? "Valid JSON" : "Invalid JSON")
            .accessibilityIdentifier("ourjson.footer.statusText")
    }

    private var separator: some View {
        Text("•")
    }

    private func shortcut(_ title: String, _ key: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
            Text(key).keyBadge()
        }
    }
}
