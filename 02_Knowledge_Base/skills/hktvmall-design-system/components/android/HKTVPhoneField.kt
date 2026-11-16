// HKTVmall Phone field (Figma 3005:218, symbol 5686:231). Matches references/components/text-field.md.
// This set has no Disabled state.

package com.hktvmall.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.foundation.Image
import androidx.compose.foundation.text.BasicText

enum class HKTVPhoneFieldState { Placeholder, Focus, Typing, Filled, Error }

@Composable
fun HKTVPhoneField(
    title: String = "手機號碼",
    countryCode: String = "+852",
    number: String = "",
    placeholder: String = "手機號碼",
    size: HKTVFieldSize = HKTVFieldSize.M,
    state: HKTVPhoneFieldState = HKTVPhoneFieldState.Placeholder,
    message: String? = null,
    chevron: ImageVector? = null,
    clearIcon: ImageVector? = null,
    modifier: Modifier = Modifier,
    onCountry: () -> Unit = {},
    onClear: () -> Unit = {},
) {
    val border = when (state) {
        HKTVPhoneFieldState.Focus, HKTVPhoneFieldState.Typing -> HKTVColor.TextPrimary
        HKTVPhoneFieldState.Error -> HKTVColor.TextDanger
        else -> HKTVColor.StrokeSecondary
    }
    val height = if (size == HKTVFieldSize.M) 56.dp else 48.dp
    val showPlaceholder = number.isEmpty()
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(HKTVSpacing.S8)) {
        BasicText(title, style = HKTVText.Body1Regular.copy(color = HKTVColor.TextPrimary))
        Column(verticalArrangement = Arrangement.spacedBy(HKTVSpacing.S4)) {
            Row(horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S8), verticalAlignment = Alignment.CenterVertically) {
                Row(
                    modifier = Modifier
                        .width(109.dp)
                        .height(height)
                        .background(HKTVColor.BackgroundWhite, RoundedCornerShape(HKTVRadius.CardS))
                        .border(HKTVBorderWidth.Regular, border, RoundedCornerShape(HKTVRadius.CardS))
                        .clickable(onClick = onCountry)
                        .padding(horizontal = HKTVSpacing.S16),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S4),
                ) {
                    BasicText(countryCode, style = HKTVText.Body1Regular.copy(color = HKTVColor.TextPrimary), modifier = Modifier.weight(1f))
                    PhoneChevron(chevron, HKTVColor.TextPrimary)
                }
                Row(
                    modifier = Modifier
                        .weight(1f)
                        .height(height)
                        .background(HKTVColor.BackgroundWhite, RoundedCornerShape(HKTVRadius.CardS))
                        .border(HKTVBorderWidth.Regular, border, RoundedCornerShape(HKTVRadius.CardS))
                        .padding(horizontal = HKTVSpacing.S16),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S8),
                ) {
                    BasicText(
                        if (showPlaceholder) placeholder else number,
                        style = HKTVText.Body1Regular.copy(color = if (showPlaceholder) HKTVColor.TextPlaceholder else HKTVColor.TextPrimary),
                        maxLines = 1,
                        modifier = Modifier.weight(1f),
                    )
                    if (state == HKTVPhoneFieldState.Focus || state == HKTVPhoneFieldState.Typing) {
                        Box(Modifier.width(HKTVBorderWidth.Regular).height(22.dp).background(HKTVColor.BrandPrimary))
                    }
                    if (state == HKTVPhoneFieldState.Error) {
                        Box(Modifier.clickable(onClick = onClear)) {
                            FieldIcon(clearIcon, HKTVPrimitive.Neutral200)
                        }
                    }
                }
            }
            if (state == HKTVPhoneFieldState.Error && !message.isNullOrEmpty()) {
                BasicText(message, style = HKTVText.Body2Regular.copy(color = HKTVColor.TextDanger))
            }
        }
    }
}

@Composable
private fun PhoneChevron(icon: ImageVector?, tint: Color) {
    if (icon != null) {
        Image(icon, null, colorFilter = ColorFilter.tint(tint), modifier = Modifier.size(20.dp))
    } else {
        FieldIcon(null, tint)
    }
}
