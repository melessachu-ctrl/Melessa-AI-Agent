// HKTVmall listing price (Figma 7083:2002). Hand-written to match references/components/price.md.
// Copy into the effective token root from CLAUDE.md / references/native-repo-map.md
// (e.g. DesignSystemComponent/ or next to HKTVTokens.swift). Do not overwrite an existing DS HKTVPrice.swift.
// PDP is a separate component and is not implemented here.
// Promotion text uses body-3-regular (12 Regular, same size as price-listing-rp, without strikethrough).
// The 85 badge is a caller-supplied image so this file does not invent badge colours. Its height is 14 in Figma and has no token.

import SwiftUI

enum HKTVPriceKind {
    case rp, sp, vip, gvip, dvip, ppp, cashback, greenLab, publicHousing, notForSale
}

enum HKTVPriceSize {
    case l, s
}

/// Listing price for search results and waterfall cards. Does not fetch an API.
struct HKTVPrice: View {
    var kind: HKTVPriceKind
    var size: HKTVPriceSize = .l
    var amount: Decimal = 0
    var originalAmount: Decimal? = nil
    var promotionText: String? = nil
    var notForSaleText: String = ""
    var kaLabel: String? = nil
    var badge: Image? = nil
    var unitAmount: Decimal? = nil
    var unitName: String? = nil
    var unitIsAverage: Bool = false
    var unitUsesChinese: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let ka = trimmed(kaLabel) {
                Text(ka)
                    .hktvText(HKTVText.body3Semibold)
                    .foregroundStyle(HKTVColor.textWhite)
                    .padding(.horizontal, HKTVSpacing.s4)
                    .padding(.vertical, HKTVSpacing.s2)
                    .background(HKTVColor.backgroundKaPrice, in: RoundedRectangle(cornerRadius: HKTVRadius.badgeS))
            }
            if kind == .notForSale {
                priceLine(notForSaleText, style: mainStyle, color: HKTVColor.textPrimary)
            } else {
                if let promotion = trimmed(promotionText) {
                    priceLine(promotion, style: HKTVText.body3Regular, color: HKTVColor.textSalePrice)
                } else if let originalAmount {
                    priceLine(HKTVPriceFormat.string(for: originalAmount), style: HKTVText.priceListingRp, color: HKTVColor.textTertiary)
                }
                HStack(alignment: .center, spacing: HKTVSpacing.s4) {
                    priceLine(HKTVPriceFormat.string(for: amount), style: mainStyle, color: mainColor)
                    if let badge {
                        badge
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 14)
                    }
                }
                if let unitAmount, let unit = trimmed(unitName) {
                    priceLine(HKTVPriceFormat.unit(amount: unitAmount, unit: unit, average: unitIsAverage, chinese: unitUsesChinese), style: HKTVText.body3Regular, color: HKTVColor.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var mainStyle: HKTVTextStyle {
        size == .l ? HKTVText.priceListingMain : HKTVText.priceListingMultiCol
    }

    private var mainColor: Color {
        switch kind {
        case .rp, .notForSale:
            return HKTVColor.textPrimary
        case .sp:
            return HKTVColor.textSalePrice
        case .vip:
            return HKTVColor.membershipPriceTextVip
        case .gvip:
            return HKTVColor.membershipPriceTextGvip
        case .dvip:
            return HKTVColor.membershipPriceTextDvip
        case .ppp:
            return HKTVColor.membershipPriceTextPpp
        case .cashback:
            return HKTVColor.buCashback
        case .greenLab:
            return HKTVColor.buGreenlab
        case .publicHousing:
            return HKTVColor.buPublicHousing
        }
    }

    private func priceLine(_ text: String, style: HKTVTextStyle, color: Color) -> some View {
        Text(text)
            .hktvText(style)
            .foregroundStyle(color)
            .lineLimit(2)
    }

    private func trimmed(_ value: String?) -> String? {
        let text = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? nil : text
    }
}

enum HKTVPriceFormat {
    /// One decimal and thousands separators, e.g. 289 -> "$289.0", 9999.2 -> "$9,999.2".
    static func string(for amount: Decimal) -> String {
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let tenths = NSDecimalNumber(decimal: amount)
            .multiplying(by: NSDecimalNumber(value: 10), withBehavior: handler)
            .int64Value
        let negative = tenths < 0
        let absolute = abs(tenths)
        let whole = grouped(absolute / 10)
        let fraction = absolute % 10
        return "\(negative ? "-" : "")$\(whole).\(fraction)"
    }

    static func unit(amount: Decimal, unit: String, average: Bool, chinese: Bool) -> String {
        let price = string(for: amount)
        if average {
            return chinese ? "平均 \(price)/\(unit)" : "Avg. \(price)/\(unit)"
        }
        return "\(price)/\(unit)"
    }

    private static func grouped(_ value: Int64) -> String {
        let digits = String(value)
        var result = ""
        for (index, character) in digits.reversed().enumerated() {
            if index > 0 && index % 3 == 0 {
                result.append(",")
            }
            result.append(character)
        }
        return String(result.reversed())
    }
}
