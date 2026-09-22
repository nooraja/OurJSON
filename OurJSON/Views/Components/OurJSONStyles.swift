import SwiftUI

// MARK: - Shared View Styles

extension View {
    func pill() -> some View {
        self
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    func toolbarButton() -> some View {
        self
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    func floatingButton() -> some View {
        self
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.castCoral.opacity(0.92))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
    }

    func iconButton() -> some View {
        self
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .padding(7)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    func keyBadge() -> some View {
        self
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.35))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.1))
            }
    }
}

// MARK: - Shared Colors and Fonts

extension Font {
    static let sectionLabel = Font.system(
        size: 10,
        weight: .bold,
        design: .monospaced
    )
}

extension Color {
    static let castObsidian = Color(hex: "0D0E10")
    static let castHeader = Color(hex: "141416")
    static let castCoral = Color(hex: "FF453A")

    init(hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 255) / 255,
            green: Double((value >> 8) & 255) / 255,
            blue: Double(value & 255) / 255
        )
    }
}
