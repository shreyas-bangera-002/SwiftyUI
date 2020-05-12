//
//  UIKitExtensions.swift
//  Plowz
//
//  Created by SpringRole on 08/11/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import UIKit

public var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

public struct StackConfig {
    let spacing: CGFloat
    let inset: UIEdgeInsets
    let distribution: UIStackView.Distribution
    let color: UIColor
    let borderColor: UIColor
    let borderWidth: CGFloat
    let radius: CGFloat
    let removeBuffer: Bool
    public static let zero = StackConfig()
    
    public init(color: UIColor = .clear,
                spacing: CGFloat = 0,
                inset: UIEdgeInsets = .zero,
                distribution: UIStackView.Distribution = .fill,
                borderColor: UIColor = .clear,
                borderWidth: CGFloat = 1,
                radius: CGFloat = 0,
                removeBuffer: Bool = false) {
        self.color = color
        self.spacing = spacing
        self.inset = inset
        self.distribution = distribution
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.radius = radius
        self.removeBuffer = removeBuffer
    }
}

extension UIButton {
    
    @discardableResult
    public convenience init(style: Style, title: String? = nil, image: ImageNameable? = nil, tint: UIColor? = nil, alignment: ButtonAlignment? = nil, layout: Layout? = nil, onTap: FinallyBlock = nil) {
        self.init(frame: .zero)
        setTitle(title)
        configure(style: style, image: image, tint: tint, alignment: alignment, layout: layout, onTap: onTap)
    }
    
    public convenience init(style: Style, image: ImageNameable? = nil, tint: UIColor? = nil, alignment: ButtonAlignment? = nil, layout: Layout? = nil, onTap: FinallyBlock = nil) {
        self.init(frame: .zero)
        configure(style: style, image: image, tint: tint, alignment: alignment, layout: layout, onTap: onTap)
    }
    
    private func configure(style: Style, image: ImageNameable? = nil, tint: UIColor? = nil, alignment: ButtonAlignment? = nil, layout: Layout? = nil, onTap: FinallyBlock = nil) {
        self.image(image, tint: tint)
        addStyle(style)
        self.onTap { _ in onTap?() }
        self.layout = layout
        if let alignment = alignment {
            switch alignment {
            case let .left(value):
                contentHorizontalAlignment = .left
                contentEdgeInsets = .init(top: 0, left: value, bottom: 0, right: 0)
            case let .right(value):
                contentHorizontalAlignment = .right
                contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: value)
            case let .top(value):
                contentVerticalAlignment = .top
                contentEdgeInsets = .init(top: value, left: 0, bottom: 0, right: 0)
            case let .bottom(value):
                contentVerticalAlignment = .bottom
                contentEdgeInsets = .init(top: 0, left: 0, bottom: value, right: 0)
            }
        }
    }
    
    func addStyle(_ style: Style) {
        titleLabel?.font = style.font
        titleColor(style.color)
        backgroundColor = style.bgColor
    }
    
    public func setTitle(_ text: String?) {
        setTitle(text, for: .normal)
    }
    
    public func titleColor(_ color: UIColor) {
        setTitleColor(color, for: .normal)
    }
    
    public func image(_ name: ImageNameable?, tint: UIColor? = nil) {
        guard let name = name else { return }
        if let tint = tint {
            setImage(UIImage(name)?.withRenderingMode(.alwaysTemplate), for: .normal)
            tintColor = tint
        } else {
            setImage(UIImage(name), for: .normal)
        }
    }
}

public extension UILabel {
    
    @discardableResult
    convenience init(style: Style, title: String?, isMultiline: Bool = false, alignment: NSTextAlignment = .natural, layout: Layout? = nil) {
        self.init(frame: .zero)
        setText(title)
        configure(style: style, isMultiline: isMultiline, alignment: alignment, layout: layout)
    }
    
    @discardableResult
    convenience init(style: Style, isMultiline: Bool = false, alignment: NSTextAlignment = .natural, layout: Layout? = nil) {
        self.init(frame: .zero)
        configure(style: style, isMultiline: isMultiline, alignment: alignment, layout: layout)
    }
    
    private func configure(style: Style, isMultiline: Bool = false, alignment: NSTextAlignment = .natural, layout: Layout? = nil) {
        addStyle(style)
        textAlignment = alignment
        if isMultiline {
            numberOfLines = 0
            lineBreakMode = .byWordWrapping
        }
        self.layout = layout
    }
    
    func addStyle(_ style: Style) {
        textColor = style.color
        backgroundColor = style.bgColor
        font = style.font
    }
    
    func setText(_ string: String?) {
        text = string
    }
}

extension UIImageView {
    public convenience init(name: ImageNameable? = nil, mode: UIView.ContentMode = .scaleToFill, tint: UIColor? = nil, layout: Layout? = nil) {
        self.init(frame: .zero)
        contentMode = mode
        image(name, tint: tint)
        self.layout = layout
    }
    
    public func image(_ name: ImageNameable? = nil, tint: UIColor? = nil) {
        guard let name = name else { return }
        if let tint = tint {
            image = UIImage(name)?.withRenderingMode(.alwaysTemplate)
            tintColor = tint
        } else {
            image = UIImage(name)
        }
    }
}

extension UITextField {
    public convenience init(style: Style, text: String? = nil, placeholder: String? = nil, placeholderStyle: Style, keyboard: UIKeyboardType = .default, layout: Layout? = nil) {
        self.init(frame: .zero)
        self.text = text
        textColor = style.color
        font = style.font
        backgroundColor = style.bgColor
        keyboardType = keyboard
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: placeholderStyle.font,
                    .foregroundColor: placeholderStyle.color
            ])
        }
        self.layout = layout
    }
    
    public func addLeftPadding(_ value: CGFloat) {
        leftView = UIView(frame: .init(x: 0, y: 0, width: value, height: 0))
        leftViewMode = .always
    }
    
    @discardableResult
    public func addAccessory(leftText: String? = nil, leftAction: FinallyBlock = nil, rightImage: ImageNameable? = nil, rightText: String? = nil, rightAction: FinallyBlock) -> Self {
        inputAccessoryView = UIToolbar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)).then {
            var items = [UIBarButtonItem]()
            if let text = leftText {
                items.append(UIBarButtonItem(customView: UIButton(style: Styles.blueWhiteRegular18, title: text, onTap: leftAction)))
            }
            if let rightText = rightText {
                items.append(contentsOf: [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(title: rightText, style: .plain, closure: {_ in rightAction?() })
                ])
            } else if let rightImage = rightImage {
                items.append(contentsOf: [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(
                        image: rightImage,
                        style: .done,
                        closure: {_ in rightAction?() }
                    )
                ])
            }
            $0.items = items
            $0.sizeToFit()
        }
        return self
    }
}

extension UITextView {
    public static func link(style: Style, text: String, linkTexts: [String: String]) -> UITextView {
        UITextView {
            $0.attributedText = NSMutableAttributedString(
                string: text,
                attributes: [
                    .foregroundColor: style.color,
                    .font: style.font
            ]).then { attrb in
                linkTexts.forEach {
                    guard let range = text.range(of: $0.0) else { return }
                    attrb.addAttribute(.link, value: $0.1, range: NSRange(range, in: text))
                }
            }
            $0.backgroundColor = .white
            $0.isSelectable = true
            $0.isEditable = false
        }
    }
}

extension UIImage {
    public convenience init?(_ imageName: ImageNameable) {
        self.init(named: imageName.value)
    }
    
    public func resizeImage(_ targetSize: CGSize = .init(width: 1024, height: 1024)) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return newImage
    }
}

public extension UILabel {
    static func create(_ style: Style,_ text: String? = "", alignment: NSTextAlignment = .natural, position: Position = .fill(0, 0), width: CGFloat? = nil, height: CGFloat? = nil) -> UILabel {
        UILabel(
            style: style,
            title: text,
            isMultiline: true,
            alignment: alignment,
            layout: {
                $0.addPosition(position)
                if let width = width {
                    $0.width(width)
                }
                if let height = height {
                    $0.height(height)
                }
        }
        )
    }
}

public enum Position {
    case fill(CGFloat,CGFloat), centerXFill, center, centerY, centerX, centerYFill, left(CGFloat)
}

public extension UIButton {
    static func create(_ style: Style,_ text: String? = nil, image: ImageNameable? = nil, height: CGFloat = 44, position: Position = .fill(0,0), alignment: ButtonAlignment? = nil, onTap: FinallyBlock = nil) -> UIButton {
        UIButton(
            style: style,
            title: text,
            image: image,
            alignment: alignment,
            layout: {
                $0.height(height)
                $0.addPosition(position)
            },
            onTap: onTap
        )
    }
}

extension UIView {
    func addPosition(_ position: Position) {
        switch position {
        case let .fill(h, v):
            fill(.left, .right, value: h).fill(.top, .bottom, value: v)
        case .centerXFill:
            centerHorizontally().top().bottom()
        case .centerY:
            centerVertically()
        case .center:
            centered()
        case .centerX:
            centerHorizontally()
        case .centerYFill:
            centerVertically().top().bottom()
        case let .left(val):
            left(val).top().bottom()
        }
    }
}

public extension Data {
    var image: UIImage? {
        UIImage(data: self)
    }
}

public extension CGRect {
    init(width: CGFloat = 0, height: CGFloat = 0) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
}
