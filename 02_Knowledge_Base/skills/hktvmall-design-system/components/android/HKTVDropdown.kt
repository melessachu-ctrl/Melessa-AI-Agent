// HKTVmall Dropdown (Figma 3005:218, symbol 5690:356). Matches references/components/text-field.md.
// Closed field only. Pass icon-chevrondown-small-outlined when the app has it.

package com.hktvmall.designsystem

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.foundation.Image
import androidx.compose.foundation.text.BasicText

enum class HKTVDropdownState { Placeholder, Focus, Filled, Disabled }

@Composable
fun HKTVDropdown(
    title: String = "Title",
    value: String = "",
    placeholder: String = "Default Hint",
    size: HKTVFieldSize = HKTVFieldSize.M,
    state: HKTVDropdownState = HKTVDropdownState.Placeholder,
    chevron: ImageVector? = null,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {},
) {
    val disabled = state == HKTVDropdownState.Disabled
    val labelColor = if (disabled) HKTVColor.TextDisable else HKTVColor.TextPrimary
    val valueColor = if (disabled) HKTVColor.TextDisable else HKTVColor.TextPrimary
    val placeholderColor = if (disabled) HKTVColor.TextDisable else HKTVColor.TextPlaceholder
    val showPlaceholder = value.isEmpty() || state == HKTVDropdownState.Placeholder
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(HKTVSpacing.S8)) {
        BasicText(title, style = HKTVText.Body1Regular.copy(color = labelColor))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(if (size == HKTVFieldSize.M) 56.dp else 48.dp)
                .background(if (disabled) HKTVColor.BackgroundGrey75 else HKTVColor.BackgroundWhite, RoundedCornerShape(HKTVRadius.CardS))
                .border(
                    HKTVBorderWidth.Regular,
                    if (state == HKTVDropdownState.Focus) HKTVColor.TextPrimary else HKTVColor.StrokeSecondary,
                    RoundedCornerShape(HKTVRadius.CardS),
                )
                .clickable(enabled = !disabled, onClick = onClick)
                .padding(horizontal = HKTVSpacing.S16),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(HKTVSpacing.S8),
        ) {
            BasicText(
                if (showPlaceholder) placeholder else value,
                style = HKTVText.Body1Regular.copy(color = if (showPlaceholder) placeholderColor else valueColor),
                maxLines = 1,
                modifier = Modifier.weight(1f),
            )
            if (chevron != null) {
                Image(chevron, null, colorFilter = ColorFilter.tint(valueColor), modifier = Modifier.size(20.dp))
            } else {
                Canvas(Modifier.size(20.dp)) {
                    val canvas = this.size
                    val y = canvas.height * 0.42f
                    drawLine(valueColor, Offset(canvas.width * 0.25f, y), Offset(canvas.width * 0.5f, canvas.height * 0.68f), strokeWidth = 1.dp.toPx(), cap = StrokeCap.Round)
                    drawLine(valueColor, Offset(canvas.width * 0.5f, canvas.height * 0.68f), Offset(canvas.width * 0.75f, y), strokeWidth = 1.dp.toPx(), cap = StrokeCap.Round)
                }
            }
        }
    }
}
