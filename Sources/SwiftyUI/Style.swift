//
//  Style.swift
//  Plowz
//
//  Created by Shreyas Bangera on 08/11/2019.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

///Naming Convention:
///Style: Color + FontWeight + FontSize
///ButtonStyle: Color + bgColor + FontWeight + FontSize
///Color: ColorShade + prominent RGB value

import UIKit

public extension UIColor {
    convenience init?(_ hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        guard cString.count == 6 else { return nil }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

public protocol Style {
    var color: UIColor { get }
    
    var bgColor: UIColor { get }
    
    var font: UIFont { get }
}

enum Styles: Style {
    case whiteBold15, blueWhiteRegular18, blackRegular18
    
    var color: UIColor {
        switch self {
        case .whiteBold15:
            return .white
        case .blueWhiteRegular18:
            return .blue
        case .blackRegular18:
            return .black
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case .blueWhiteRegular18:
            return .white
        default:
            return .clear
        }
    }
    
    var font: UIFont {
        switch self {
        case .whiteBold15:
            return .systemFont(ofSize: 15, weight: .bold)
        default:
            return .systemFont(ofSize: 18, weight: .regular)
        }
    }
}

public enum ButtonAlignment {
    case left(CGFloat), right(CGFloat), top(CGFloat), bottom(CGFloat)
}
