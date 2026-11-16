// HKTVmall Text Field (Figma 3005:218, symbol 5686:130). Matches references/components/text-field.md.
// Reference file for writing UI. Do not scaffold a whole DS into the app.
// Clear icon colour is primitive neutral-200. Pass icon-on-textfieldclear-regular-filled when the app has it.

import SwiftUI

enum HKTVFieldSize {
    case m, s
}

enum HKTVTextFieldState {
    case placeholder, focus, typing, filled, error, errorTyping, disabled
}

struct HKTVTextField: View {
    var title: String = "Title"
    var text: String = ""
    var placeholder: String = "Default Hint"
    var size: HKTVFieldSize = .m
    var state: HKTVTextFieldState = .placeholder
    var message: String? = nil
    var showsPrefix: Bool = false
    var prefix: String = "$"
    var isSecure: Bool = false
    var clearIcon: Image? = nil
    var secureIcon: Image? = nil
    var onClear: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: HKTVSpacing.s8) {
            Text(title)
                .hktvText(HKTVText.body1Regular)
                .foregroundStyle(labelColor)
            VStack(alignment: .leading, spacing: HKTVSpacing.s4) {
                field
                if let message, showsMessage {
                    Text(message)
                        .hktvText(HKTVText.body2Regular)
                        .foregroundStyle(HKTVColor.textDanger)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var field: some View {
        HStack(spacing: HKTVSpacing.s8) {
            if showsPrefix {
                Text(prefix)
                    .hktvText(HKTVText.body1Regular)
                    .foregroundStyle(valueColor)
            }
            Group {
                if isSecure && !showsPlaceholder {
                    HStack(spacing: HKTVSpacing.s4) {
                        ForEach(0..<8, id: \.self) { _ in
                            Circle().fill(valueColor).frame(width: 6, height: 6)
                        }
                    }
                } else {
                    Text(showsPlaceholder ? placeholder : text)
                        .hktvText(HKTVText.body1Regular)
                        .foregroundStyle(showsPlaceholder ? placeholderColor : valueColor)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if showsCaret {
                Rectangle()
                    .fill(HKTVColor.brandPrimary)
                    .frame(width: HKTVBorderWidth.regular, height: 22)
            }
            if isSecure {
                iconSlot(secureIcon) { HKTVFieldMark.hide }
            }
            if showsClear {
                Button(action: onClear) {
                    iconSlot(clearIcon) { HKTVFieldMark.clear }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HKTVSpacing.s16)
        .frame(height: size == .m ? 56 : 48)
        .background(fieldBackground, in: RoundedRectangle(cornerRadius: HKTVRadius.cardS))
        .overlay {
            RoundedRectangle(cornerRadius: HKTVRadius.cardS)
                .strokeBorder(borderColor, lineWidth: HKTVBorderWidth.regular)
        }
        .allowsHitTesting(state != .disabled)
    }

    private var showsPlaceholder: Bool {
        switch state {
        case .placeholder, .focus, .disabled:
            return text.isEmpty
        default:
            return text.isEmpty
        }
    }

    private var showsCaret: Bool {
        state == .focus || state == .typing || state == .errorTyping
    }

    private var showsClear: Bool {
        state == .error || state == .errorTyping
    }

    private var showsMessage: Bool {
        state == .error || state == .errorTyping
    }

    private var labelColor: Color {
        state == .disabled ? HKTVColor.textDisable : HKTVColor.textPrimary
    }

    private var valueColor: Color {
        state == .disabled ? HKTVColor.textDisable : HKTVColor.textPrimary
    }

    private var placeholderColor: Color {
        state == .disabled ? HKTVColor.textDisable : HKTVColor.textPlaceholder
    }

    private var fieldBackground: Color {
        state == .disabled ? HKTVColor.backgroundGrey75 : HKTVColor.backgroundWhite
    }

    private var borderColor: Color {
        switch state {
        case .focus, .typing:
            return HKTVColor.textPrimary
        case .error, .errorTyping:
            return HKTVColor.textDanger
        default:
            return HKTVColor.strokeSecondary
        }
    }

    @ViewBuilder
    private func iconSlot(_ image: Image?, @ViewBuilder fallback: () -> some View) -> some View {
        if let image {
            image.renderingMode(.template).resizable().scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(HKTVPrimitive.neutral200)
        } else {
            fallback()
                .frame(width: 24, height: 24)
        }
    }
}

enum HKTVFieldMark {
    static var clear: some View {
        Circle()
            .strokeBorder(HKTVPrimitive.neutral200, lineWidth: HKTVBorderWidth.regular)
            .overlay {
                Path { path in
                    path.move(to: CGPoint(x: 8, y: 8))
                    path.addLine(to: CGPoint(x: 16, y: 16))
                    path.move(to: CGPoint(x: 16, y: 8))
                    path.addLine(to: CGPoint(x: 8, y: 16))
                }
                .stroke(HKTVPrimitive.neutral200, lineWidth: HKTVBorderWidth.regular)
            }
    }

    static var hide: some View {
        Circle()
            .strokeBorder(HKTVColor.textPrimary, lineWidth: HKTVBorderWidth.regular)
    }

    static var chevron: some View {
        Path { path in
            path.move(to: CGPoint(x: 5, y: 8))
            path.addLine(to: CGPoint(x: 10, y: 13))
            path.addLine(to: CGPoint(x: 15, y: 8))
        }
        .stroke(HKTVColor.textPrimary, style: StrokeStyle(lineWidth: HKTVBorderWidth.regular, lineCap: .round, lineJoin: .round))
        .frame(width: 20, height: 20)
    }
}
