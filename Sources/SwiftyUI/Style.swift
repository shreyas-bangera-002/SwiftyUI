//
//  Style.swift
//  Plowz
//
//  Created by SpringRole on 08/11/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
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

public extension UIFont {
    enum FontType {
        case helveticaNeueBold(CGFloat)
        case helveticaNeueRegular(CGFloat)
        case helveticaNeueLight(CGFloat)
        case helveticaNeueMedium(CGFloat)
        case helveticaNeueThin(CGFloat)
    }
    
    convenience init(_ type: FontType) {
        switch type {
        case let .helveticaNeueBold(size):
            self.init(name: "HelveticaNeue-Bold", size: size)!
        case let .helveticaNeueRegular(size):
            self.init(name: "HelveticaNeue", size: size)!
        case let .helveticaNeueLight(size):
            self.init(name: "HelveticaNeue-Light", size: size)!
        case let .helveticaNeueMedium(size):
            self.init(name: "HelveticaNeue-Medium", size: size)!
        case let .helveticaNeueThin(size):
            self.init(name: "HelveticaNeue-Thin", size: size)!
        }
    }
}

public enum Style {
    case blackRegular18
    
    var color: UIColor {
        switch self {
        default:
            return .black
        }
    }
    
    var bgColor: UIColor {
        switch self {
        default:
            return .clear
        }
    }
    
    var font: UIFont {
        switch self {
        default:
            return UIFont(.helveticaNeueRegular(18))
        }
    }
}

public enum ButtonStyle {
    case blueWhiteRegular18, whiteBold15
    
    var color: UIColor {
        switch self {
        case .whiteBold15: return .white
        default: return .blue
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case .blueWhiteRegular18: return .white
        default: return .clear
        }
    }
    
    var font: UIFont {
        switch self {
        case .whiteBold15: return UIFont(.helveticaNeueBold(15))
        default: return UIFont(.helveticaNeueRegular(18))
        }
    }
}

public enum ButtonAlignment {
    case left(CGFloat), right(CGFloat), top(CGFloat), bottom(CGFloat)
}
