//
//  Constants.swift
//  Consumer
//
//  Created by SpringRole on 15/11/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import Foundation

public class Constants {
    private init() {}
    public static let shared = Constants()
    var isMockingEnabled = false
    var isCachingEnabled = false
    var canShowNoNetwork = false
    var isLoggingEnabled = true
    
    public func configure(isMockingEnabled: Bool = false,
                          isCachingEnabled: Bool = false,
                          canShowNoNetwork: Bool = false,
                          isLoggingEnabled: Bool = true) {
        self.isMockingEnabled = isMockingEnabled
        self.isCachingEnabled = isCachingEnabled
        self.canShowNoNetwork = canShowNoNetwork
        self.isLoggingEnabled = isLoggingEnabled
    }
}
