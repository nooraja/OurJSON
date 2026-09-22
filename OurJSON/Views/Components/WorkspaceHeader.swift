import SwiftUI
import Inject

// MARK: - Workspace Header

struct WorkspaceHeader: View {
    // MARK: Dependencies

    @ObservedObject var viewModel: WorkspaceViewModel
    @Binding var showOptions: Bool
    @ObserveInjection var inject

    // MARK: Body

    var body: some View {
        HStack(spacing: 14) {
            BrandMark()

            Divider()
                .frame(height: 22)

            Text("JSON")
                .pill()

            Text("to")
                .foregroundStyle(.secondary)
                .font(.caption)

            LanguageTabs(viewModel: viewModel)

            Spacer()

            copyButton
            optionsButton
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.castHeader)
        .overlay(alignment: .bottom) {
            Divider()
                .opacity(0.15)
        }
        .accessibilityIdentifier("ourjson.header")
        .enableInjection()
    }

    // MARK: Actions

    private var copyButton: some View {
        Button {
            viewModel.copyOutput()
        } label: {
            Label(
                viewModel.copied ? "Copied" : "Copy",
                systemImage: viewModel.copied ? "checkmark" : "doc.on.doc"
            )
            .toolbarButton()
        }
        .buttonStyle(.plain)
        .keyboardShortcut("c", modifiers: [.command])
        .accessibilityIdentifier("ourjson.header.copy")
    }

    private var optionsButton: some View {
        Button {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.84)) {
                showOptions.toggle()
            }
        } label: {
            Label("Options", systemImage: "slider.horizontal.3")
                .toolbarButton()
        }
        .buttonStyle(.plain)
        .keyboardShortcut("o", modifiers: [.option])
        .accessibilityIdentifier("ourjson.header.options")
    }
}

// MARK: - Traffic Lights

private struct TrafficLights: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(Color(hex: "FF5F56"))
            Circle().fill(Color(hex: "FFBD2E"))
            Circle().fill(Color(hex: "27C93F"))
        }
        .frame(width: 52)
        .accessibilityIdentifier("ourjson.header.trafficLights")
    }
}

// MARK: - Brand Mark

private struct BrandMark: View {
    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.castCoral)
                    .frame(width: 22, height: 22)

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)

                Circle()
                    .fill(.white)
                    .frame(width: 6, height: 6)
                    .overlay {
                        Circle().stroke(Color.castCoral, lineWidth: 2)
                    }
                    .offset(x: 2, y: 2)
            }

            Text("OurJSON")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
        }
        .accessibilityIdentifier("ourjson.header.brandMark")
    }
}

// MARK: - Language Tabs

private struct LanguageTabs: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    var body: some View {
        LiquidGlassSegmentedControl(
            items: TargetLanguage.allCases,
            selection: $viewModel.language,
            title: \.rawValue,
            accessibilityIdentifier: "ourjson.header.language",
            color: { Color(hex: $0.accent) }
        )
        .frame(width: 270)
        .accessibilityIdentifier("ourjson.header.languageTabs")
    }
}
