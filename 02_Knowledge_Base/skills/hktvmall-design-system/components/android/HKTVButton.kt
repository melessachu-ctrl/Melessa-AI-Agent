// HKTVmall Button (Figma 3135:812). Hand-written to match references/components/button.md.
// Copy into the effective token package from CLAUDE.md / references/native-repo-map.md
// (HKTVTokens.kt package or mall core/ui/.../theme/). Change this package to match.
// Do not overwrite an existing Compose DS HKTVButton.kt. Same-name but non-DS API = Conflict — ask first.
// Icon sizes (22 / 20 / 18) have no token yet; they follow the Button spec.
// Press and focus colours are not in the Figma set, so the click has no extra indication.

package com.hktvmall.designsystem

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.Image
import androidx.compose.foundation.text.BasicText

enum class HKTVButtonAppearance {
    Filled, Secondary, Outline, Text,
}

enum class HKTVButtonShape {
    Rounded, Capsule,
}

enum class HKTVButtonSize {
    L, M, S, XS,
}

enum class HKTVButtonState {
    Enable, Disabled, Loading,
}

@Composable
fun HKTVButton(
    text: String = "Button",
    appearance: HKTVButtonAppearance = HKTVButtonAppearance.Filled,
    shape: HKTVButtonShape = HKTVButtonShape.Rounded,
    size: HKTVButtonSize = HKTVButtonSize.L,
    state: HKTVButtonState = HKTVButtonState.Enable,
    startIcon: ImageVector? = null,
    endIcon: ImageVector? = null,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {},
) {
    val palette = palette(appearance, state)
    val metrics = metrics(size, shape, appearance)
    val corner = RoundedCornerShape(metrics.cornerRadius)
    val rowModifier = modifier
        .widthIn(min = metrics.minWidth)
        .then(if (metrics.height != null) Modifier.height(metrics.height) else Modifier)
        .clip(corner)
        .background(palette.background)
        .then(
            if (palette.drawsBorder) {
                Modifier.border(HKTVBorderWidth.Regular, palette.border, corner)
            } else {
                Modifier
            }
        )
        .clickable(
            enabled = state == HKTVButtonState.Enable,
            interactionSource = remember { MutableInteractionSource() },
            indication = null,
            onClick = onClick,
        )
        .padding(horizontal = metrics.horizontalPadding, vertical = metrics.verticalPadding)
        .semantics { contentDescription = text }
    Row(
        modifier = rowModifier,
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (startIcon != null) {
            ButtonIcon(startIcon, metrics.startIcon, palette.foreground)
        }
        if (state == HKTVButtonState.Loading) {
            ButtonSpinner(palette.foreground, metrics.spinner)
        } else {
            BasicText(
                text = text,
                style = metrics.text.copy(color = palette.foreground, textAlign = TextAlign.Center),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
        if (endIcon != null) {
            ButtonIcon(endIcon, metrics.endIcon, palette.foreground)
        }
    }
}

@Composable
private fun ButtonIcon(icon: ImageVector, size: Dp, tint: Color) {
    Image(
        imageVector = icon,
        contentDescription = null,
        colorFilter = ColorFilter.tint(tint),
        contentScale = ContentScale.Fit,
        modifier = Modifier.size(size),
    )
}

@Composable
private fun ButtonSpinner(color: Color, size: Dp) {
    val angle by rememberInfiniteTransition(label = "hktvButtonLoading").animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(durationMillis = 800, easing = LinearEasing)),
        label = "angle",
    )
    Canvas(Modifier.size(size)) {
        rotate(angle) {
            drawArc(
                color = color,
                startAngle = 0f,
                sweepAngle = 270f,
                useCenter = false,
                style = Stroke(width = 2.dp.toPx(), cap = StrokeCap.Round),
            )
        }
    }
}

private data class ButtonPalette(
    val background: Color,
    val foreground: Color,
    val border: Color,
    val drawsBorder: Boolean,
)

private fun palette(appearance: HKTVButtonAppearance, state: HKTVButtonState): ButtonPalette {
    val visual = if (state == HKTVButtonState.Loading) HKTVButtonState.Enable else state
    if (visual == HKTVButtonState.Disabled) {
        return when (appearance) {
            HKTVButtonAppearance.Filled, HKTVButtonAppearance.Secondary ->
                ButtonPalette(HKTVColor.BackgroundGrey75, HKTVColor.TextDisable, Color.Transparent, false)
            HKTVButtonAppearance.Outline ->
                ButtonPalette(Color.Transparent, HKTVColor.TextDisable, HKTVColor.StrokeSecondary, true)
            HKTVButtonAppearance.Text ->
                ButtonPalette(Color.Transparent, HKTVColor.TextDisable, Color.Transparent, false)
        }
    }
    return when (appearance) {
        HKTVButtonAppearance.Filled ->
            ButtonPalette(HKTVColor.BrandPrimary, HKTVColor.TextWhite, Color.Transparent, false)
        HKTVButtonAppearance.Secondary ->
            ButtonPalette(HKTVColor.BackgroundGreen75, HKTVColor.BrandPrimary, Color.Transparent, false)
        HKTVButtonAppearance.Outline ->
            ButtonPalette(Color.Transparent, HKTVColor.BrandPrimary, HKTVColor.BrandPrimary, true)
        HKTVButtonAppearance.Text ->
            ButtonPalette(Color.Transparent, HKTVColor.BrandPrimary, Color.Transparent, false)
    }
}

private data class ButtonMetrics(
    val height: Dp?,
    val minWidth: Dp,
    val horizontalPadding: Dp,
    val verticalPadding: Dp,
    val cornerRadius: Dp,
    val startIcon: Dp,
    val endIcon: Dp,
    val spinner: Dp,
    val text: androidx.compose.ui.text.TextStyle,
)

private fun metrics(
    size: HKTVButtonSize,
    shape: HKTVButtonShape,
    appearance: HKTVButtonAppearance,
): ButtonMetrics {
    val large = size == HKTVButtonSize.L || size == HKTVButtonSize.M
    val text = if (appearance == HKTVButtonAppearance.Text) {
        if (large) HKTVText.Body1Regular else HKTVText.Body2Regular
    } else {
        if (large) HKTVText.TitleSemibold else HKTVText.Body2Semibold
    }
    val startIcon = if (large) 22.dp else 18.dp
    val endIcon = if (large) 20.dp else 18.dp
    val spinner = if (large) 16.dp else 14.dp
    val (height, minWidth, horizontal, vertical, radius) = when (size to shape) {
        HKTVButtonSize.L to HKTVButtonShape.Rounded ->
            MetricsRow(52.dp, 88.dp, HKTVSpacing.S16, 0.dp, HKTVRadius.CardS)
        HKTVButtonSize.L to HKTVButtonShape.Capsule ->
            MetricsRow(52.dp, 84.dp, HKTVSpacing.S20, 0.dp, HKTVRadius.Full)
        HKTVButtonSize.M to HKTVButtonShape.Rounded ->
            MetricsRow(44.dp, 76.dp, HKTVSpacing.S12, 0.dp, HKTVRadius.CardS)
        HKTVButtonSize.M to HKTVButtonShape.Capsule ->
            MetricsRow(44.dp, 72.dp, HKTVSpacing.S16, 0.dp, HKTVRadius.Full)
        HKTVButtonSize.S to HKTVButtonShape.Rounded ->
            MetricsRow(36.dp, 64.dp, HKTVSpacing.S8, 0.dp, HKTVRadius.ButtonS)
        HKTVButtonSize.S to HKTVButtonShape.Capsule ->
            MetricsRow(36.dp, 64.dp, HKTVSpacing.S12, 0.dp, HKTVRadius.Full)
        HKTVButtonSize.XS to HKTVButtonShape.Rounded ->
            MetricsRow(null, 48.dp, HKTVSpacing.S8, HKTVSpacing.S6, HKTVRadius.CardXs)
        HKTVButtonSize.XS to HKTVButtonShape.Capsule ->
            MetricsRow(null, 48.dp, HKTVSpacing.S8, HKTVSpacing.S6, HKTVRadius.Full)
        else -> MetricsRow(52.dp, 88.dp, HKTVSpacing.S16, 0.dp, HKTVRadius.CardS)
    }
    return ButtonMetrics(height, minWidth, horizontal, vertical, radius, startIcon, endIcon, spinner, text)
}

private data class MetricsRow(
    val height: Dp?,
    val minWidth: Dp,
    val horizontal: Dp,
    val vertical: Dp,
    val radius: Dp,
)
