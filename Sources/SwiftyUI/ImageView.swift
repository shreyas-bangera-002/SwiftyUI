//
//  ImageView.swift
//  Plowz
//
//  Created by SpringRole on 13/11/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import UIKit

public class ImageView: UIImageView {
    private var imageUrl: String?
    let activityIndicator = UIActivityIndicatorView(style: .gray).then {
        $0.hidesWhenStopped = true
    }
    
    public func load(_ urlString: String?, showLoader: Bool = true, placeholder: ImageNameable? = nil) {
        if let placeholder = placeholder {
            image(placeholder)
        }
        guard let urlString = urlString, !urlString.isEmpty else { return }
        guard urlString.contains("http") else {
            image = UIImage(named: urlString)
            return
        }
        if activityIndicator.superview == nil {
            sv(activityIndicator)
            activityIndicator.centered()
        }
        guard let url = URL(string: urlString) else { return }
        imageUrl = urlString
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        func loadImage(_ image: UIImage) {
            guard imageUrl == urlString else { return }
            UIView.transition(with: self, duration: 0.3, options: [.transitionCrossDissolve], animations: { [weak self] in self?.image = image }, completion: nil)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async { loadImage(image) }
            } else {
                DispatchQueue.main.async { self?.activityIndicator.startAnimating() }
                URLSession.shared.dataTask(with: request) {
                    DispatchQueue.main.async { self?.activityIndicator.stopAnimating() }
                    if $2 == nil, let data = $0, let response = $1,
                        response.httpUrlResponse?.statusCode ?? 500 < 300,
                        let image = UIImage(data: data) {
                        cache.storeCachedResponse(.init(response: response, data: data), for: request)
                        DispatchQueue.main.async { loadImage(image) }
                    }
                }.resume()
            }
        }
    }
}
