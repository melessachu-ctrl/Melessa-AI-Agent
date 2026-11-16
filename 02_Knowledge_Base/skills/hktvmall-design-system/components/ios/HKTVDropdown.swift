// HKTVmall Dropdown (Figma 3005:218, symbol 5690:356). Matches references/components/text-field.md.
// Closed field only. The menu is not part of this component.
// Pass icon-chevrondown-small-outlined when the app has it. The fallback mark is not an SF Symbol.

import SwiftUI

enum HKTVDropdownState {
    case placeholder, focus, filled, disabled
}

struct HKTVDropdown: View {
    var title: String = "Title"
    var value: String = ""
    var placeholder: String = "Default Hint"
    var size: HKTVFieldSize = .m
    var state: HKTVDropdownState = .placeholder
    var chevron: Image? = nil
    var action: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: HKTVSpacing.s8) {
            Text(title)
                .hktvText(HKTVText.body1Regular)
                .foregroundStyle(labelColor)
            Button(action: action) {
                HStack(spacing: HKTVSpacing.s8) {
                    Text(showsPlaceholder ? placeholder : value)
                        .hktvText(HKTVText.body1Regular)
                        .foregroundStyle(showsPlaceholder ? placeholderColor : valueColor)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let chevron {
                        chevron.renderingMode(.template).resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(valueColor)
                    } else {
                        HKTVDropdownChevron()
                            .stroke(valueColor, style: StrokeStyle(lineWidth: HKTVBorderWidth.regular, lineCap: .round, lineJoin: .round))
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.horizontal, HKTVSpacing.s16)
                .frame(height: size == .m ? 56 : 48)
                .background(fieldBackground, in: RoundedRectangle(cornerRadius: HKTVRadius.cardS))
                .overlay {
                    RoundedRectangle(cornerRadius: HKTVRadius.cardS)
                        .strokeBorder(borderColor, lineWidth: HKTVBorderWidth.regular)
                }
            }
            .buttonStyle(.plain)
            .disabled(state == .disabled)
        }
    }

    private var showsPlaceholder: Bool { value.isEmpty || state == .placeholder }

    private var labelColor: Color { state == .disabled ? HKTVColor.textDisable : HKTVColor.textPrimary }
    private var valueColor: Color { state == .disabled ? HKTVColor.textDisable : HKTVColor.textPrimary }
    private var placeholderColor: Color { state == .disabled ? HKTVColor.textDisable : HKTVColor.textPlaceholder }
    private var fieldBackground: Color { state == .disabled ? HKTVColor.backgroundGrey75 : HKTVColor.backgroundWhite }
    private var borderColor: Color { state == .focus ? HKTVColor.textPrimary : HKTVColor.strokeSecondary }
}

private struct HKTVDropdownChevron: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 4, y: rect.midY - 3))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 3))
        path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.midY - 3))
        return path
    }
}
