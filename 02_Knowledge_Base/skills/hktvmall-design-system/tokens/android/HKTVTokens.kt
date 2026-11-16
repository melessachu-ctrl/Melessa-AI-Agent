// Generated from tokens.json (HKTVmall Design System, Figma F0tjdruLjJTfWgmTeZKBnw, synced 2026-11-05). Do not edit by hand: change tokens.json and regenerate.
// Requires Poppins font files in res/font: poppins_regular.ttf, poppins_medium.ttf, poppins_semibold.ttf, poppins_bold.ttf
// Change the package name to fit your app, and import your app's R class (e.g. import com.hktvmall.app.R).

package com.hktvmall.designsystem

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/** Primitive colour scale. Prefer HKTVColor. Use a primitive only when no semantic token has this exact colour. */
object HKTVPrimitive {
    val Green25 = Color(0xFFEEFFF6)
    val Green50 = Color(0xFFF2FBF7)
    val Green75 = Color(0xFFE5F6EE)
    val Green100 = Color(0xFFCCFFE2)
    val Green200 = Color(0xFF9EFCCB)
    val Green300 = Color(0xFF76FFBE)
    val Green400 = Color(0xFF67FB98)
    val Green500 = Color(0xFF09DE7A)
    val Green600 = Color(0xFF00CE6E)
    val Green700 = Color(0xFF00B539)
    val Green800 = Color(0xFF00A759)
    val Green900 = Color(0xFF007B55)
    val Green950 = Color(0xFF04503A)
    val Neutral0 = Color(0xFFFFFFFF)
    val Neutral50 = Color(0xFFF7F7F7)
    val Neutral75 = Color(0xFFF2F2F2)
    val Neutral100 = Color(0xFFE5E8EB)
    val Neutral200 = Color(0xFFD3D3D3)
    val Neutral300 = Color(0xFFB2B2B2)
    val Neutral400 = Color(0xFFA3A3A3)
    val Neutral500 = Color(0xFF8B8B8B)
    val Neutral600 = Color(0xFF535353)
    val Neutral700 = Color(0xFF575757)
    val Neutral800 = Color(0xFF474747)
    val Neutral900 = Color(0xFF272727)
    val Neutral950 = Color(0xFF1C1C1C)
    val Neutral1000 = Color(0xFF000000)
    val Red25 = Color(0xFFFFEBEE)
    val Red50 = Color(0xFFFFE1E1)
    val Red75 = Color(0xFFFFC8C8)
    val Red100 = Color(0xFFF1B3BB)
    val Red200 = Color(0xFFFFA0A0)
    val Red300 = Color(0xFFFF6464)
    val Red400 = Color(0xFFFC5585)
    val Red500 = Color(0xFFFF4C4C)
    val Red600 = Color(0xFFE4483F)
    val Red700 = Color(0xFFD0021B)
    val Red800 = Color(0xFFCF062A)
    val Red900 = Color(0xFFAE061A)
    val Red950 = Color(0xFF8F0D1D)
    val Orange25 = Color(0xFFFFF8ED)
    val Orange50 = Color(0xFFFFF4E2)
    val Orange75 = Color(0xFFFEF3E8)
    val Orange100 = Color(0xFFFDEBD7)
    val Orange200 = Color(0xFFFFDCA8)
    val Orange300 = Color(0xFFFFC272)
    val Orange400 = Color(0xFFFE9E39)
    val Orange500 = Color(0xFFFD7C0A)
    val Orange600 = Color(0xFFFF6C40)
    val Orange700 = Color(0xFFFF5500)
    val Orange800 = Color(0xFFCC3B02)
    val Orange900 = Color(0xFF82290C)
    val Orange950 = Color(0xFF7E3310)
    val Yellow25 = Color(0xFFFFFCEB)
    val Yellow50 = Color(0xFFFFF7CD)
    val Yellow75 = Color(0xFFFFF4CD)
    val Yellow100 = Color(0xFFFDF2AD)
    val Yellow200 = Color(0xFFFCF18C)
    val Yellow300 = Color(0xFFFFEC74)
    val Yellow400 = Color(0xFFFAE24A)
    val Yellow500 = Color(0xFFF7CF18)
    val Yellow600 = Color(0xFFE4B40B)
    val Yellow700 = Color(0xFFC0812B)
    val Yellow800 = Color(0xFFA76708)
    val Yellow900 = Color(0xFF844E0F)
    val Yellow950 = Color(0xFF7A4F01)
    val Blue25 = Color(0xFFEFFAFF)
    val Blue50 = Color(0xFFE6F7FF)
    val Blue75 = Color(0xFFD0F2FF)
    val Blue100 = Color(0xFFB9E8FF)
    val Blue200 = Color(0xFFACE1FF)
    val Blue300 = Color(0xFF7ACAFF)
    val Blue400 = Color(0xFF28A6FF)
    val Blue500 = Color(0xFF1890FF)
    val Blue600 = Color(0xFF1D78FF)
    val Blue700 = Color(0xFF0057FF)
    val Blue800 = Color(0xFF005AFF)
    val Blue900 = Color(0xFF004EDC)
    val Blue950 = Color(0xFF04297A)
    val Purple25 = Color(0xFFF8F7FF)
    val Purple50 = Color(0xFFF5EFFF)
    val Purple75 = Color(0xFFF1E9FF)
    val Purple100 = Color(0xFFEFEBFF)
    val Purple200 = Color(0xFFE5D3FF)
    val Purple300 = Color(0xFFB680FF)
    val Purple400 = Color(0xFFA35CFD)
    val Purple500 = Color(0xFF852CF1)
    val Purple600 = Color(0xFF711CD4)
    val Purple700 = Color(0xFF7039C7)
    val Purple800 = Color(0xFF5E30A7)
    val Purple900 = Color(0xFF4E2989)
    val Purple950 = Color(0xFF30195C)
    val OverlayNeu100070 = Color(0xB2000000)
    val OverlayNeu100030 = Color(0x4D000000)
}

/** Semantic colours. Use these in UI. */
object HKTVColor {
    val TextPrimary = HKTVPrimitive.Neutral950
    val TextSecondary = HKTVPrimitive.Neutral700
    val TextTertiary = HKTVPrimitive.Neutral500
    val TextPlaceholder = HKTVPrimitive.Neutral300
    val TextDisable = HKTVPrimitive.Neutral400
    val TextWhite = HKTVPrimitive.Neutral0
    val TextSalePrice = HKTVPrimitive.Red800
    val TextDanger = HKTVPrimitive.Red600
    val TextHighlight = HKTVPrimitive.Orange500
    val BrandPrimary = HKTVPrimitive.Green800
    val BrandSecondary = HKTVPrimitive.Green900
    val BrandTertiary = HKTVPrimitive.Green600
    val BrandFlagshipStore = HKTVPrimitive.Yellow700
    val BackgroundWhite = HKTVPrimitive.Neutral0
    val BackgroundGrey50 = HKTVPrimitive.Neutral50
    val BackgroundGrey75 = HKTVPrimitive.Neutral75
    val BackgroundBlack = HKTVPrimitive.Neutral1000
    val BackgroundDisable = HKTVPrimitive.Neutral100
    val BackgroundError = HKTVPrimitive.Red25
    val BackgroundGreen50 = HKTVPrimitive.Green50
    val BackgroundGreen75 = HKTVPrimitive.Green75
    val BackgroundWarning = HKTVPrimitive.Yellow50
    val BackgroundInform = HKTVPrimitive.Blue75
    val StrokePrimary = HKTVPrimitive.Neutral75
    val StrokeSecondary = HKTVPrimitive.Neutral100
    val Overlay70 = HKTVPrimitive.OverlayNeu100070
    val Overlay30 = HKTVPrimitive.OverlayNeu100030
    val MembershipPriceTextPlus = HKTVPrimitive.Green700
    val MembershipPlus = HKTVPrimitive.Green400
    val MembershipPriceTextVip = HKTVPrimitive.Purple800
    val MembershipPriceTextGvip = HKTVPrimitive.Yellow600
    val MembershipGvip = HKTVPrimitive.Yellow600
    val MembershipGvipBackground = HKTVPrimitive.Yellow75
    val MembershipVip = HKTVPrimitive.Purple800
    val MembershipPriceTextDvip = HKTVPrimitive.Yellow800
    val MembershipVipBackground = HKTVPrimitive.Purple50
    val MembershipPriceTextPpp = HKTVPrimitive.Orange600
    val BuLandmark = Color(0xFF666666)
    val BuSupermarket = Color(0xFF7CC73D)
    val BuPersonalCare = Color(0xFFF5A623)
    val BuBeauty = HKTVPrimitive.Red400
    val BuFashion = Color(0xFF2D2D2D)
    val BuMacau = Color(0xFFAE8223)
    val BuPets = Color(0xFFF97C46)
    val BuMotherBaby = Color(0xFF77D1DA)
    val BuGadgets = Color(0xFF2A74E0)
    val BuHomeApplicances = Color(0xFF57C2BD)
    val BuHousewares = Color(0xFFE3C100)
    val BuSports = Color(0xFF77AE39)
    val BuToys = Color(0xFF0196FF)
    val BuInsurance = Color(0xFF98353B)
    val BuServiceDeal = Color(0xFF8366FF)
    val BuCashback = HKTVPrimitive.Orange600
    val Bu3Hrs = HKTVPrimitive.Purple600
    val BuLive = Color(0xFF00BFE0)
    val BuTaobao = Color(0xFFFF401E)
    val BuPublicHousing = Color(0xFF23814F)
    val BuGreenlab = Color(0xFF3DD4AE)
    val BuThePlace = Color(0xFF33CCCC)
    val BackgroundRed50 = HKTVPrimitive.Red50
    val BackgroundOrange75 = HKTVPrimitive.Yellow75
    val BackgroundBlue50 = HKTVPrimitive.Blue50
    val BackgroundKaPrice = HKTVPrimitive.Neutral800
}

object HKTVSpacing {
    val S2 = 2.dp
    val S4 = 4.dp
    val S6 = 6.dp
    val S8 = 8.dp
    val S12 = 12.dp
    val S16 = 16.dp
    val S20 = 20.dp
    val S24 = 24.dp
    val S32 = 32.dp
    val S36 = 36.dp
}

object HKTVRadius {
    val BadgeS = 4.dp
    val BadgeL = 6.dp
    val CardXs = 8.dp
    val ButtonS = 10.dp
    val CardS = 12.dp
    val CardL = 16.dp
    val Module = 24.dp
    val Full = 999.dp
}

object HKTVBorderWidth {
    val Hairline = 0.4.dp
    val Regular = 1.dp
    val Bold = 2.dp
}

/**
 * One shadow layer, values as in CSS (blur and spread in dp).
 * Draw with Modifier.dropShadow (Compose UI 1.9+) or a custom drawBehind; Modifier.shadow(elevation) cannot reproduce these values.
 */
data class HKTVShadowLayer(val x: Dp, val y: Dp, val blur: Dp, val spread: Dp, val color: Color)

object HKTVShadow {
    /** 0 4px 8px 0 rgba(145, 158, 171, 0.16) */
    val Card = listOf(HKTVShadowLayer(0.dp, 4.dp, 8.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 4px 16px 0 rgba(145, 158, 171, 0.3) */
    val Modal = listOf(HKTVShadowLayer(0.dp, 4.dp, 16.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.3).toInt())))
    /** 0 0 8px 0 rgba(145, 158, 171, 0.16) */
    val Footer = listOf(HKTVShadowLayer(0.dp, 0.dp, 8.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 1px 2px 0 rgba(145, 158, 171, 0.16) */
    val Z1 = listOf(HKTVShadowLayer(0.dp, 1.dp, 2.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 8px 16px 0 rgba(145, 158, 171, 0.16) */
    val Z8 = listOf(HKTVShadowLayer(0.dp, 8.dp, 16.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 12px 24px -4px rgba(145, 158, 171, 0.16) */
    val Z12 = listOf(HKTVShadowLayer(0.dp, 12.dp, 24.dp, -4.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 16px 32px -4px rgba(145, 158, 171, 0.16) */
    val Z16 = listOf(HKTVShadowLayer(0.dp, 16.dp, 32.dp, -4.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 20px 40px -4px rgba(145, 158, 171, 0.16) */
    val Z20 = listOf(HKTVShadowLayer(0.dp, 20.dp, 40.dp, -4.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 24px 48px 0 rgba(145, 158, 171, 0.16) */
    val Z24 = listOf(HKTVShadowLayer(0.dp, 24.dp, 48.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.16).toInt())))
    /** 0 12px 24px -4px rgba(145, 158, 171, 0.12), 0 0 2px 0 rgba(145, 158, 171, 0.2) */
    val Zcard = listOf(HKTVShadowLayer(0.dp, 12.dp, 24.dp, -4.dp, Color(145, 158, 171, alpha = (255 * 0.12).toInt())), HKTVShadowLayer(0.dp, 0.dp, 2.dp, 0.dp, Color(145, 158, 171, alpha = (255 * 0.2).toInt())))
}

val PoppinsFamily = FontFamily(
    Font(R.font.poppins_regular, FontWeight.Normal),
    Font(R.font.poppins_medium, FontWeight.Medium),
    Font(R.font.poppins_semibold, FontWeight.SemiBold),
    Font(R.font.poppins_bold, FontWeight.Bold),
)

object HKTVText {
    val Headline1Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 28.sp, lineHeight = 39.2.sp, letterSpacing = 0.sp)
    val Headline1Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 28.sp, lineHeight = 39.2.sp, letterSpacing = 0.sp)
    val Headline1Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 28.sp, lineHeight = 39.2.sp, letterSpacing = 0.sp)
    val Headline2Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 24.sp, lineHeight = 33.6.sp, letterSpacing = 0.sp)
    val Headline2Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 24.sp, lineHeight = 33.6.sp, letterSpacing = 0.sp)
    val Headline2Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 24.sp, lineHeight = 33.6.sp, letterSpacing = 0.sp)
    val Headline2Bold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Bold, fontSize = 24.sp, lineHeight = 33.6.sp, letterSpacing = 0.sp)
    val Headline3Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 20.sp, lineHeight = 28.sp, letterSpacing = 0.sp)
    val Headline3Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 20.sp, lineHeight = 28.sp, letterSpacing = 0.sp)
    val Headline3Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 20.sp, lineHeight = 28.sp, letterSpacing = 0.sp)
    val SubtitleRegular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 18.sp, lineHeight = 25.2.sp, letterSpacing = 0.sp)
    val SubtitleMedium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 18.sp, lineHeight = 25.2.sp, letterSpacing = 0.sp)
    val SubtitleSemibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 18.sp, lineHeight = 25.2.sp, letterSpacing = 0.sp)
    val TitleRegular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val TitleMedium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val TitleSemibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val Body1Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val Body1Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val Body1Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val Body2Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 14.sp, lineHeight = 19.6.sp, letterSpacing = 0.sp)
    val Body2Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 14.sp, lineHeight = 19.6.sp, letterSpacing = 0.sp)
    val Body2Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, lineHeight = 19.6.sp, letterSpacing = 0.sp)
    val Body3Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 12.sp, lineHeight = 16.8.sp, letterSpacing = 0.sp)
    val Body3Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 12.sp, lineHeight = 16.8.sp, letterSpacing = 0.sp)
    val Body3Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 12.sp, lineHeight = 16.8.sp, letterSpacing = 0.sp)
    val Caption1Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 10.sp, lineHeight = 14.sp, letterSpacing = 0.sp)
    val Caption1Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 10.sp, lineHeight = 14.sp, letterSpacing = 0.sp)
    val Caption1Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 10.sp, lineHeight = 14.sp, letterSpacing = 0.sp)
    val Caption1Bold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Bold, fontSize = 10.sp, lineHeight = 14.sp, letterSpacing = 0.sp)
    val Caption2Regular = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 8.sp, lineHeight = 11.2.sp, letterSpacing = 0.sp)
    val Caption2Medium = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Medium, fontSize = 8.sp, lineHeight = 11.2.sp, letterSpacing = 0.sp)
    val Caption2Semibold = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 8.sp, lineHeight = 11.2.sp, letterSpacing = 0.sp)
    val PriceDetailPageMain = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 24.sp, lineHeight = 33.6.sp, letterSpacing = 0.sp)
    val PriceDetailPageRp = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 12.sp, lineHeight = 16.8.sp, letterSpacing = 0.sp, textDecoration = TextDecoration.LineThrough)
    val PriceListingMain = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 16.sp, lineHeight = 22.4.sp, letterSpacing = 0.sp)
    val PriceListingMultiCol = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, lineHeight = 19.6.sp, letterSpacing = 0.sp)
    val PriceListingRp = TextStyle(fontFamily = PoppinsFamily, fontWeight = FontWeight.Normal, fontSize = 12.sp, lineHeight = 16.8.sp, letterSpacing = 0.sp, textDecoration = TextDecoration.LineThrough)
}
