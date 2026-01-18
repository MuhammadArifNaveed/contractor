//
//  AppTheme.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

// MARK: - App Colors
struct AppTheme {
    
    struct Colors {
        static let primary = Color(hex: "F9B11F") // Yellow/Gold
        static let darkBlue = Color(hex: "093485")
        static let lightBlue = Color(hex: "093485").opacity(0.61)
        static let gray = Color(hex: "969696")
        static let lightGray = Color(hex: "969696").opacity(0.61)
        static let darkGreen = Color(hex: "00582A")
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let cardBackground = Color.white
        static let textPrimary = Color.black
        static let textSecondary = Color(hex: "555555")
        static let border = Color(hex: "E0E0E0")
        static let starYellow = Color(hex: "FFD700")
    }
    
    struct Fonts {
        // Century Gothic fonts matching the app's existing style
        static func centuryGothicBold(size: CGFloat) -> Font {
            return Font.custom("Century Gothic Bold", size: size)
        }
        
        static func centuryGothicRegular(size: CGFloat) -> Font {
            return Font.custom("Century Gothic", size: size)
        }
        
        // Fallback to system fonts if custom fonts aren't available
        static func bold(_ size: CGFloat) -> Font {
            return .system(size: size, weight: .bold)
        }
        
        static func semibold(_ size: CGFloat) -> Font {
            return .system(size: size, weight: .semibold)
        }
        
        static func medium(_ size: CGFloat) -> Font {
            return .system(size: size, weight: .medium)
        }
        
        static func regular(_ size: CGFloat) -> Font {
            return .system(size: size, weight: .regular)
        }
        
        // Semantic font sizes
        static let title = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .medium)
        static let body = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
        static let small = Font.system(size: 12, weight: .regular)
    }
    
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 30
    }
    
    struct Shadow {
        static let small = ShadowStyle(radius: 2, x: 0, y: 1)
        static let medium = ShadowStyle(radius: 4, x: 0, y: 2)
        static let large = ShadowStyle(radius: 8, x: 0, y: 4)
    }
}

struct ShadowStyle {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable View Modifiers
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.CornerRadius.medium
    var shadowRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.semibold(16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? AppTheme.Colors.primary : AppTheme.Colors.gray)
            .cornerRadius(AppTheme.CornerRadius.large)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct OutlinedTextFieldStyle: ViewModifier {
    var borderColor: Color = AppTheme.Colors.primary
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(borderColor, lineWidth: 1.5)
            )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(cornerRadius: CGFloat = AppTheme.CornerRadius.medium, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func outlinedTextField(borderColor: Color = AppTheme.Colors.primary) -> some View {
        modifier(OutlinedTextFieldStyle(borderColor: borderColor))
    }
}
