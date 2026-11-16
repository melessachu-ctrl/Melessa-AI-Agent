// HKTVmall Cart Button (Figma 7088:1450). Matches references/components/cart-button.md.
// Reference file for writing UI. Do not scaffold a whole DS into the app.
// Outlined Cart (Primary) and Outlined Cart (Secondary) are intentionally absent.
// Cart (Default) is Rounded only; an oval style still draws rounded so it does not recreate the excluded primary.
// Sizes 36 / 32 and icon boxes 24.75 / 22 / 16 / 14 have no token.
// Cashback uses the primitive tokens orange-75 and yellow-800. No semantic token has those exact colours.

import SwiftUI

enum HKTVCartButtonType {
    case cart, discount, cashback, notifyMe, favourite
}

enum HKTVCartButtonSize {
    case l, s
}

enum HKTVCartButtonStyle {
    case oval, rounded
}

struct HKTVCartButton: View {
    var type: HKTVCartButtonType = .cart
    var size: HKTVCartButtonSize = .l
    var style: HKTVCartButtonStyle = .rounded
    var icon: Image? = nil
    var action: () -> Void = {}

    var body: some View {
        let side: CGFloat = size == .l ? 36 : 32
        let corner: CGFloat = resolvedStyle == .oval ? HKTVRadius.full : HKTVRadius.cardXs
        Button(action: action) {
            ZStack {
                content
            }
            .frame(width: side, height: side)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: corner))
            .overlay {
                if type == .favourite {
                    RoundedRectangle(cornerRadius: corner)
                        .strokeBorder(HKTVColor.strokeSecondary, lineWidth: HKTVBorderWidth.regular)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityName)
    }

    private var resolvedStyle: HKTVCartButtonStyle {
        type == .cart ? .rounded : style
    }

    private var backgroundColor: Color {
        switch type {
        case .cart:
            return HKTVColor.brandPrimary
        case .discount:
            return HKTVColor.textHighlight
        case .cashback:
            return HKTVPrimitive.orange75
        case .notifyMe:
            return HKTVColor.backgroundDisable
        case .favourite:
            return HKTVColor.backgroundWhite
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .cart, .discount:
            return HKTVColor.textWhite
        case .cashback:
            return HKTVPrimitive.yellow800
        case .notifyMe:
            return HKTVColor.textPrimary
        case .favourite:
            return HKTVColor.textSecondary
        }
    }

    @ViewBuilder
    private var content: some View {
        if type == .discount {
            VStack(spacing: 0) {
                Text("大手")
                Text("折扣")
            }
            .hktvText(HKTVText.caption2Semibold)
            .foregroundStyle(HKTVColor.textWhite)
            .multilineTextAlignment(.center)
        } else if let icon {
            icon
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSide, height: iconSide)
                .foregroundStyle(foregroundColor)
        }
    }

    private var iconSide: CGFloat {
        if type == .cart {
            return size == .l ? 24.75 : 22
        }
        return size == .l ? 16 : 14
    }

    private var accessibilityName: String {
        switch type {
        case .cart: return "加入購物車"
        case .discount: return "大手折扣"
        case .cashback: return "Cashback"
        case .notifyMe: return "到貨通知"
        case .favourite: return "收藏"
        }
    }
}
