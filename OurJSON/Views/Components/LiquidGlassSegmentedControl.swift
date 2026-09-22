import SwiftUI

// MARK: - Liquid Glass Segmented Control

struct LiquidGlassSegmentedControl<Item: Hashable>: View {
    // MARK: Configuration

    let items: [Item]
    @Binding var selection: Item
    let title: KeyPath<Item, String>
    let accessibilityIdentifier: String
    let color: (Item) -> Color

    init(
        items: [Item],
        selection: Binding<Item>,
        title: KeyPath<Item, String>,
        accessibilityIdentifier: String,
        color: @escaping (Item) -> Color = { _ in .white }
    ) {
        self.items = items
        _selection = selection
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.color = color
    }

    // MARK: Animation

    @Namespace private var glassNamespace

    // MARK: Body

    var body: some View {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(items, id: \.self) { item in
                    segment(for: item)
                }
            }
            .padding(4)
            .glassEffect(.clear.interactive(), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.10), lineWidth: 0.5)
            }
        }
        .contentShape(Capsule())
        .highPriorityGesture(swipeGesture)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    // MARK: Segment

    private func segment(for item: Item) -> some View {
        let isSelected = item == selection
        let label = item[keyPath: title]
        let itemColor = color(item)

        return Button {
            select(item)
        } label: {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(itemColor.opacity(isSelected ? 1 : 0.62))
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .padding(.horizontal, 10)
                .contentShape(Capsule())
                .background {
                    if isSelected {
                        Capsule()
                            .glassEffect(.clear.interactive(), in: Capsule())
                            .glassEffectID("selection", in: glassNamespace)
                            .glassEffectTransition(.matchedGeometry)
                            .overlay {
                                Capsule()
                                    .stroke(itemColor.opacity(0.40), lineWidth: 0.75)
                            }
                            .shadow(color: itemColor.opacity(0.18), radius: 8)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(
            "\(accessibilityIdentifier).\(label.lowercased())"
        )
    }

    // MARK: Selection

    private func select(_ item: Item) {
        withAnimation(.interactiveSpring(duration: 0.28, extraBounce: 0.08)) {
            selection = item
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height),
                      let currentIndex = items.firstIndex(of: selection) else { return }

                let direction = value.translation.width < 0 ? 1 : -1
                let nextIndex = currentIndex + direction
                guard items.indices.contains(nextIndex) else { return }

                select(items[nextIndex])
            }
    }
}
