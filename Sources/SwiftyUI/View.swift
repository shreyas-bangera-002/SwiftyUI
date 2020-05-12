//
//  View.swift
//  
//
//  Created by SpringRole on 10/04/2020.
//

import UIKit

open class View<T: ViewModel>: UIView {
    
    public let viewModel: T
    
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge).then { $0.color = .gray }
    
    private let overlay = UIView {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    public var didLayout: (() -> Void)?
    
    public let presentingController: UIViewController
    
    public init(_ presentingController: UIViewController, viewModel: T) {
        self.viewModel = viewModel
        self.presentingController = presentingController
        super.init(frame: .zero)
        viewModelSetup()
        setupVM()
        render()
        let hud = UIView {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }.radius(8)
        sv(overlay.sv(hud.sv(activityIndicator)))
        overlay.fillContainer()
        hud.centered().size(60)
        activityIndicator.centered()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        didLayout?()
    }
    
    private func viewModelSetup() {
        viewModel.onError = { [weak self] in self?.showError($0.localizedDescription) }
        viewModel.startActivity = { [weak self] in self?.showActivity() }
        viewModel.stopActivity = { [weak self] in self?.stopActivity() }
        viewModel.fetch()
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(
            title: "Hey there!",
            message: error,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        presentingController.present(alert, animated: true, completion: nil)
    }
    
    private func showActivity() {
        overlay.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func stopActivity() {
        overlay.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    open func setupVM() {}
    open func render() {}
    
    deinit {
        log("\(#function) \(Self.self)")
    }
}
