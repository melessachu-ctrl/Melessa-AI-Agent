// HKTVmall Cart Button (Figma 7088:1450). Matches references/components/cart-button.md.
// Reference file for writing UI. Do not scaffold a whole DS into the app.
// Outlined Cart (Primary) and Outlined Cart (Secondary) are intentionally absent.
// Cart (Default) is Rounded only.
// Sizes 36 / 32 and icon boxes 24.75 / 22 / 16 / 14 have no token.
// Cashback uses the primitive tokens orange-75 and yellow-800. No semantic token has those exact colours.

package com.hktvmall.designsystem

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.foundation.text.BasicText

enum class HKTVCartButtonType {
    Cart, Discount, Cashback, NotifyMe, Favourite,
}

enum class HKTVCartButtonSize {
    L, S,
}

enum class HKTVCartButtonStyle {
    Oval, Rounded,
}

@Composable
fun HKTVCartButton(
    type: HKTVCartButtonType = HKTVCartButtonType.Cart,
    size: HKTVCartButtonSize = HKTVCartButtonSize.L,
    style: HKTVCartButtonStyle = HKTVCartButtonStyle.Rounded,
    icon: ImageVector? = null,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {},
) {
    val resolved = if (type == HKTVCartButtonType.Cart) HKTVCartButtonStyle.Rounded else style
    val side = if (size == HKTVCartButtonSize.L) 36.dp else 32.dp
    val corner = RoundedCornerShape(if (resolved == HKTVCartButtonStyle.Oval) HKTVRadius.Full else HKTVRadius.CardXs)
    val background = when (type) {
        HKTVCartButtonType.Cart -> HKTVColor.BrandPrimary
        HKTVCartButtonType.Discount -> HKTVColor.TextHighlight
        HKTVCartButtonType.Cashback -> HKTVPrimitive.Orange75
        HKTVCartButtonType.NotifyMe -> HKTVColor.BackgroundDisable
        HKTVCartButtonType.Favourite -> HKTVColor.BackgroundWhite
    }
    val foreground = when (type) {
        HKTVCartButtonType.Cart, HKTVCartButtonType.Discount -> HKTVColor.TextWhite
        HKTVCartButtonType.Cashback -> HKTVPrimitive.Yellow800
        HKTVCartButtonType.NotifyMe -> HKTVColor.TextPrimary
        HKTVCartButtonType.Favourite -> HKTVColor.TextSecondary
    }
    val iconSide = when {
        type == HKTVCartButtonType.Cart && size == HKTVCartButtonSize.L -> 24.75.dp
        type == HKTVCartButtonType.Cart -> 22.dp
        size == HKTVCartButtonSize.L -> 16.dp
        else -> 14.dp
    }
    Box(
        modifier = modifier
            .size(side)
            .clip(corner)
            .background(background)
            .then(
                if (type == HKTVCartButtonType.Favourite) {
                    Modifier.border(HKTVBorderWidth.Regular, HKTVColor.StrokeSecondary, corner)
                } else {
                    Modifier
                }
            )
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick,
            )
            .semantics { contentDescription = accessibilityName(type) },
        contentAlignment = Alignment.Center,
    ) {
        if (type == HKTVCartButtonType.Discount) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                BasicText("大手", style = HKTVText.Caption2Semibold.copy(color = HKTVColor.TextWhite))
                BasicText("折扣", style = HKTVText.Caption2Semibold.copy(color = HKTVColor.TextWhite))
            }
        } else if (icon != null) {
            Image(
                imageVector = icon,
                contentDescription = null,
                colorFilter = ColorFilter.tint(foreground),
                contentScale = ContentScale.Fit,
                modifier = Modifier.size(iconSide),
            )
        }
    }
}

private fun accessibilityName(type: HKTVCartButtonType): String = when (type) {
    HKTVCartButtonType.Cart -> "加入購物車"
    HKTVCartButtonType.Discount -> "大手折扣"
    HKTVCartButtonType.Cashback -> "Cashback"
    HKTVCartButtonType.NotifyMe -> "到貨通知"
    HKTVCartButtonType.Favourite -> "收藏"
}
