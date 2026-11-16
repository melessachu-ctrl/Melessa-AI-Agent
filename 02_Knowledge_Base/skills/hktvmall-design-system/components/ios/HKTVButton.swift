// HKTVmall Button (Figma 3135:812). Hand-written to match references/components/button.md.
// Copy into the effective token root from CLAUDE.md / references/native-repo-map.md
// (e.g. DesignSystemComponent/ or next to HKTVTokens.swift). Do not overwrite a DS SwiftUI HKTVButton.
// UIKit legacy HKTVButton (UIButton subclass) is Conflict — ask before copy or rename; do not treat as DS.
// Icon sizes (22 / 20 / 18) have no token yet; they follow the Button spec.

import SwiftUI

enum HKTVButtonAppearance {
    case filled, secondary, outline, text
}

enum HKTVButtonShape {
    case rounded, capsule
}

enum HKTVButtonSize {
    case l, m, s, xs
}

enum HKTVButtonState {
    case enable, disabled, loading
}

/// Design-system button. Does not apply a pressed or focus colour; Figma has no such variant.
struct HKTVButton: View {
    var title: String = "Button"
    var appearance: HKTVButtonAppearance = .filled
    var shape: HKTVButtonShape = .rounded
    var size: HKTVButtonSize = .l
    var state: HKTVButtonState = .enable
    var startIcon: Image? = nil
    var endIcon: Image? = nil
    var action: () -> Void = {}

    var body: some View {
        let palette = HKTVButtonPalette(appearance: appearance, state: state)
        let metrics = HKTVButtonMetrics(size: size, shape: shape, appearance: appearance)
        Button(action: action) {
            HStack(spacing: HKTVSpacing.s4) {
                if let startIcon {
                    icon(startIcon, side: metrics.startIcon, color: palette.foreground)
                }
                if state == .loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(palette.foreground)
                        .frame(width: metrics.text.size, height: metrics.text.size)
                } else {
                    Text(title)
                        .hktvText(metrics.text)
                        .foregroundStyle(palette.foreground)
                        .lineLimit(1)
                }
                if let endIcon {
                    icon(endIcon, side: metrics.endIcon, color: palette.foreground)
                }
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .frame(minWidth: metrics.minWidth)
            .frame(height: metrics.height)
            .background(palette.background, in: RoundedRectangle(cornerRadius: metrics.cornerRadius))
            .overlay {
                if palette.drawsBorder {
                    RoundedRectangle(cornerRadius: metrics.cornerRadius)
                        .strokeBorder(palette.border, lineWidth: HKTVBorderWidth.regular)
                }
            }
        }
        .buttonStyle(.plain)
        .allowsHitTesting(state == .enable)
        .accessibilityLabel(title)
    }

    private func icon(_ image: Image, side: CGFloat, color: Color) -> some View {
        image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: side, height: side)
            .foregroundStyle(color)
    }
}

private struct HKTVButtonPalette {
    let background: Color
    let foreground: Color
    let border: Color
    let drawsBorder: Bool

    init(appearance: HKTVButtonAppearance, state: HKTVButtonState) {
        let visual: HKTVButtonState = state == .loading ? .enable : state
        switch (appearance, visual) {
        case (_, .disabled):
            foreground = HKTVColor.textDisable
            switch appearance {
            case .filled, .secondary:
                background = HKTVColor.backgroundGrey75
                border = .clear
                drawsBorder = false
            case .outline:
                background = .clear
                border = HKTVColor.strokeSecondary
                drawsBorder = true
            case .text:
                background = .clear
                border = .clear
                drawsBorder = false
            }
        case (.filled, _):
            background = HKTVColor.brandPrimary
            foreground = HKTVColor.textWhite
            border = .clear
            drawsBorder = false
        case (.secondary, _):
            background = HKTVColor.backgroundGreen75
            foreground = HKTVColor.brandPrimary
            border = .clear
            drawsBorder = false
        case (.outline, _):
            background = .clear
            foreground = HKTVColor.brandPrimary
            border = HKTVColor.brandPrimary
            drawsBorder = true
        case (.text, _):
            background = .clear
            foreground = HKTVColor.brandPrimary
            border = .clear
            drawsBorder = false
        }
    }
}

private struct HKTVButtonMetrics {
    let height: CGFloat?
    let minWidth: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let cornerRadius: CGFloat
    let startIcon: CGFloat
    let endIcon: CGFloat
    let text: HKTVTextStyle

    init(size: HKTVButtonSize, shape: HKTVButtonShape, appearance: HKTVButtonAppearance) {
        let large = size == .l || size == .m
        text = appearance == .text
            ? (large ? HKTVText.body1Regular : HKTVText.body2Regular)
            : (large ? HKTVText.titleSemibold : HKTVText.body2Semibold)
        startIcon = large ? 22 : 18
        endIcon = large ? 20 : 18
        switch (size, shape) {
        case (.l, .rounded):
            height = 52
            minWidth = 88
            horizontalPadding = HKTVSpacing.s16
            verticalPadding = 0
            cornerRadius = HKTVRadius.cardS
        case (.l, .capsule):
            height = 52
            minWidth = 84
            horizontalPadding = HKTVSpacing.s20
            verticalPadding = 0
            cornerRadius = HKTVRadius.full
        case (.m, .rounded):
            height = 44
            minWidth = 76
            horizontalPadding = HKTVSpacing.s12
            verticalPadding = 0
            cornerRadius = HKTVRadius.cardS
        case (.m, .capsule):
            height = 44
            minWidth = 72
            horizontalPadding = HKTVSpacing.s16
            verticalPadding = 0
            cornerRadius = HKTVRadius.full
        case (.s, .rounded):
            height = 36
            minWidth = 64
            horizontalPadding = HKTVSpacing.s8
            verticalPadding = 0
            cornerRadius = HKTVRadius.buttonS
        case (.s, .capsule):
            height = 36
            minWidth = 64
            horizontalPadding = HKTVSpacing.s12
            verticalPadding = 0
            cornerRadius = HKTVRadius.full
        case (.xs, .rounded):
            height = nil
            minWidth = 48
            horizontalPadding = HKTVSpacing.s8
            verticalPadding = HKTVSpacing.s6
            cornerRadius = HKTVRadius.cardXs
        case (.xs, .capsule):
            height = nil
            minWidth = 48
            horizontalPadding = HKTVSpacing.s8
            verticalPadding = HKTVSpacing.s6
            cornerRadius = HKTVRadius.full
        }
    }
}
