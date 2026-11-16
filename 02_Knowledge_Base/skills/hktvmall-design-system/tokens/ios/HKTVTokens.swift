// Generated from tokens.json (HKTVmall Design System, Figma F0tjdruLjJTfWgmTeZKBnw, synced 2026-11-05). Do not edit by hand: change tokens.json and regenerate.
// Colours are sRGB. Requires Poppins font files bundled in the app (UIAppFonts in Info.plist):
// Poppins-Regular.ttf, Poppins-Medium.ttf, Poppins-SemiBold.ttf, Poppins-Bold.ttf

import SwiftUI

private extension Color {
    init(hktvHex hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

/// Primitive colour scale. Prefer HKTVColor. Use a primitive only when no semantic token has this exact colour.
enum HKTVPrimitive {
    static let green25 = Color(hktvHex: 0xEEFFF6)
    static let green50 = Color(hktvHex: 0xF2FBF7)
    static let green75 = Color(hktvHex: 0xE5F6EE)
    static let green100 = Color(hktvHex: 0xCCFFE2)
    static let green200 = Color(hktvHex: 0x9EFCCB)
    static let green300 = Color(hktvHex: 0x76FFBE)
    static let green400 = Color(hktvHex: 0x67FB98)
    static let green500 = Color(hktvHex: 0x09DE7A)
    static let green600 = Color(hktvHex: 0x00CE6E)
    static let green700 = Color(hktvHex: 0x00B539)
    static let green800 = Color(hktvHex: 0x00A759)
    static let green900 = Color(hktvHex: 0x007B55)
    static let green950 = Color(hktvHex: 0x04503A)
    static let neutral0 = Color(hktvHex: 0xFFFFFF)
    static let neutral50 = Color(hktvHex: 0xF7F7F7)
    static let neutral75 = Color(hktvHex: 0xF2F2F2)
    static let neutral100 = Color(hktvHex: 0xE5E8EB)
    static let neutral200 = Color(hktvHex: 0xD3D3D3)
    static let neutral300 = Color(hktvHex: 0xB2B2B2)
    static let neutral400 = Color(hktvHex: 0xA3A3A3)
    static let neutral500 = Color(hktvHex: 0x8B8B8B)
    static let neutral600 = Color(hktvHex: 0x535353)
    static let neutral700 = Color(hktvHex: 0x575757)
    static let neutral800 = Color(hktvHex: 0x474747)
    static let neutral900 = Color(hktvHex: 0x272727)
    static let neutral950 = Color(hktvHex: 0x1C1C1C)
    static let neutral1000 = Color(hktvHex: 0x000000)
    static let red25 = Color(hktvHex: 0xFFEBEE)
    static let red50 = Color(hktvHex: 0xFFE1E1)
    static let red75 = Color(hktvHex: 0xFFC8C8)
    static let red100 = Color(hktvHex: 0xF1B3BB)
    static let red200 = Color(hktvHex: 0xFFA0A0)
    static let red300 = Color(hktvHex: 0xFF6464)
    static let red400 = Color(hktvHex: 0xFC5585)
    static let red500 = Color(hktvHex: 0xFF4C4C)
    static let red600 = Color(hktvHex: 0xE4483F)
    static let red700 = Color(hktvHex: 0xD0021B)
    static let red800 = Color(hktvHex: 0xCF062A)
    static let red900 = Color(hktvHex: 0xAE061A)
    static let red950 = Color(hktvHex: 0x8F0D1D)
    static let orange25 = Color(hktvHex: 0xFFF8ED)
    static let orange50 = Color(hktvHex: 0xFFF4E2)
    static let orange75 = Color(hktvHex: 0xFEF3E8)
    static let orange100 = Color(hktvHex: 0xFDEBD7)
    static let orange200 = Color(hktvHex: 0xFFDCA8)
    static let orange300 = Color(hktvHex: 0xFFC272)
    static let orange400 = Color(hktvHex: 0xFE9E39)
    static let orange500 = Color(hktvHex: 0xFD7C0A)
    static let orange600 = Color(hktvHex: 0xFF6C40)
    static let orange700 = Color(hktvHex: 0xFF5500)
    static let orange800 = Color(hktvHex: 0xCC3B02)
    static let orange900 = Color(hktvHex: 0x82290C)
    static let orange950 = Color(hktvHex: 0x7E3310)
    static let yellow25 = Color(hktvHex: 0xFFFCEB)
    static let yellow50 = Color(hktvHex: 0xFFF7CD)
    static let yellow75 = Color(hktvHex: 0xFFF4CD)
    static let yellow100 = Color(hktvHex: 0xFDF2AD)
    static let yellow200 = Color(hktvHex: 0xFCF18C)
    static let yellow300 = Color(hktvHex: 0xFFEC74)
    static let yellow400 = Color(hktvHex: 0xFAE24A)
    static let yellow500 = Color(hktvHex: 0xF7CF18)
    static let yellow600 = Color(hktvHex: 0xE4B40B)
    static let yellow700 = Color(hktvHex: 0xC0812B)
    static let yellow800 = Color(hktvHex: 0xA76708)
    static let yellow900 = Color(hktvHex: 0x844E0F)
    static let yellow950 = Color(hktvHex: 0x7A4F01)
    static let blue25 = Color(hktvHex: 0xEFFAFF)
    static let blue50 = Color(hktvHex: 0xE6F7FF)
    static let blue75 = Color(hktvHex: 0xD0F2FF)
    static let blue100 = Color(hktvHex: 0xB9E8FF)
    static let blue200 = Color(hktvHex: 0xACE1FF)
    static let blue300 = Color(hktvHex: 0x7ACAFF)
    static let blue400 = Color(hktvHex: 0x28A6FF)
    static let blue500 = Color(hktvHex: 0x1890FF)
    static let blue600 = Color(hktvHex: 0x1D78FF)
    static let blue700 = Color(hktvHex: 0x0057FF)
    static let blue800 = Color(hktvHex: 0x005AFF)
    static let blue900 = Color(hktvHex: 0x004EDC)
    static let blue950 = Color(hktvHex: 0x04297A)
    static let purple25 = Color(hktvHex: 0xF8F7FF)
    static let purple50 = Color(hktvHex: 0xF5EFFF)
    static let purple75 = Color(hktvHex: 0xF1E9FF)
    static let purple100 = Color(hktvHex: 0xEFEBFF)
    static let purple200 = Color(hktvHex: 0xE5D3FF)
    static let purple300 = Color(hktvHex: 0xB680FF)
    static let purple400 = Color(hktvHex: 0xA35CFD)
    static let purple500 = Color(hktvHex: 0x852CF1)
    static let purple600 = Color(hktvHex: 0x711CD4)
    static let purple700 = Color(hktvHex: 0x7039C7)
    static let purple800 = Color(hktvHex: 0x5E30A7)
    static let purple900 = Color(hktvHex: 0x4E2989)
    static let purple950 = Color(hktvHex: 0x30195C)
    static let overlayNeu100070 = Color(hktvHex: 0x000000, alpha: 0.70)
    static let overlayNeu100030 = Color(hktvHex: 0x000000, alpha: 0.30)
}

/// Semantic colours. Use these in UI.
enum HKTVColor {
    static let textPrimary = HKTVPrimitive.neutral950
    static let textSecondary = HKTVPrimitive.neutral700
    static let textTertiary = HKTVPrimitive.neutral500
    static let textPlaceholder = HKTVPrimitive.neutral300
    static let textDisable = HKTVPrimitive.neutral400
    static let textWhite = HKTVPrimitive.neutral0
    static let textSalePrice = HKTVPrimitive.red800
    static let textDanger = HKTVPrimitive.red600
    static let textHighlight = HKTVPrimitive.orange500
    static let brandPrimary = HKTVPrimitive.green800
    static let brandSecondary = HKTVPrimitive.green900
    static let brandTertiary = HKTVPrimitive.green600
    static let brandFlagshipStore = HKTVPrimitive.yellow700
    static let backgroundWhite = HKTVPrimitive.neutral0
    static let backgroundGrey50 = HKTVPrimitive.neutral50
    static let backgroundGrey75 = HKTVPrimitive.neutral75
    static let backgroundBlack = HKTVPrimitive.neutral1000
    static let backgroundDisable = HKTVPrimitive.neutral100
    static let backgroundError = HKTVPrimitive.red25
    static let backgroundGreen50 = HKTVPrimitive.green50
    static let backgroundGreen75 = HKTVPrimitive.green75
    static let backgroundWarning = HKTVPrimitive.yellow50
    static let backgroundInform = HKTVPrimitive.blue75
    static let strokePrimary = HKTVPrimitive.neutral75
    static let strokeSecondary = HKTVPrimitive.neutral100
    static let overlay70 = HKTVPrimitive.overlayNeu100070
    static let overlay30 = HKTVPrimitive.overlayNeu100030
    static let membershipPriceTextPlus = HKTVPrimitive.green700
    static let membershipPlus = HKTVPrimitive.green400
    static let membershipPriceTextVip = HKTVPrimitive.purple800
    static let membershipPriceTextGvip = HKTVPrimitive.yellow600
    static let membershipGvip = HKTVPrimitive.yellow600
    static let membershipGvipBackground = HKTVPrimitive.yellow75
    static let membershipVip = HKTVPrimitive.purple800
    static let membershipPriceTextDvip = HKTVPrimitive.yellow800
    static let membershipVipBackground = HKTVPrimitive.purple50
    static let membershipPriceTextPpp = HKTVPrimitive.orange600
    static let buLandmark = Color(hktvHex: 0x666666)
    static let buSupermarket = Color(hktvHex: 0x7CC73D)
    static let buPersonalCare = Color(hktvHex: 0xF5A623)
    static let buBeauty = HKTVPrimitive.red400
    static let buFashion = Color(hktvHex: 0x2D2D2D)
    static let buMacau = Color(hktvHex: 0xAE8223)
    static let buPets = Color(hktvHex: 0xF97C46)
    static let buMotherBaby = Color(hktvHex: 0x77D1DA)
    static let buGadgets = Color(hktvHex: 0x2A74E0)
    static let buHomeApplicances = Color(hktvHex: 0x57C2BD)
    static let buHousewares = Color(hktvHex: 0xE3C100)
    static let buSports = Color(hktvHex: 0x77AE39)
    static let buToys = Color(hktvHex: 0x0196FF)
    static let buInsurance = Color(hktvHex: 0x98353B)
    static let buServiceDeal = Color(hktvHex: 0x8366FF)
    static let buCashback = HKTVPrimitive.orange600
    static let bu3Hrs = HKTVPrimitive.purple600
    static let buLive = Color(hktvHex: 0x00BFE0)
    static let buTaobao = Color(hktvHex: 0xFF401E)
    static let buPublicHousing = Color(hktvHex: 0x23814F)
    static let buGreenlab = Color(hktvHex: 0x3DD4AE)
    static let buThePlace = Color(hktvHex: 0x33CCCC)
    static let backgroundRed50 = HKTVPrimitive.red50
    static let backgroundOrange75 = HKTVPrimitive.yellow75
    static let backgroundBlue50 = HKTVPrimitive.blue50
    static let backgroundKaPrice = HKTVPrimitive.neutral800
}

enum HKTVSpacing {
    static let s2: CGFloat = 2
    static let s4: CGFloat = 4
    static let s6: CGFloat = 6
    static let s8: CGFloat = 8
    static let s12: CGFloat = 12
    static let s16: CGFloat = 16
    static let s20: CGFloat = 20
    static let s24: CGFloat = 24
    static let s32: CGFloat = 32
    static let s36: CGFloat = 36
}

enum HKTVRadius {
    static let badgeS: CGFloat = 4
    static let badgeL: CGFloat = 6
    static let cardXs: CGFloat = 8
    static let buttonS: CGFloat = 10
    static let cardS: CGFloat = 12
    static let cardL: CGFloat = 16
    static let module: CGFloat = 24
    static let full: CGFloat = 999
}

enum HKTVBorderWidth {
    static let hairline: CGFloat = 0.4
    static let regular: CGFloat = 1
    static let bold: CGFloat = 2
}

/// One shadow layer. SwiftUI's `radius` is about half of the CSS blur, and SwiftUI has no spread:
/// a negative spread (z12, z16, z20, zCard) is approximated by the smaller radius only.
struct HKTVShadowLayer {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum HKTVShadow {
    /// 0 4px 8px 0 rgba(145, 158, 171, 0.16)
    static let card: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 4, x: 0, y: 4)]
    /// 0 4px 16px 0 rgba(145, 158, 171, 0.3)
    static let modal: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.3), radius: 8, x: 0, y: 4)]
    /// 0 0 8px 0 rgba(145, 158, 171, 0.16)
    static let footer: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 4, x: 0, y: 0)]
    /// 0 1px 2px 0 rgba(145, 158, 171, 0.16)
    static let z1: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 1, x: 0, y: 1)]
    /// 0 8px 16px 0 rgba(145, 158, 171, 0.16)
    static let z8: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 8, x: 0, y: 8)]
    /// 0 12px 24px -4px rgba(145, 158, 171, 0.16)
    static let z12: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 12, x: 0, y: 12)]
    /// 0 16px 32px -4px rgba(145, 158, 171, 0.16)
    static let z16: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 16, x: 0, y: 16)]
    /// 0 20px 40px -4px rgba(145, 158, 171, 0.16)
    static let z20: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 20, x: 0, y: 20)]
    /// 0 24px 48px 0 rgba(145, 158, 171, 0.16)
    static let z24: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.16), radius: 24, x: 0, y: 24)]
    /// 0 12px 24px -4px rgba(145, 158, 171, 0.12), 0 0 2px 0 rgba(145, 158, 171, 0.2)
    static let zcard: [HKTVShadowLayer] = [HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.12), radius: 12, x: 0, y: 12), HKTVShadowLayer(color: Color(.sRGB, red: 145.0 / 255, green: 158.0 / 255, blue: 171.0 / 255, opacity: 0.2), radius: 1, x: 0, y: 0)]
}

extension View {
    /// Applies an HKTVmall shadow, e.g. `.hktvShadow(HKTVShadow.card)`.
    func hktvShadow(_ layers: [HKTVShadowLayer]) -> some View {
        layers.reduce(AnyView(self)) { view, l in
            AnyView(view.shadow(color: l.color, radius: l.radius, x: l.x, y: l.y))
        }
    }
}

struct HKTVTextStyle {
    let fontName: String
    let size: CGFloat
    let lineHeight: CGFloat   // multiplier (1.4 = 140%)
    var strikethrough = false

    var font: Font { .custom(fontName, size: size) }
}

enum HKTVText {
    static let headline1Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 28, lineHeight: 1.4)
    static let headline1Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 28, lineHeight: 1.4)
    static let headline1Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 28, lineHeight: 1.4)
    static let headline2Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 24, lineHeight: 1.4)
    static let headline2Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 24, lineHeight: 1.4)
    static let headline2Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 24, lineHeight: 1.4)
    static let headline2Bold = HKTVTextStyle(fontName: "Poppins-Bold", size: 24, lineHeight: 1.4)
    static let headline3Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 20, lineHeight: 1.4)
    static let headline3Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 20, lineHeight: 1.4)
    static let headline3Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 20, lineHeight: 1.4)
    static let subtitleRegular = HKTVTextStyle(fontName: "Poppins-Regular", size: 18, lineHeight: 1.4)
    static let subtitleMedium = HKTVTextStyle(fontName: "Poppins-Medium", size: 18, lineHeight: 1.4)
    static let subtitleSemibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 18, lineHeight: 1.4)
    static let titleRegular = HKTVTextStyle(fontName: "Poppins-Regular", size: 16, lineHeight: 1.4)
    static let titleMedium = HKTVTextStyle(fontName: "Poppins-Medium", size: 16, lineHeight: 1.4)
    static let titleSemibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 16, lineHeight: 1.4)
    static let body1Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 16, lineHeight: 1.4)
    static let body1Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 16, lineHeight: 1.4)
    static let body1Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 16, lineHeight: 1.4)
    static let body2Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 14, lineHeight: 1.4)
    static let body2Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 14, lineHeight: 1.4)
    static let body2Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 14, lineHeight: 1.4)
    static let body3Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 12, lineHeight: 1.4)
    static let body3Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 12, lineHeight: 1.4)
    static let body3Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 12, lineHeight: 1.4)
    static let caption1Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 10, lineHeight: 1.4)
    static let caption1Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 10, lineHeight: 1.4)
    static let caption1Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 10, lineHeight: 1.4)
    static let caption1Bold = HKTVTextStyle(fontName: "Poppins-Bold", size: 10, lineHeight: 1.4)
    static let caption2Regular = HKTVTextStyle(fontName: "Poppins-Regular", size: 8, lineHeight: 1.4)
    static let caption2Medium = HKTVTextStyle(fontName: "Poppins-Medium", size: 8, lineHeight: 1.4)
    static let caption2Semibold = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 8, lineHeight: 1.4)
    static let priceDetailPageMain = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 24, lineHeight: 1.4)
    static let priceDetailPageRp = HKTVTextStyle(fontName: "Poppins-Regular", size: 12, lineHeight: 1.4, strikethrough: true)
    static let priceListingMain = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 16, lineHeight: 1.4)
    static let priceListingMultiCol = HKTVTextStyle(fontName: "Poppins-SemiBold", size: 14, lineHeight: 1.4)
    static let priceListingRp = HKTVTextStyle(fontName: "Poppins-Regular", size: 12, lineHeight: 1.4, strikethrough: true)
}

extension View {
    /// Applies an HKTVmall text style (View.strikethrough needs iOS 16+), e.g. `Text("$289.0").hktvText(HKTVText.priceListingMain)`.
    func hktvText(_ style: HKTVTextStyle) -> some View {
        self.font(style.font)
            .lineSpacing(style.size * (style.lineHeight - 1))
            .strikethrough(style.strikethrough)
    }
}
