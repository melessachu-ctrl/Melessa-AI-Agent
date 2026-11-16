// HKTVmall Text Field (Figma 3005:218, symbol 5686:130). Matches references/components/text-field.md.
// Reference file for writing UI. Do not scaffold a whole DS into the app.
// Clear icon colour is primitive neutral-200.

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.foundation.Image
import androidx.compose.foundation.text.BasicText

enum class HKTVFieldSize { M, S }

enum class HKTVTextFieldState {
    Placeholder, Focus, Typing, Filled, Error, ErrorTyping, Disabled,
}

@Composable
fun HKTVTextField(
    title: String = "Title",
    text: String = "",
    placeholder: String = "Default Hint",
    size: HKTVFieldSize = HKTVFieldSize.M,
    state: HKTVTextFieldState = HKTVTextFieldState.Placeholder,
    message: String? = null,
    showsPrefix: Boolean = false,
    prefix: String = "$",
    isSecure: Boolean = false,
    clearIcon: ImageVector? = null,
    secureIcon: ImageVector? = null,
    modifier: Modifier = Modifier,
    onClear: () -> Unit = {},
) {
    val disabled = state == HKTVTextFieldState.Disabled
    val labelColor = if (disabled) HKTVColor.TextDisable else HKTVColor.TextPrimary
    val valueColor = if (disabled) HKTVColor.TextDisable else HKTVColor.TextPrimary
    val placeholderColor = if (disabled) HKTVColor.TextDisable else HKTVColor.TextPlaceholder
    val showPlaceholder = text.isEmpty()
    val showCaret = state == HKTVTextFieldState.Focus || state == HKTVTextFieldState.Typing || state == HKTVTextFieldState.ErrorTyping
    val showClear = state == HKTVTextFieldState.Error || state == HKTVTextFieldState.ErrorTyping
    val showMessage = showClear && !message.isNullOrEmpty()
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(HKTVSpacing.S8)) {
        BasicText(title, style = HKTVText.Body1Regular.copy(color = labelColor))
        Column(verticalArrangement = Arrangement.spacedBy(HKTVSpacing.S4)) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(if (size == HKTVFieldSize.M) 56.dp else 48.dp)
                    .background(if (disabled) HKTVColor.BackgroundGrey75 else HKTVColor.BackgroundWhite, RoundedCornerShape(HKTVRadius.CardS))
                    .border(HKTVBorderWidth.Regular, borderColor(state), RoundedCornerShape(HKTVRadius.CardS))
                    .padding(horizontal = HKTVSpacing.S16),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S8),
            ) {
                if (showsPrefix) {
                    BasicText(prefix, style = HKTVText.Body1Regular.copy(color = valueColor))
                }
                Box(Modifier.weight(1f)) {
                    if (isSecure && !showPlaceholder) {
                        Row(horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S4)) {
                            repeat(8) {
                                Box(Modifier.size(6.dp).background(valueColor, CircleShape))
                            }
                        }
                    } else {
                        BasicText(
                            if (showPlaceholder) placeholder else text,
                            style = HKTVText.Body1Regular.copy(color = if (showPlaceholder) placeholderColor else valueColor),
                            maxLines = 1,
                        )
                    }
                }
                if (showCaret) {
                    Box(Modifier.width(HKTVBorderWidth.Regular).height(22.dp).background(HKTVColor.BrandPrimary))
                }
                if (isSecure) {
                    FieldIcon(secureIcon, HKTVColor.TextPrimary)
                }
                if (showClear) {
                    Box(Modifier.clickable(onClick = onClear)) {
                        FieldIcon(clearIcon, HKTVPrimitive.Neutral200)
                    }
                }
            }
            if (showMessage) {
                BasicText(message!!, style = HKTVText.Body2Regular.copy(color = HKTVColor.TextDanger))
            }
        }
    }
}

@Composable
internal fun FieldIcon(icon: ImageVector?, tint: Color) {
    if (icon != null) {
        Image(
            imageVector = icon,
            contentDescription = null,
            colorFilter = ColorFilter.tint(tint),
            modifier = Modifier.size(24.dp),
        )
    } else {
        Canvas(Modifier.size(24.dp)) {
            drawCircle(color = tint, radius = size.minDimension / 2f - 1.dp.toPx(), style = androidx.compose.ui.graphics.drawscope.Stroke(width = 1.dp.toPx()))
        }
    }
}

private fun borderColor(state: HKTVTextFieldState): Color = when (state) {
    HKTVTextFieldState.Focus, HKTVTextFieldState.Typing -> HKTVColor.TextPrimary
    HKTVTextFieldState.Error, HKTVTextFieldState.ErrorTyping -> HKTVColor.TextDanger
    else -> HKTVColor.StrokeSecondary
}
