//
//  UIViewExtension.swift
//  Plowz
//
//  Created by Shreyas Bangera on 07/11/2019.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

public enum ScrollDirection { case horizontal, vertical }

prefix operator >=
@discardableResult
public prefix func >= (value: CGFloat) -> FlexibleMargin {
    return FlexibleMargin(points: value, relation: .greaterThanOrEqual)
}

prefix operator <=
@discardableResult
public prefix func <= (value: CGFloat) -> FlexibleMargin {
    return FlexibleMargin(points: value, relation: .lessThanOrEqual)
}

public struct FlexibleMargin {
    let points: CGFloat
    let relation: NSLayoutConstraint.Relation
}

extension UIView {
    
    public enum ConstraintType {
        case left, right, top, bottom
    }
    
    public enum LayoutContext { case normal, safe }
    
    @discardableResult
    public func top(_ value: CGFloat = 0, from item: NSLayoutYAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutYAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.topAnchor : superview?.safeAreaLayoutGuide.topAnchor
        } else {
            layoutAnchor = superview?.topAnchor
        }
        if let item = item ?? layoutAnchor {
            topAnchor.constraint(equalTo: item, constant: value).isActive = true
        }
        return self
    }
    
    @discardableResult
    public func top(_ value: FlexibleMargin, from item: NSLayoutYAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutYAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.topAnchor : superview?.safeAreaLayoutGuide.topAnchor
        } else {
            layoutAnchor = superview?.topAnchor
        }
        if let item = item ?? layoutAnchor {
            switch value.relation {
            case .greaterThanOrEqual:
                topAnchor.constraint(greaterThanOrEqualTo: item, constant: value.points).isActive = true
            case .lessThanOrEqual:
                topAnchor.constraint(lessThanOrEqualTo: item, constant: value.points).isActive = true
            default:
                break
            }
        }
        return self
    }
    
    @discardableResult
    public func left(_ value: CGFloat = 0, from item: NSLayoutXAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutXAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.leftAnchor : superview?.safeAreaLayoutGuide.leftAnchor
        } else {
            layoutAnchor = superview?.leftAnchor
        }
        if let item = item ?? layoutAnchor {
            leftAnchor.constraint(equalTo: item, constant: value).isActive = true
        }
        return self
    }
    
    @discardableResult
    public func left(_ value: FlexibleMargin, from item: NSLayoutXAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutXAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.leftAnchor : superview?.safeAreaLayoutGuide.leftAnchor
        } else {
            layoutAnchor = superview?.leftAnchor
        }
        if let item = item ?? layoutAnchor {
            switch value.relation {
            case .greaterThanOrEqual:
                leftAnchor.constraint(greaterThanOrEqualTo: item, constant: value.points).isActive = true
            case .lessThanOrEqual:
                leftAnchor.constraint(lessThanOrEqualTo: item, constant: value.points).isActive = true
            default:
                break
            }
        }
        return self
    }
    
    @discardableResult
    public func right(_ value: CGFloat = 0, from item: NSLayoutXAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutXAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.rightAnchor : superview?.safeAreaLayoutGuide.rightAnchor
        } else {
            layoutAnchor = superview?.rightAnchor
        }
        if let item = item ?? layoutAnchor {
            rightAnchor.constraint(equalTo: item, constant: -value).isActive = true
        }
        return self
    }
    
    @discardableResult
    public func right(_ value: FlexibleMargin, from item: NSLayoutXAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutXAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.rightAnchor : superview?.safeAreaLayoutGuide.rightAnchor
        } else {
            layoutAnchor = superview?.rightAnchor
        }
        if let item = item ?? layoutAnchor {
            switch value.relation {
            case .greaterThanOrEqual:
                rightAnchor.constraint(greaterThanOrEqualTo: item, constant: -value.points).isActive = true
            case .lessThanOrEqual:
                rightAnchor.constraint(lessThanOrEqualTo: item, constant: -value.points).isActive = true
            default:
                break
            }
        }
        return self
    }
    
    @discardableResult
    public func bottom(_ value: CGFloat = 0, from item: NSLayoutYAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutYAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.bottomAnchor : superview?.safeAreaLayoutGuide.bottomAnchor
        } else {
            layoutAnchor = superview?.bottomAnchor
        }
        if let item = item ?? layoutAnchor {
            bottomAnchor.constraint(equalTo: item, constant: -value).isActive = true
        }
        return self
    }
    
    @discardableResult
    public func bottom(_ value: FlexibleMargin, from item: NSLayoutYAxisAnchor? = nil, context: LayoutContext = .normal) -> UIView {
        let layoutAnchor: NSLayoutYAxisAnchor?
        if #available(iOS 11.0, *) {
            layoutAnchor = context == .normal ? superview?.bottomAnchor : superview?.safeAreaLayoutGuide.bottomAnchor
        } else {
            layoutAnchor = superview?.bottomAnchor
        }
        if let item = item ?? layoutAnchor {
            switch value.relation {
            case .greaterThanOrEqual:
                bottomAnchor.constraint(greaterThanOrEqualTo: item, constant: -value.points).isActive = true
            case .lessThanOrEqual:
                bottomAnchor.constraint(lessThanOrEqualTo: item, constant: -value.points).isActive = true
            default:
                break
            }
        }
        return self
    }
    
    @discardableResult
    public func fillContainer(_ value: CGFloat = 0) -> UIView {
        guard let view = superview else { return self }
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: value),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -value),
            topAnchor.constraint(equalTo: view.topAnchor, constant: value),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -value)
        ])
        return self
    }
    
    @discardableResult
    public func fill(_ contraintTypes: ConstraintType..., value: CGFloat = 0, context: LayoutContext = .normal) -> UIView {
        contraintTypes.forEach {
            switch $0 {
            case .left:
                left(value)
            case .right:
                right(value)
            case .top:
                top(value)
            case .bottom:
                bottom(value)
            }
        }
        return self
    }
    
    @discardableResult
    public func size(_ value: CGFloat = 0) -> UIView {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: value),
            heightAnchor.constraint(equalToConstant: value)
        ])
        return self
    }
    
    @discardableResult
    public func circle(_ value: CGFloat = 0) -> UIView {
        size(value).then {
            $0.layer.cornerRadius = value/2
        }
    }
    
    @discardableResult
    public func width(_ value: CGFloat = 0) -> UIView {
        widthAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }
    
    @discardableResult
    public func height(_ value: CGFloat = 0) -> UIView {
        heightAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }
    
    @discardableResult
    public func heightEqualToSuperview() -> UIView {
        guard let view = superview else { return self }
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return self
    }
    
    @discardableResult
    public func widthEqualToSuperview() -> UIView {
        guard let view = superview else { return self }
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return self
    }
    
    @discardableResult
    public func widthEqualsHeight() -> UIView {
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        return self
    }
    
    @discardableResult
    public func square() -> UIView {
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        return self
    }
    
    @discardableResult
    public func widthFactor(_ value: CGFloat) -> UIView {
        guard let view = superview else { return self }
        widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: value).isActive = true
        return self
    }
    
    @discardableResult
    public func heightFactor(_ value: CGFloat) -> UIView {
        guard let view = superview else { return self }
        heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: value).isActive = true
        return self
    }
    
    @discardableResult
    public func sv(_ subViews: UIView...) -> UIView {
        return sv(subViews)
    }
    
    @discardableResult
    public func sv(_ subViews: [UIView]) -> UIView {
        for subView in subViews {
            addSubview(subView)
            subView.translatesAutoresizingMaskIntoConstraints = false
            subView.layout?(subView)
            if let view = subView.child?() {
                subView.sv(view)
            }
        }
        return self
    }
    
    @discardableResult
    public func centerHorizontally(_ value: CGFloat = 0) -> UIView {
        guard let view = superview else { return self }
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: value).isActive = true
        return self
    }
    
    @discardableResult
    public func centerVertically(_ value: CGFloat = 0) -> UIView {
        guard let view = superview else { return self }
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: value).isActive = true
        return self
    }
    
    @discardableResult
    public func centered(_ value: CGFloat = 0) -> UIView {
        guard let view = superview else { return self }
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: value),
            centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: value)
        ])
        return self
    }
    
    @discardableResult
    public func horizontal(_ value: CGFloat = 0) -> UIView {
        left(value).right(value)
    }
    
    @discardableResult
    public func vertical(_ value: CGFloat = 0) -> UIView {
        top(value).bottom(value)
    }
    
    @discardableResult
    public func hide() -> Self {
        isHidden = true
        return self
    }
    
    @discardableResult
    public func unhide() -> Self {
        isHidden = false
        return self
    }
    
    public func visibilityToggle() {
        alpha = alpha == 0 ? 1 : 0
    }
    
    public func animateVisibilityToggle(_ completion: FinallyBlock = nil) {
        let newAlpha: CGFloat = alpha == 0 ? 1 : 0
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.alpha = newAlpha
            },
            completion: {_ in completion?() }
        )
    }
    
    public func scrollContainer(_ direction: ScrollDirection) -> UIView {
        let scrollView = UIScrollView {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }
        let container = UIView()
        sv(scrollView.sv(container))
        scrollView.fillContainer()
        container.fillContainer()
        switch direction {
        case .horizontal:
            container.heightEqualToSuperview()
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).then {
                $0.priority = .defaultLow
                $0.isActive = true
            }
        case .vertical:
            container.widthEqualToSuperview()
            container.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1).then {
                $0.priority = .defaultLow
                $0.isActive = true
            }
        }
        return container
    }
    
    public enum Priority {
        case compression(UILayoutPriority, NSLayoutConstraint.Axis)
        case hugging(UILayoutPriority, NSLayoutConstraint.Axis)
    }
    
    @discardableResult
    public func priority(_ priority: Priority) -> Self {
        switch priority {
        case let .compression(layoutPriority, axis):
            setContentCompressionResistancePriority(layoutPriority, for: axis)
        case let .hugging(layoutPriority, axis):
            setContentHuggingPriority(layoutPriority, for: axis)
        }
        return self
    }
    
    @discardableResult
    public func radius(_ value: CGFloat) -> Self {
        layer.cornerRadius = value
        return self
    }
    
    @discardableResult
    public func mask() -> Self {
        layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    public func dropShadow(_ color: UIColor = .black, opacity: Float = 0.3, offset: CGSize = .init(width: 0, height: 2)) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        return self
    }
    
    @discardableResult
    public func shadow(opacity: Float = 0.1) -> Self {
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        return self
    }
    
    public func present(_ view: UIView?) {
        guard let view = view else { return }
        sv(view)
        view.fillContainer()
        view.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
        UIView.transition(with: self,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: { view.transform = .identity},
                          completion: nil)
    }
    
    public func remove() {
        guard let view = superview else { return }
        UIView.transition(with: view, duration: 0.3, options: [.transitionCrossDissolve], animations: { [weak self] in
            self?.removeFromSuperview()
        }, completion: nil)
    }
    
    public func crossDissolve() {
        guard let view = superview else { return }
        UIView.transition(with: view, duration: 0.3, options: [.transitionCrossDissolve], animations: { [weak self] in
            self?.isHidden.toggle()
        }, completion: nil)
    }
    
    @discardableResult
    public func addGradient(_ colors: UIColor..., startPoint: CGPoint = .init(x: 0.5, y: 0), endPoint: CGPoint = .init(x: 0.5, y: 1)) -> FinallyBlock {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        layer.addSublayer(gradient)
        return { [weak self] in gradient.frame = self?.bounds ?? .zero }
    }
    
    public func hideFromStack(_ hide: Bool) {
        superview?.isHidden = hide
    }
    
    @discardableResult
    public func add(to view: UIView) -> Self {
        view.sv(self)
        return self
    }
    
    @discardableResult
    public func border(_ color: UIColor, width: CGFloat = 1) -> Self {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self
    }
    
    public static func vDivider(v: CGFloat = 0) -> UIView {
        UIView {
            $0.width(1)
            $0.backgroundColor = .lightGray
            $0.layout = { $0.width(1).left().right().top(v).bottom(v) }
        }
    }
    
    public static func hDivider(h: CGFloat = 0, height: CGFloat = 1) -> UIView {
        UIView {
            $0.backgroundColor = .lightGray
            $0.layout = { $0.height(height).left(h).right(h).top().bottom() }
        }
    }
    
    fileprivate static func space(h: CGFloat? = nil, w: CGFloat? = nil) -> UIView {
        UIView {
            $0.layout = {
                $0.fillContainer()
                if let height = h {
                    $0.height(height)
                }
                if let width = w {
                    $0.width(width)
                }
            }
        }
    }
    
    public static var empty: UIView { space() }
    
    public static func vSpace(_ value: CGFloat = 0, color: UIColor = .clear) -> UIView { space(h: value).bgColor(color) }
    
    public static func hSpace(_ value: CGFloat = 0, color: UIColor = .clear) -> UIView { space(w: value).bgColor(color) }
    
    public static func spacer(color: UIColor = .clear) -> UIView {
        UIView { $0.backgroundColor = color; $0.layout = { $0.fillContainer() } }
    }
    
    @discardableResult
    func bgColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    public static var header: (view: UIView, configure: (UITableView?) -> Void) {
        let headerView = UIView()
        return (headerView, { table in
            let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if headerView.frame.size.height != size.height {
                headerView.frame.size.height = size.height
                table?.tableHeaderView = headerView
            }
        })
    }
    
    public func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

extension UIStackView {
    @discardableResult
    public func spacing(_ value: CGFloat) -> UIStackView {
        self.spacing = value
        return self
    }
    
    public func insert(_ view: UIView, at location: Int) {
        insertArrangedSubview(UIView { $0.sv(view) }, at: location)
    }
}

public typealias Layout = (UIView) -> Void
public typealias Child = () -> UIView?

public extension UIView {
    private struct AssociatedKeys {
        static var LayoutKey = "LayoutKey"
        static var ChildKey = "ChildKey"
    }
    var layout: Layout? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.LayoutKey) as? Layout
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.LayoutKey,
                    newValue as Layout?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    var child: Child? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ChildKey) as? Child
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.ChildKey,
                    newValue as Child?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}

@discardableResult
public func vStack(_ views: UIView?..., layout: @escaping Layout = { $0.fillContainer() }, config: StackConfig = .zero) -> UIStackView {
    stack(views, axis: .vertical, config: config, layout: layout)
}

@discardableResult
public func hStack(_ views: UIView?..., layout: @escaping Layout = { $0.fillContainer() }, config: StackConfig = .zero) -> UIStackView {
    stack(views, axis: .horizontal, config: config, layout: layout)
}

@discardableResult
public func vStack(_ views: [UIView?], layout: @escaping Layout = { $0.fillContainer() }, config: StackConfig = .zero) -> UIStackView {
    stack(views, axis: .vertical, config: config, layout: layout)
}

@discardableResult
public func hStack(_ views: [UIView?], layout: @escaping Layout = { $0.fillContainer() }, config: StackConfig = .zero) -> UIStackView {
    stack(views, axis: .horizontal, config: config, layout: layout)
}

@discardableResult
public func stack(_ views: [UIView?], axis: NSLayoutConstraint.Axis, config: StackConfig = .zero, layout: @escaping Layout) -> UIStackView {
    UIStackView(arrangedSubviews: views
        .compactMap { $0 }.map { view in UIView { $0.sv(view) }})
        .then {
            $0.axis = axis
            $0.layout = layout
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = config.inset
            $0.spacing = config.spacing
            $0.distribution = config.distribution
            $0.insertSubview(UIView {
                $0.border(config.borderColor, width: config.borderWidth).radius(config.radius)
                $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                $0.backgroundColor = config.color
            }, at: 0)
    }
}

public func Container(color: UIColor = .white, radius: CGFloat = 0, opacity: Float = 0.1, offset: CGSize = .zero, child: UIView, layout: @escaping Layout = { $0.fillContainer() }) -> UIView {
    UIView {
        $0.backgroundColor = color
        $0.layer.cornerRadius = radius
        $0.layer.shadowOpacity = opacity
        $0.layer.shadowRadius = 4
        $0.layer.shadowOffset = offset
        $0.layout = layout
        UIView {
            $0.layer.cornerRadius = radius
            $0.layout = { $0.fillContainer() }
            $0.sv(child)
            $0.clipsToBounds = true
        }.add(to: $0)
    }
}

public func borderView(color: UIColor, width: CGFloat = 1, layout: @escaping Layout, child: Child? = nil) -> UIView {
    UIView {
        $0.layer.borderColor = color.cgColor
        $0.layer.borderWidth = width
        $0.layout = layout
        $0.child = child
        $0.clipsToBounds = true
    }
}

public extension UIEdgeInsets {
    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    init(h: CGFloat = 0, v: CGFloat = 0) {
        self.init(top: v, left: h, bottom: v, right: h)
    }
    
    init(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) {
        self.init(top: t, left: l, bottom: b, right: r)
    }
}
