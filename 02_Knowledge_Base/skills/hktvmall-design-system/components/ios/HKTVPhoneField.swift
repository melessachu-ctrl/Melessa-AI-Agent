// HKTVmall Phone field (Figma 3005:218, symbol 5686:231). Matches references/components/text-field.md.
// Country code and number are passed in. This set has no Disabled state.
// Pass icon-chevrondown-small-outlined and icon-on-textfieldclear-regular-filled when the app has them.

import SwiftUI

enum HKTVPhoneFieldState {
    case placeholder, focus, typing, filled, error
}

struct HKTVPhoneField: View {
    var title: String = "手機號碼"
    var countryCode: String = "+852"
    var number: String = ""
    var placeholder: String = "手機號碼"
    var size: HKTVFieldSize = .m
    var state: HKTVPhoneFieldState = .placeholder
    var message: String? = nil
    var chevron: Image? = nil
    var clearIcon: Image? = nil
    var onCountry: () -> Void = {}
    var onClear: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: HKTVSpacing.s8) {
            Text(title)
                .hktvText(HKTVText.body1Regular)
                .foregroundStyle(HKTVColor.textPrimary)
            VStack(alignment: .leading, spacing: HKTVSpacing.s4) {
                HStack(alignment: .center, spacing: HKTVSpacing.s8) {
                    country
                    numberField
                }
                if let message, state == .error {
                    Text(message)
                        .hktvText(HKTVText.body2Regular)
                        .foregroundStyle(HKTVColor.textDanger)
                }
            }
        }
    }

    private var country: some View {
        Button(action: onCountry) {
            HStack(spacing: HKTVSpacing.s8) {
                Text(countryCode)
                    .hktvText(HKTVText.body1Regular)
                    .foregroundStyle(HKTVColor.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: HKTVSpacing.s4)
                chevronMark
            }
            .padding(.horizontal, HKTVSpacing.s16)
            .frame(width: 109, height: fieldHeight)
            .background(HKTVColor.backgroundWhite, in: RoundedRectangle(cornerRadius: HKTVRadius.cardS))
            .overlay {
                RoundedRectangle(cornerRadius: HKTVRadius.cardS)
                    .strokeBorder(borderColor, lineWidth: HKTVBorderWidth.regular)
            }
        }
        .buttonStyle(.plain)
    }

    private var numberField: some View {
        HStack(spacing: HKTVSpacing.s8) {
            Text(showsPlaceholder ? placeholder : number)
                .hktvText(HKTVText.body1Regular)
                .foregroundStyle(showsPlaceholder ? HKTVColor.textPlaceholder : HKTVColor.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            if state == .focus || state == .typing {
                Rectangle()
                    .fill(HKTVColor.brandPrimary)
                    .frame(width: HKTVBorderWidth.regular, height: 22)
            }
            if state == .error {
                Button(action: onClear) {
                    if let clearIcon {
                        clearIcon.renderingMode(.template).resizable().scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(HKTVPrimitive.neutral200)
                    } else {
                        HKTVPhoneClearMark()
                            .frame(width: 24, height: 24)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HKTVSpacing.s16)
        .frame(maxWidth: .infinity)
        .frame(height: fieldHeight)
        .background(HKTVColor.backgroundWhite, in: RoundedRectangle(cornerRadius: HKTVRadius.cardS))
        .overlay {
            RoundedRectangle(cornerRadius: HKTVRadius.cardS)
                .strokeBorder(borderColor, lineWidth: HKTVBorderWidth.regular)
        }
    }

    @ViewBuilder
    private var chevronMark: some View {
        if let chevron {
            chevron.renderingMode(.template).resizable().scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(HKTVColor.textPrimary)
        } else {
            HKTVPhoneChevron()
                .stroke(HKTVColor.textPrimary, style: StrokeStyle(lineWidth: HKTVBorderWidth.regular, lineCap: .round, lineJoin: .round))
                .frame(width: 20, height: 20)
        }
    }

    private var fieldHeight: CGFloat { size == .m ? 56 : 48 }
    private var showsPlaceholder: Bool { number.isEmpty }
    private var borderColor: Color {
        switch state {
        case .focus, .typing:
            return HKTVColor.textPrimary
        case .error:
            return HKTVColor.textDanger
        default:
            return HKTVColor.strokeSecondary
        }
    }
}

private struct HKTVPhoneChevron: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 4, y: rect.midY - 3))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 3))
        path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.midY - 3))
        return path
    }
}

private struct HKTVPhoneClearMark: View {
    var body: some View {
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
}
