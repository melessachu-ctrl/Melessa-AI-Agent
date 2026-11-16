// HKTVmall listing price (Figma 7083:2002). Hand-written to match references/components/price.md.
// Copy into the effective token package from CLAUDE.md / references/native-repo-map.md
// (HKTVTokens.kt package or mall core/ui/.../theme/). Change this package to match.
// Do not overwrite an existing DS HKTVPrice.kt.
// PDP is a separate component and is not implemented here.
// Promotion text uses Body3Regular (12 Regular, same size as PriceListingRp, without strikethrough).
// The 85 badge is a caller-supplied image so this file does not invent badge colours. Its height is 14 in Figma and has no token.

package com.hktvmall.designsystem

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.text.BasicText
import java.math.BigDecimal
import java.math.RoundingMode

enum class HKTVPriceKind {
    RP, SP, VIP, GVIP, DVIP, PPP, Cashback, GreenLab, PublicHousing, NotForSale,
}

enum class HKTVPriceSize {
    L, S,
}

@Composable
fun HKTVPrice(
    kind: HKTVPriceKind,
    amount: BigDecimal = BigDecimal.ZERO,
    size: HKTVPriceSize = HKTVPriceSize.L,
    originalAmount: BigDecimal? = null,
    promotionText: String? = null,
    notForSaleText: String = "",
    kaLabel: String? = null,
    badge: ImageVector? = null,
    unitAmount: BigDecimal? = null,
    unitName: String? = null,
    unitIsAverage: Boolean = false,
    unitUsesChinese: Boolean = true,
    modifier: Modifier = Modifier,
) {
    val mainStyle = if (size == HKTVPriceSize.L) HKTVText.PriceListingMain else HKTVText.PriceListingMultiCol
    Column(modifier = modifier, horizontalAlignment = Alignment.Start) {
        val ka = kaLabel?.trim().orEmpty()
        if (ka.isNotEmpty()) {
            BasicText(
                text = ka,
                style = HKTVText.Body3Semibold.copy(color = HKTVColor.TextWhite),
                modifier = Modifier
                    .background(HKTVColor.BackgroundKaPrice, RoundedCornerShape(HKTVRadius.BadgeS))
                    .padding(horizontal = HKTVSpacing.S4, vertical = HKTVSpacing.S2),
            )
        }
        if (kind == HKTVPriceKind.NotForSale) {
            PriceLine(notForSaleText, mainStyle, HKTVColor.TextPrimary)
        } else {
            val promotion = promotionText?.trim().orEmpty()
            if (promotion.isNotEmpty()) {
                PriceLine(promotion, HKTVText.Body3Regular, HKTVColor.TextSalePrice)
            } else if (originalAmount != null) {
                PriceLine(hktvFormatPrice(originalAmount), HKTVText.PriceListingRp, HKTVColor.TextTertiary)
            }
            Row(
                horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S4),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                PriceLine(hktvFormatPrice(amount), mainStyle, kindColor(kind))
                if (badge != null) {
                    Image(
                        imageVector = badge,
                        contentDescription = null,
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.height(14.dp),
                    )
                }
            }
            val unit = unitName?.trim().orEmpty()
            if (unitAmount != null && unit.isNotEmpty()) {
                PriceLine(
                    hktvFormatUnit(unitAmount, unit, unitIsAverage, unitUsesChinese),
                    HKTVText.Body3Regular,
                    HKTVColor.TextTertiary,
                )
            }
        }
    }
}

@Composable
private fun PriceLine(text: String, style: TextStyle, color: Color) {
    BasicText(text = text, style = style.copy(color = color), maxLines = 2)
}

private fun kindColor(kind: HKTVPriceKind): Color = when (kind) {
    HKTVPriceKind.RP, HKTVPriceKind.NotForSale -> HKTVColor.TextPrimary
    HKTVPriceKind.SP -> HKTVColor.TextSalePrice
    HKTVPriceKind.VIP -> HKTVColor.MembershipPriceTextVip
    HKTVPriceKind.GVIP -> HKTVColor.MembershipPriceTextGvip
    HKTVPriceKind.DVIP -> HKTVColor.MembershipPriceTextDvip
    HKTVPriceKind.PPP -> HKTVColor.MembershipPriceTextPpp
    HKTVPriceKind.Cashback -> HKTVColor.BuCashback
    HKTVPriceKind.GreenLab -> HKTVColor.BuGreenlab
    HKTVPriceKind.PublicHousing -> HKTVColor.BuPublicHousing
}

/** One decimal and thousands separators, e.g. 289 -> "$289.0", 9999.2 -> "$9,999.2". */
fun hktvFormatPrice(amount: BigDecimal): String {
    val rounded = amount.setScale(1, RoundingMode.HALF_UP)
    val negative = rounded.signum() < 0
    val plain = rounded.abs().toPlainString()
    val dot = plain.indexOf('.')
    val whole = if (dot >= 0) plain.substring(0, dot) else plain
    val fraction = if (dot >= 0) plain.substring(dot + 1) else "0"
    val grouped = whole.reversed().chunked(3).joinToString(",").reversed()
    return (if (negative) "-$" else "$") + grouped + "." + fraction
}

fun hktvFormatUnit(amount: BigDecimal, unit: String, average: Boolean, chinese: Boolean): String {
    val price = hktvFormatPrice(amount)
    return if (average) {
        if (chinese) "平均 $price/$unit" else "Avg. $price/$unit"
    } else {
        "$price/$unit"
    }
}
