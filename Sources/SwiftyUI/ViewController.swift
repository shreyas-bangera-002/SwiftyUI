//
//  ViewController.swift
//  Plowz
//
//  Created by SpringRole on 07/11/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import UIKit
import Photos

public func log(_ items: Any...) {
    #if RELEASE
    #else
    if Constants.shared.isLoggingEnabled {
        debugPrint(items)
    }
    #endif
}

public protocol SessionTokenProtocol: ViewModel {
    func fetchSessionToken(_ onSuccess: FinallyBlock)
}

public protocol Delegate: class {}

open class BaseController: UIViewController {
    public weak var delegate: Delegate?
}

open class ViewController<T: ViewModel>: BaseController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public let disposable = Disposable()

    public let viewModel: T
        
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge).then { $0.color = .gray }
    
    private let overlay = UIView {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    private let noNetworkView = UILabel(
        style: Styles.blackRegular18,
        title: "No network available!",
        isMultiline: true,
        alignment: .center
    )
        
    public var didLayout: (() -> Void)?
        
    public init(_ viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tokens = [NSObjectProtocol]()
    
    public lazy var picker = UIImagePickerController().then {
        $0.delegate = self
    }
    
    public func openGallery() {
        picker.sourceType = .photoLibrary
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            present(picker, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] in
                if $0 == .authorized, let controller = self?.picker {
                    self?.present(controller, animated: true, completion: nil)
                }
            }
        default:
            showError("Please enable access to photos")
        }
    }
    
    public func openCamera() {
        picker.sourceType = .camera
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            showError("Please enable camera access to capture photos")
            return
        }
        present(picker, animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModelSetup()
        setupVM()
        render()
        (navigationController?.view ?? view).sv(overlay.sv(activityIndicator))
        overlay.fillContainer()
        activityIndicator.centered()
    }
    
    open func didBecomeActive() {}
    open func willResignActive() {}
    open func willEnterForeground() {}
    open func didEnterBackground() {}
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
        tokens.append(NotificationCenter.observe(.networkChanged) { [weak self] in
            self?.showNoNetworkView(!($0?[.isReachable]).boolValue)
        })
        tokens.append(NotificationCenter.observe(UIApplication.didBecomeActiveNotification, closure: { [weak self]_ in self?.didBecomeActive() }))
        tokens.append(NotificationCenter.observe(UIApplication.willResignActiveNotification, closure: { [weak self]_ in self?.willResignActive() }))
        tokens.append(NotificationCenter.observe(UIApplication.willEnterForegroundNotification, closure: { [weak self]_ in self?.willEnterForeground() }))
        tokens.append(NotificationCenter.observe(UIApplication.didEnterBackgroundNotification, closure: { [weak self]_ in self?.didEnterBackground() }))
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didLayout?()
    }
    
    private func showNoNetworkView(_ show: Bool) {
        guard Constants.shared.canShowNoNetwork, !Constants.shared.isCachingEnabled else { return }
        if show {
            (navigationController?.view ?? view)?.present(noNetworkView)
        } else {
            noNetworkView.remove()
        }
    }
    
    private func viewModelSetup() {
        viewModel.onError = { [weak self] in self?.showError($0.localizedDescription) }
        viewModel.startActivity = { [weak self] in self?.showActivity() }
        viewModel.stopActivity = { [weak self] in self?.stopActivity() }
        viewModel.fetch()
    }
    
    public func showError(_ error: String) {
        let alert = UIAlertController(
            title: "Hey there!",
            message: error,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    public func showActivity() {
        overlay.isHidden = false
        activityIndicator.startAnimating()
    }
    
    public func stopActivity() {
        overlay.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    open func setupVM() {}
    open func render() {}
    
    deinit {
        disposable.dispose()
        log("\(#function) \(Self.self)")
    }
}

open class LightController<T: ViewModel>: ViewController<T> {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

open class DarkController<T: ViewModel>: ViewController<T> {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}

