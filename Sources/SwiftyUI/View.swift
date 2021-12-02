//
//  View.swift
//  
//
//  Created by Shreyas Bangera on 10/04/2020.
//

import UIKit

open class View<T: BaseController>: UIView {

    public let disposable = Disposable()
    
    public var didLayout: (() -> Void)?
    
    public weak var controller: T?
    
    public init?(_ controller: T?, layout: Layout? = { $0.fillContainer() }) {
        guard let controller = controller else { return nil }
        self.controller = controller
        super.init(frame: .zero)
        self.layout = layout
        render()
        setupVM()
        controller.viewWillAppear.subscribe({ [weak self]_ in
            self?.viewWillAppear()
            }, disposeWith: disposable)
        controller.viewDidLayout.subscribe({ [weak self]_ in
            self?.viewDidLayout()
            }, disposeWith: disposable)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func viewDidLayout() {}
    open func viewWillAppear() {}
    open func setupVM() {}
    open func render() {}
    
    deinit {
        disposable.dispose()
        log("\(#function) \(Self.self)")
    }
}
