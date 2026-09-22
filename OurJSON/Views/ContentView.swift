import SwiftUI
import Inject

// MARK: - Workspace Scene

struct ContentView: View {
    // MARK: State

    @ObservedObject var viewModel: WorkspaceViewModel
    @State private var showOptions = true
    @ObserveInjection var inject

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            WorkspaceHeader(
                viewModel: viewModel,
                showOptions: $showOptions
            )
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)

            WorkspaceColumns(
                viewModel: viewModel,
                showOptions: showOptions
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            WorkspaceFooter(viewModel: viewModel)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
        }
        .background(Color.castObsidian)
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("ourjson.content")
        .enableInjection()
    }
}

// MARK: - Settings Scene

struct SettingsView: View {
    var body: some View {
        Form {
            Text("OurJSON").font(.title2)
            Text("Offline JSON model generation for macOS.").foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 360)
        .accessibilityIdentifier("ourjson.settings")
    }
}
