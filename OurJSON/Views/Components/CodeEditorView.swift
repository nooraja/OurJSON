import AppKit
import SwiftUI

// MARK: - Native Code Editor

struct CodeEditorView: NSViewRepresentable {
    @Binding var text: String
    let isEditable: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = makeScrollView()
        let textView = makeTextView()

        scrollView.documentView = textView
        scrollView.setAccessibilityIdentifier(isEditable ? "ourjson.codeEditor.source" : "ourjson.codeEditor.output")
        textView.setAccessibilityIdentifier(isEditable ? "ourjson.codeEditor.source.text" : "ourjson.codeEditor.output.text")

        let lineNumberRuler = LineNumberRulerView(
            scrollView: scrollView,
            textView: textView
        )
        lineNumberRuler.setAccessibilityIdentifier(isEditable ? "ourjson.codeEditor.source.lineNumbers" : "ourjson.codeEditor.output.lineNumbers")

        scrollView.verticalRulerView = lineNumberRuler
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true

        context.coordinator.textView = textView
        context.coordinator.lineNumberRuler = lineNumberRuler
        textView.delegate = context.coordinator

        textView.setSelectedRange(NSRange(location: 0, length: 0))
        scrollView.contentView.scroll(to: .zero)
        scrollView.reflectScrolledClipView(scrollView.contentView)

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.text = $text

        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }

        textView.isEditable = isEditable

        if textView.string != text {
            textView.string = text
            context.coordinator.lineNumberRuler?.needsDisplay = true
        }
    }

    // MARK: View Construction

    private func makeScrollView() -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .castEditorBackground
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        return scrollView
    }

    private func makeTextView() -> NSTextView {
        let textView = NSTextView()
        textView.string = text
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = isEditable
        textView.drawsBackground = true
        textView.backgroundColor = .castEditorBackground
        textView.textColor = .castEditorText
        textView.insertionPointColor = .white
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textContainerInset = NSSize(width: 12, height: 10)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width]
        textView.minSize = .zero
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        return textView
    }
}

// MARK: - Text Coordinator

extension CodeEditorView {
    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        weak var textView: NSTextView?
        fileprivate weak var lineNumberRuler: LineNumberRulerView?

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else {
                return
            }

            if text.wrappedValue != textView.string {
                text.wrappedValue = textView.string
            }

            lineNumberRuler?.needsDisplay = true
        }
    }
}

// MARK: - Line Number Ruler

private final class LineNumberRulerView: NSRulerView {
    private weak var textView: NSTextView?
    private let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)

    init(scrollView: NSScrollView, textView: NSTextView) {
        self.textView = textView
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        clientView = textView
        ruleThickness = 42
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        NSColor.castGutterBackground.setFill()
        bounds.fill()

        guard
            let textView,
            let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer
        else {
            return
        }

        updateRuleThickness(for: textView.string)

        let visibleRect = textView.visibleRect
        let glyphRange = layoutManager.glyphRange(
            forBoundingRect: visibleRect,
            in: textContainer
        )

        var lineNumber = firstVisibleLineNumber(
            glyphRange: glyphRange,
            layoutManager: layoutManager,
            text: textView.string
        )

        layoutManager.enumerateLineFragments(
            forGlyphRange: glyphRange
        ) { [weak self] rect, _, _, _, _ in
            self?.draw(
                lineNumber: lineNumber,
                lineRect: rect,
                textView: textView
            )
            lineNumber += 1
        }
    }

    private func firstVisibleLineNumber(
        glyphRange: NSRange,
        layoutManager: NSLayoutManager,
        text: String
    ) -> Int {
        let characterIndex = layoutManager.characterIndexForGlyph(
            at: glyphRange.location
        )
        let prefix = (text as NSString).substring(to: characterIndex)
        return prefix.reduce(into: 1) { count, character in
            if character == "\n" {
                count += 1
            }
        }
    }

    private func draw(
        lineNumber: Int,
        lineRect: NSRect,
        textView: NSTextView
    ) {
        let label = NSAttributedString(
            string: "\(lineNumber)",
            attributes: [
                .font: font,
                .foregroundColor: NSColor.castGutterText
            ]
        )

        let labelSize = label.size()
        let textOrigin = textView.textContainerOrigin
        let pointInTextView = NSPoint(
            x: 0,
            y: lineRect.minY + textOrigin.y
        )
        let convertedY = convert(pointInTextView, from: textView).y
        let gutterX = ruleThickness - 8 - labelSize.width

        label.draw(
            at: NSPoint(
                x: gutterX,
                y: convertedY + (lineRect.height - labelSize.height) / 2
            )
        )
    }

    private func updateRuleThickness(for text: String) {
        let lineCount = max(
            1,
            text.split(
                separator: "\n",
                omittingEmptySubsequences: false
            ).count
        )
        let digitCount = String(lineCount).count
        let sampleLabel = String(repeating: "8", count: digitCount)
        let labelWidth = (sampleLabel as NSString).size(
            withAttributes: [.font: font]
        ).width
        ruleThickness = max(42, ceil(labelWidth) + 16)
    }
}

// MARK: - Editor Colors

private extension NSColor {
    static let castEditorBackground = NSColor(
        calibratedRed: 13 / 255,
        green: 14 / 255,
        blue: 16 / 255,
        alpha: 1
    )

    static let castGutterBackground = NSColor(
        calibratedRed: 16 / 255,
        green: 17 / 255,
        blue: 19 / 255,
        alpha: 1
    )

    static let castEditorText = NSColor(
        calibratedWhite: 0.9,
        alpha: 1
    )

    static let castGutterText = NSColor(
        calibratedWhite: 0.38,
        alpha: 1
    )
}
